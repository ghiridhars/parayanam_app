import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';
import '../models/user_profile.dart';
import '../models/reader_category.dart';
import '../models/reader.dart';
import '../models/day_configuration.dart';
import '../models/reading_session.dart';
import '../services/data_service.dart';
import 'profile_screen.dart';

class ReaderAssignmentScreen extends StatefulWidget {
  final Book book;
  final UserProfile userProfile;
  final ReadingSession? session;
  final int selectedDay;

  const ReaderAssignmentScreen({
    super.key,
    required this.book,
    required this.userProfile,
    this.session,
    required this.selectedDay,
  });

  @override
  State<ReaderAssignmentScreen> createState() => _ReaderAssignmentScreenState();
}

class _ReaderAssignmentScreenState extends State<ReaderAssignmentScreen> {
  final DataService _dataService = DataService();
  final TextEditingController _nameController = TextEditingController();
  final DateFormat _timeFormat = DateFormat('hh:mm a');
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  
  List<Reader> _readers = [];
  List<ReaderCategory> _categories = [];
  List<DayConfiguration> _dayConfigs = [];
  int _currentLine = 1;
  int _currentParagraph = 1;
  int _currentDay = 1;
  String? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allReaders = await _dataService.loadReaders(widget.book.id);
    // Filter readers for selected day
    final readers = allReaders.where((r) => r.dayNumber == widget.selectedDay).toList();
    
    final categories = await _dataService.loadCategories(widget.book.id);
    final dayConfigs = await _dataService.loadDayConfigurations(widget.book.id, widget.book.totalDays);
    
    // Calculate current line and paragraph based on previous days
    int currentLine = 1;
    int currentParagraph = 1;
    
    // Add up all lines and paragraphs from previous days
    for (int day = 1; day < widget.selectedDay; day++) {
      final dayReaders = allReaders.where((r) => r.dayNumber == day).toList();
      if (dayReaders.isNotEmpty) {
        // Find the max end line and paragraph for this day
        currentLine = dayReaders.map((r) => r.endLine).reduce((a, b) => a > b ? a : b) + 1;
        currentParagraph = dayReaders.map((r) => r.endParagraph).reduce((a, b) => a > b ? a : b) + 1;
      } else if (day <= dayConfigs.length) {
        // Use day config limits if no readers assigned yet
        currentLine += dayConfigs[day - 1].maxLines;
        currentParagraph += dayConfigs[day - 1].maxParagraphs;
      }
    }
    
    // If there are readers for current day, continue from their max end
    if (readers.isNotEmpty) {
      currentLine = readers.map((r) => r.endLine).reduce((a, b) => a > b ? a : b) + 1;
      currentParagraph = readers.map((r) => r.endParagraph).reduce((a, b) => a > b ? a : b) + 1;
    }
    
    setState(() {
      _readers = readers;
      _currentLine = currentLine;
      _currentParagraph = currentParagraph;
      _categories = categories;
      _currentDay = widget.selectedDay;
      _dayConfigs = dayConfigs;
      _isLoading = false;
    });
  }

  Future<void> _addReader() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter reader name')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final category = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
    );

    // Check if adding this reader would exceed day limit
    if (_currentDay <= _dayConfigs.length) {
      final dayConfig = _dayConfigs[_currentDay - 1];
      final proposedEndLine = _currentLine + category.lineCount - 1;
      final proposedEndParagraph = _currentParagraph + category.paragraphCount - 1;
      
      if (proposedEndLine > dayConfig.maxLines * _currentDay || 
          proposedEndParagraph > dayConfig.maxParagraphs * _currentDay) {
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Day Limit Reached'),
            content: Text(
              'Adding this reader would exceed Day $_currentDay limits:\n'
              'Lines: ${dayConfig.maxLines}\n'
              'Paragraphs: ${dayConfig.maxParagraphs}\n\n'
              'Do you want to move to Day ${_currentDay + 1}?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Next Day'),
              ),
            ],
          ),
        );

        if (shouldContinue == true) {
          setState(() {
            _currentDay++;
          });
          await _dataService.setCurrentDay(widget.book.id, _currentDay);
        } else {
          return;
        }
      }
    }

    final reader = Reader(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      categoryId: category.id,
      punchInTime: DateTime.now(),
      startLine: _currentLine,
      endLine: _currentLine + category.lineCount - 1,
      startParagraph: _currentParagraph,
      endParagraph: _currentParagraph + category.paragraphCount - 1,
      bookId: widget.book.id,
      dayNumber: widget.selectedDay,
    );

    await _dataService.addReader(reader);
    
    setState(() {
      _readers.add(reader);
      _currentLine = reader.endLine + 1;
      _currentParagraph = reader.endParagraph + 1;
      _nameController.clear();
      _selectedCategoryId = null;
    });

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reader.name} assigned:\nLines ${reader.startLine}-${reader.endLine}\nParagraphs ${reader.startParagraph}-${reader.endParagraph}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _clearAllReaders() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Readers?'),
        content: const Text('This will remove all reader assignments and reset to Day 1, Line 1, Paragraph 1. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dataService.clearReaders(widget.book.id);
      await _dataService.setCurrentDay(widget.book.id, 1);
      setState(() {
        _readers.clear();
        _currentLine = 1;
        _currentParagraph = 1;
        _currentDay = 1;
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All readers cleared'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _deleteReader(Reader reader) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reader?'),
        content: Text('Remove ${reader.name} from the assignment list?\n\nThis will undo the assignment:\nLines ${reader.startLine}-${reader.endLine}\nParagraphs ${reader.startParagraph}-${reader.endParagraph}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dataService.deleteReader(widget.book.id, reader.id);
      await _loadData(); // Reload all data to get updated positions

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reader.name} removed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.session != null ? widget.session!.name : '${widget.book.displayName} - Readers',
              style: const TextStyle(fontSize: 18),
            ),
            if (widget.session != null)
              Text(
                widget.book.displayName,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userProfile: widget.userProfile,
                    selectedBookId: widget.book.id,
                  ),
                ),
              ).then((_) => _loadData()); // Reload data when returning from profile
            },
            tooltip: 'Category Settings',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _readers.isEmpty ? null : _clearAllReaders,
            tooltip: 'Clear All Readers',
          ),
        ],
      ),
      body: Container(
        decoration: widget.book.backgroundImage != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.book.backgroundImage!),
                  fit: BoxFit.cover,
                  opacity: 0.6,
                ),
              )
            : null,
        child: Column(
          children: [
            // Add Reader Form
            Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            color: Colors.white.withValues(alpha: 0.7),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add New Reader',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Day $_currentDay of ${widget.book.totalDays}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Reader Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: _getCategoryColor(category.id),
                              child: Text(
                                category.id,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('${category.name} (${category.lineCount}L, ${category.paragraphCount}¶)'),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Next Starting:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Line $_currentLine | ¶ $_currentParagraph',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        if (_currentDay <= _dayConfigs.length) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Day Limits:',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                '${_dayConfigs[_currentDay - 1].maxLines} lines | ${_dayConfigs[_currentDay - 1].maxParagraphs} ¶',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Lines', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    LinearProgressIndicator(
                                      value: _currentLine / _dayConfigs[_currentDay - 1].maxLines,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _currentLine / _dayConfigs[_currentDay - 1].maxLines > 0.8
                                            ? Colors.orange
                                            : Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Paragraphs', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    LinearProgressIndicator(
                                      value: _currentParagraph / _dayConfigs[_currentDay - 1].maxParagraphs,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _currentParagraph / _dayConfigs[_currentDay - 1].maxParagraphs > 0.8
                                            ? Colors.orange
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addReader,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Reader'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Readers List
          Expanded(
            child: _readers.isEmpty
                ? const Center(
                    child: Text(
                      'No readers assigned yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _readers.length,
                    itemBuilder: (context, index) {
                      final reader = _readers[_readers.length - 1 - index]; // Reverse order
                      final category = _categories.firstWhere(
                        (c) => c.id == reader.categoryId,
                      );
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        color: Colors.white.withValues(alpha: 0.7),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(category.id),
                            child: Text(
                              category.id,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            reader.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Lines: ${reader.startLine}-${reader.endLine} (${reader.totalLines} lines)'),
                              Text('Paragraphs: ${reader.startParagraph}-${reader.endParagraph} (${reader.totalParagraphs} ¶)'),
                              Text(
                                'Punch In: ${_timeFormat.format(reader.punchInTime)} - ${_dateFormat.format(reader.punchInTime)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReader(reader),
                            tooltip: 'Delete reader',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

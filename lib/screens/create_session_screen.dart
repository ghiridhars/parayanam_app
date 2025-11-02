import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/reading_session.dart';
import '../models/book.dart';
import '../models/user_profile.dart';
import '../models/reader_category.dart';
import '../models/day_configuration.dart';
import '../services/data_service.dart';

class CreateSessionScreen extends StatefulWidget {
  final UserProfile userProfile;
  final Book? selectedBook;
  final ReadingSession? editSession;

  const CreateSessionScreen({
    super.key,
    required this.userProfile,
    this.selectedBook,
    this.editSession,
  });

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final DataService _dataService = DataService();
  final TextEditingController _nameController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  
  String? _selectedBookId;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedColor = ReadingSession.availableColors[0];
  
  List<ReaderCategory> _categories = [];
  List<DayConfiguration> _dayConfigs = [];
  final Map<String, TextEditingController> _categoryLineControllers = {};
  final Map<String, TextEditingController> _categoryParagraphControllers = {};
  final Map<int, TextEditingController> _dayConfigLineControllers = {};
  final Map<int, TextEditingController> _dayConfigParagraphControllers = {};
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editSession != null) {
      // Load session for editing
      _nameController.text = widget.editSession!.name;
      _selectedBookId = widget.editSession!.bookId;
      _startDate = widget.editSession!.startDate;
      _endDate = widget.editSession!.endDate;
      _selectedColor = widget.editSession!.colorCode;
      _loadDefaults();
    } else if (widget.selectedBook != null) {
      _selectedBookId = widget.selectedBook!.id;
      _loadDefaults();
    }
  }

  Future<void> _loadDefaults() async {
    if (_selectedBookId == null) return;
    
    final book = Book.availableBooks.firstWhere((b) => b.id == _selectedBookId);
    
    // Load session-specific config if editing, otherwise load book defaults
    List<ReaderCategory> categories;
    List<DayConfiguration> dayConfigs;
    
    if (widget.editSession != null) {
      // Editing existing session - load session-specific config
      categories = await _dataService.loadSessionCategories(widget.editSession!.id) 
          ?? await _dataService.loadCategories(_selectedBookId!);
      dayConfigs = await _dataService.loadSessionDayConfig(widget.editSession!.id)
          ?? await _dataService.loadDayConfigurations(_selectedBookId!, book.totalDays);
    } else {
      // Creating new session - load book defaults
      categories = await _dataService.loadCategories(_selectedBookId!);
      dayConfigs = await _dataService.loadDayConfigurations(_selectedBookId!, book.totalDays);
    }
    
    setState(() {
      _categories = categories;
      _dayConfigs = dayConfigs;
    });
    
    // Initialize controllers
    for (var category in _categories) {
      _categoryLineControllers[category.id] = TextEditingController(
        text: category.lineCount.toString(),
      );
      _categoryParagraphControllers[category.id] = TextEditingController(
        text: category.paragraphCount.toString(),
      );
    }
    
    for (var dayConfig in _dayConfigs) {
      _dayConfigLineControllers[dayConfig.dayNumber] = TextEditingController(
        text: dayConfig.maxLines.toString(),
      );
      _dayConfigParagraphControllers[dayConfig.dayNumber] = TextEditingController(
        text: dayConfig.maxParagraphs.toString(),
      );
    }
  }

  Future<void> _createSession() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter session name')),
      );
      return;
    }
    
    if (_selectedBookId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a book')),
      );
      return;
    }
    
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }
    
    // Validate date range matches the number of days configured
    final book = Book.availableBooks.firstWhere((b) => b.id == _selectedBookId);
    final daysDifference = _endDate!.difference(_startDate!).inDays + 1;
    
    if (daysDifference != book.totalDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Date range must be exactly ${book.totalDays} days.\n'
            'Current selection: $daysDifference days.\n'
            'Please adjust the end date.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Update categories with new values
    for (var category in _categories) {
      final lineController = _categoryLineControllers[category.id];
      final paragraphController = _categoryParagraphControllers[category.id];
      if (lineController != null) {
        category.lineCount = int.tryParse(lineController.text) ?? category.lineCount;
      }
      if (paragraphController != null) {
        category.paragraphCount = int.tryParse(paragraphController.text) ?? category.paragraphCount;
      }
    }
    
    // Update day configs with new values
    for (var dayConfig in _dayConfigs) {
      final lineController = _dayConfigLineControllers[dayConfig.dayNumber];
      final paragraphController = _dayConfigParagraphControllers[dayConfig.dayNumber];
      if (lineController != null) {
        dayConfig.maxLines = int.tryParse(lineController.text) ?? dayConfig.maxLines;
      }
      if (paragraphController != null) {
        dayConfig.maxParagraphs = int.tryParse(paragraphController.text) ?? dayConfig.maxParagraphs;
      }
    }
    
    final session = ReadingSession(
      id: widget.editSession?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      bookId: _selectedBookId!,
      startDate: _startDate!,
      endDate: _endDate!,
      userProfileId: widget.userProfile.id,
      readerIds: widget.editSession?.readerIds ?? [],
      colorCode: _selectedColor,
    );
    
    await _dataService.saveReadingSession(session);
    await _dataService.saveSessionCategories(session.id, _categories);
    await _dataService.saveSessionDayConfig(session.id, _dayConfigs);
    
    if (!mounted) return;
    
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.editSession != null 
            ? 'Session "${session.name}" updated' 
            : 'Session "${session.name}" created'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _categoryLineControllers.values) {
      controller.dispose();
    }
    for (var controller in _categoryParagraphControllers.values) {
      controller.dispose();
    }
    for (var controller in _dayConfigLineControllers.values) {
      controller.dispose();
    }
    for (var controller in _dayConfigParagraphControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editSession != null ? 'Edit Reading Session' : 'Create Reading Session'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Session Name
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Session Name',
                      hintText: 'e.g., Bhagavatam December 2025',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Book Selection
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBookId,
                    decoration: const InputDecoration(
                      labelText: 'Select Book',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                    items: Book.getActiveBooks().map((book) {
                      return DropdownMenuItem(
                        value: book.id,
                        child: Text(book.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBookId = value;
                      });
                      _loadDefaults();
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date Range
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                                // Auto-calculate end date based on total days
                                if (_selectedBookId != null) {
                                  final book = Book.availableBooks.firstWhere((b) => b.id == _selectedBookId);
                                  _endDate = date.add(Duration(days: book.totalDays - 1));
                                }
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _startDate == null
                                ? 'Start Date'
                                : _dateFormat.format(_startDate!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? (_startDate ?? DateTime.now()),
                              firstDate: _startDate ?? DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => _endDate = date);
                            }
                          },
                          icon: const Icon(Icons.event),
                          label: Text(
                            _endDate == null
                                ? 'End Date'
                                : _dateFormat.format(_endDate!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedBookId != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Note: Date range must be exactly ${Book.availableBooks.firstWhere((b) => b.id == _selectedBookId).totalDays} days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Color Selection
                  const Text(
                    'Session Color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ReadingSession.availableColors.map((colorCode) {
                      final isSelected = _selectedColor == colorCode;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedColor = colorCode);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(int.parse(colorCode.replaceFirst('#', '0xFF'))),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  if (_selectedBookId != null && _dayConfigs.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Day Configuration
                    const Text(
                      'Day Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set maximum lines and paragraphs for each day',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._dayConfigs.map((dayConfig) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))).withAlpha(51),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Day',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    '${dayConfig.dayNumber}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _dayConfigLineControllers[dayConfig.dayNumber],
                                decoration: const InputDecoration(
                                  labelText: 'Max Lines',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _dayConfigParagraphControllers[dayConfig.dayNumber],
                                decoration: const InputDecoration(
                                  labelText: 'Max ¶',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Reader Categories
                    const Text(
                      'Reader Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set lines and paragraphs for each category',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _getCategoryColor(category.id),
                              child: Text(
                                category.id,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    category.description,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: _categoryLineControllers[category.id],
                                decoration: const InputDecoration(
                                  labelText: 'Lines',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                controller: _categoryParagraphControllers[category.id],
                                decoration: const InputDecoration(
                                  labelText: '¶',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _createSession,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      widget.editSession != null ? 'Update Session' : 'Create Session',
                      style: const TextStyle(fontSize: 16),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reading_session.dart';
import '../models/book.dart';
import '../models/user_profile.dart';
import '../models/day_status.dart';
import '../models/day_configuration.dart';
import '../services/data_service.dart';
import 'reader_assignment_screen.dart';
import 'create_session_screen.dart';

class DayPlanningScreen extends StatefulWidget {
  final ReadingSession session;
  final Book book;
  final UserProfile userProfile;

  const DayPlanningScreen({
    super.key,
    required this.session,
    required this.book,
    required this.userProfile,
  });

  @override
  State<DayPlanningScreen> createState() => _DayPlanningScreenState();
}

class _DayPlanningScreenState extends State<DayPlanningScreen> {
  final DataService _dataService = DataService();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  
  List<DayStatus> _dayStatuses = [];
  List<DayConfiguration> _dayConfigs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDayStatuses();
  }

  Future<void> _loadDayStatuses() async {
    final statuses = await _dataService.loadDayStatuses(widget.session.id, widget.book.totalDays);
    
    // Load session-specific day configurations (not book defaults)
    final configs = await _dataService.loadSessionDayConfig(widget.session.id)
        ?? await _dataService.loadDayConfigurations(widget.book.id, widget.book.totalDays);
    
    setState(() {
      _dayStatuses = statuses;
      _dayConfigs = configs;
      _isLoading = false;
    });
  }

  Future<void> _toggleDayStatus(DayStatus dayStatus) async {
    if (dayStatus.isDone) {
      // Unmark as done
      final updated = dayStatus.copyWith(isDone: false);
      await _dataService.saveDayStatuses(widget.session.id, _updateStatus(updated));
      _loadDayStatuses();
    } else {
      // Mark as done with confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mark Day as Done?'),
          content: Text('Mark Day ${dayStatus.dayNumber} as completed?\n\nNo further reader assignments will be allowed for this day.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark as Done'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final updated = dayStatus.copyWith(isDone: true);
        await _dataService.saveDayStatuses(widget.session.id, _updateStatus(updated));
        _loadDayStatuses();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day ${dayStatus.dayNumber} marked as done'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  List<DayStatus> _updateStatus(DayStatus updated) {
    return _dayStatuses.map((s) => s.dayNumber == updated.dayNumber ? updated : s).toList();
  }

  Future<void> _editSession() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSessionScreen(
          userProfile: widget.userProfile,
          selectedBook: widget.book,
          editSession: widget.session,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true); // Return to sessions screen to refresh
    }
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
              widget.session.name,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              widget.book.displayName,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editSession,
            tooltip: 'Edit Session',
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
          // Session Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(int.parse(widget.session.colorCode.replaceFirst('#', '0xFF'))).withAlpha(51),
              border: Border(
                bottom: BorderSide(
                  color: Color(int.parse(widget.session.colorCode.replaceFirst('#', '0xFF'))),
                  width: 3,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_dateFormat.format(widget.session.startDate)} - ${_dateFormat.format(widget.session.endDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a day to assign readers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Days List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dayStatuses.length,
              itemBuilder: (context, index) {
                final dayStatus = _dayStatuses[index];
                final dayConfig = _dayConfigs[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: dayStatus.isDone ? 4 : 2,
                  color: dayStatus.isDone 
                      ? Colors.green.shade50.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.7),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border(
                        left: BorderSide(
                          color: dayStatus.isDone 
                              ? Colors.green 
                              : Color(int.parse(widget.session.colorCode.replaceFirst('#', '0xFF'))),
                          width: 4,
                        ),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: dayStatus.isDone 
                              ? Colors.green 
                              : Color(int.parse(widget.session.colorCode.replaceFirst('#', '0xFF'))).withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (dayStatus.isDone)
                              const Icon(Icons.check_circle, color: Colors.white, size: 24)
                            else
                              const Text(
                                'Day',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            Text(
                              '${dayStatus.dayNumber}',
                              style: TextStyle(
                                fontSize: dayStatus.isDone ? 16 : 20,
                                fontWeight: FontWeight.bold,
                                color: dayStatus.isDone ? Colors.white : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        'Day ${dayStatus.dayNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: dayStatus.isDone ? Colors.green.shade900 : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text('Limits: ${dayConfig.maxLines} lines, ${dayConfig.maxParagraphs} paragraphs'),
                          if (dayStatus.isDone) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              dayStatus.isDone ? Icons.undo : Icons.check,
                              color: dayStatus.isDone ? Colors.orange : Colors.green,
                            ),
                            onPressed: () => _toggleDayStatus(dayStatus),
                            tooltip: dayStatus.isDone ? 'Unmark as done' : 'Mark as done',
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      onTap: dayStatus.isDone
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReaderAssignmentScreen(
                                    book: widget.book,
                                    userProfile: widget.userProfile,
                                    session: widget.session,
                                    selectedDay: dayStatus.dayNumber,
                                  ),
                                ),
                              ).then((_) => _loadDayStatuses());
                            },
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
}

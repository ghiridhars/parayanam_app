import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/reading_session.dart';
import '../models/book.dart';
import '../models/user_profile.dart';
import '../services/data_service.dart';
import 'create_session_screen.dart';
import 'day_planning_screen.dart';

class SessionsScreen extends StatefulWidget {
  final UserProfile userProfile;
  final Book? selectedBook;

  const SessionsScreen({
    super.key,
    required this.userProfile,
    this.selectedBook,
  });

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final DataService _dataService = DataService();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  
  List<ReadingSession> _allSessions = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  bool _filterByDay = false; // Track if filtering by specific day or showing month view

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _dataService.getAllReadingSessions();
    setState(() {
      _allSessions = sessions;
      _isLoading = false;
    });
  }

  List<ReadingSession> _getSessionsForDay(DateTime day) {
    final sessions = _allSessions.where((session) {
      return day.isAfter(session.startDate.subtract(const Duration(days: 1))) &&
             day.isBefore(session.endDate.add(const Duration(days: 1)));
    }).toList();
    
    // Filter by selected book if specified
    if (widget.selectedBook != null) {
      return sessions.where((s) => s.bookId == widget.selectedBook!.id).toList();
    }
    
    return sessions;
  }

  List<ReadingSession> _getSessionsForMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    
    final sessions = _allSessions.where((session) {
      // Include session if it overlaps with any day in the month
      return (session.startDate.isBefore(lastDayOfMonth.add(const Duration(days: 1))) &&
              session.endDate.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))));
    }).toList();
    
    // Filter by selected book if specified
    if (widget.selectedBook != null) {
      return sessions.where((s) => s.bookId == widget.selectedBook!.id).toList();
    }
    
    // Sort by start date
    sessions.sort((a, b) => a.startDate.compareTo(b.startDate));
    
    return sessions;
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
        title: Text(widget.selectedBook != null 
            ? '${widget.selectedBook!.displayName} Sessions'
            : 'Reading Sessions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        decoration: widget.selectedBook?.backgroundImage != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.selectedBook!.backgroundImage!),
                  fit: BoxFit.cover,
                  opacity: 0.6,
                ),
              )
            : null,
        child: Column(
          children: [
            // Info message when coming from book selection
            if (widget.selectedBook != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50.withAlpha(230),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select an active session to assign readers. Create a new session if none exists.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          
          // Calendar View
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            color: Colors.white.withValues(alpha: 0.7),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: _getSessionsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _filterByDay = true; // Enable day filter when a day is clicked
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _filterByDay = false; // Reset to month view when changing months
                  _selectedDay = null;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, sessions) {
                  if (sessions.isEmpty) return null;
                  
                  final typedSessions = sessions.cast<ReadingSession>();
                  
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: typedSessions.take(3).map((session) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(int.parse(session.colorCode.replaceFirst('#', '0xFF'))),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),

          // Selected Day Sessions
          Expanded(
            child: Column(
              children: [
                // Header with view toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white.withValues(alpha: 0.7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _filterByDay && _selectedDay != null
                            ? 'Sessions on ${_dateFormat.format(_selectedDay!)}'
                            : 'All Sessions in ${_monthFormat.format(_focusedDay)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_filterByDay && _selectedDay != null)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _filterByDay = false;
                              _selectedDay = null;
                            });
                          },
                          icon: const Icon(Icons.view_list, size: 18),
                          label: const Text('Show All Month'),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                // Sessions list
                Expanded(child: _buildSessionsList()),
              ],
            ),
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateSessionScreen(
                userProfile: widget.userProfile,
                selectedBook: widget.selectedBook,
              ),
            ),
          );
          
          if (result == true) {
            _loadSessions();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
      ),
    );
  }

  Widget _buildSessionsList() {
    // Get sessions based on filter mode
    final List<ReadingSession> sessionsToShow;
    
    if (_filterByDay && _selectedDay != null) {
      // Day view: show only sessions for the selected day
      sessionsToShow = _getSessionsForDay(_selectedDay!);
    } else {
      // Month view: show all sessions in the current month
      sessionsToShow = _getSessionsForMonth(_focusedDay);
    }
    
    // Filter by selected book if specified (already done in helper methods)
    final filteredSessions = sessionsToShow;
    
    if (filteredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _filterByDay && _selectedDay != null
                  ? (widget.selectedBook != null
                      ? 'No ${widget.selectedBook!.displayName} sessions on ${_dateFormat.format(_selectedDay!)}'
                      : 'No sessions on ${_dateFormat.format(_selectedDay!)}')
                  : (widget.selectedBook != null
                      ? 'No ${widget.selectedBook!.displayName} sessions in ${_monthFormat.format(_focusedDay)}'
                      : 'No sessions in ${_monthFormat.format(_focusedDay)}'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSessions.length,
      itemBuilder: (context, index) {
        final session = filteredSessions[index];
        final book = Book.availableBooks.firstWhere((b) => b.id == session.bookId);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          color: Colors.white.withValues(alpha: 0.7),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border(
                left: BorderSide(
                  color: Color(int.parse(session.colorCode.replaceFirst('#', '0xFF'))),
                  width: 4,
                ),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                session.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.book, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(book.displayName),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${_dateFormat.format(session.startDate)} - ${_dateFormat.format(session.endDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${session.readerIds.length} readers'),
                    ],
                  ),
                ],
              ),
              trailing: _buildStatusChip(session),
              isThreeLine: true,
              onTap: () => _showSessionDetails(session, book),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(ReadingSession session) {
    String label;
    Color color;
    
    if (session.isActive()) {
      label = 'Active';
      color = Colors.green;
    } else if (session.isUpcoming()) {
      label = 'Upcoming';
      color = Colors.blue;
    } else {
      label = 'Completed';
      color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showSessionDetails(ReadingSession session, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(int.parse(session.colorCode.replaceFirst('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            book.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(session),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow(Icons.calendar_today, 'Start Date', _dateFormat.format(session.startDate)),
                _buildDetailRow(Icons.event, 'End Date', _dateFormat.format(session.endDate)),
                _buildDetailRow(Icons.people, 'Total Readers', '${session.readerIds.length}'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context); // Close modal first
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateSessionScreen(
                                userProfile: widget.userProfile,
                                selectedBook: widget.selectedBook,
                                editSession: session,
                              ),
                            ),
                          );
                          
                          if (result == true) {
                            _loadSessions();
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Session'),
                              content: const Text('Are you sure you want to delete this session? This action cannot be undone.'),
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
                            await _dataService.deleteReadingSession(session.id);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            _loadSessions();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Session deleted')),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Assign Readers button (full width)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: session.isActive()
                        ? () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DayPlanningScreen(
                                  session: session,
                                  book: book,
                                  userProfile: widget.userProfile,
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.assignment_ind),
                    label: Text(session.isActive() ? 'Assign Readers' : 'Session Not Active'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/book.dart';
import '../models/reader_category.dart';
import '../models/day_configuration.dart';
import '../services/data_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final String? selectedBookId;

  const ProfileScreen({
    super.key,
    required this.userProfile,
    this.selectedBookId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DataService _dataService = DataService();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final Map<String, List<ReaderCategory>> _bookCategories = {};
  final Map<String, List<DayConfiguration>> _bookDayConfigs = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllCategories();
  }

  Future<void> _loadAllCategories() async {
    for (var book in Book.availableBooks) {
      final categories = await _dataService.loadCategories(book.id);
      final dayConfigs = await _dataService.loadDayConfigurations(book.id, book.totalDays);
      _bookCategories[book.id] = categories;
      _bookDayConfigs[book.id] = dayConfigs;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveCategories(String bookId) async {
    final categories = _bookCategories[bookId];
    if (categories != null) {
      await _dataService.saveCategories(bookId, categories);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveDayConfigurations(String bookId) async {
    final dayConfigs = _bookDayConfigs[bookId];
    if (dayConfigs != null) {
      await _dataService.saveDayConfigurations(bookId, dayConfigs);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Day configuration saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dataService.clearUserProfile();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
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
        title: const Text('Profile & Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.userProfile.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.userProfile.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.userProfile.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Member since ${_dateFormat.format(widget.userProfile.createdAt)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

            // Category Settings for Each Book
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure reader categories and day limits for each book',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...Book.availableBooks.map((book) {
                    return _buildBookSettings(book);
                  }),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookSettings(Book book) {
    final categories = _bookCategories[book.id] ?? [];
    final dayConfigs = _bookDayConfigs[book.id] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: book.isActive ? Theme.of(context).colorScheme.primary : Colors.grey,
          child: Text(
            book.displayName[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              book.displayName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: book.isActive ? Colors.black : Colors.grey,
              ),
            ),
            if (!book.isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${book.totalDays} days',
          style: const TextStyle(fontSize: 12),
        ),
        initiallyExpanded: book.id == widget.selectedBookId && book.isActive,
        children: [
          if (book.isActive) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day Configuration Section
                  const Text(
                    'Day Configuration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set maximum lines and paragraphs that can be read each day',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...dayConfigs.map((dayConfig) {
                    return _buildDayConfigInput(book.id, dayConfig);
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _saveDayConfigurations(book.id),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Day Configuration'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const Divider(height: 32),
                  
                  // Reader Categories Section
                  const Text(
                    'Reader Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...categories.map((category) {
                    return _buildCategoryInput(book.id, category);
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _saveCategories(book.id),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Categories'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'This book is not yet available. Stay tuned!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayConfigInput(String bookId, DayConfiguration dayConfig) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${dayConfig.dayNumber}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: TextEditingController(
                text: dayConfig.maxLines.toString(),
              ),
              decoration: InputDecoration(
                labelText: 'Max Lines',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                dayConfig.maxLines = int.tryParse(value) ?? dayConfig.maxLines;
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: TextEditingController(
                text: dayConfig.maxParagraphs.toString(),
              ),
              decoration: InputDecoration(
                labelText: 'Max ¶',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixIcon: const Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                dayConfig.maxParagraphs = int.tryParse(value) ?? dayConfig.maxParagraphs;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInput(String bookId, ReaderCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getCategoryColor(category.id),
            radius: 20,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  category.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: TextEditingController(
                text: category.lineCount.toString(),
              ),
              decoration: const InputDecoration(
                labelText: 'Lines',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                category.lineCount = int.tryParse(value) ?? category.lineCount;
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: TextField(
              controller: TextEditingController(
                text: category.paragraphCount.toString(),
              ),
              decoration: const InputDecoration(
                labelText: '¶',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                category.paragraphCount = int.tryParse(value) ?? category.paragraphCount;
              },
            ),
          ),
        ],
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

import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/user_profile.dart';
import 'profile_screen.dart';
import 'sessions_screen.dart';

class BookSelectionScreen extends StatelessWidget {
  final UserProfile userProfile;

  const BookSelectionScreen({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Sessions Icon
          IconButton(
            icon: const Icon(Icons.event_note),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SessionsScreen(userProfile: userProfile),
                ),
              );
            },
            tooltip: 'Sessions',
          ),
          // Profile Icon
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userProfile.name[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userProfile: userProfile),
                  ),
                );
              },
              tooltip: 'Profile & Settings',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Select a Book',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: Book.getActiveBooks().length,
                itemBuilder: (context, index) {
                  final book = Book.getActiveBooks()[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: book.backgroundImage != null
                          ? BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(book.backgroundImage!),
                                fit: BoxFit.cover,
                                opacity: 0.3,
                              ),
                            )
                          : null,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            book.displayName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          book.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionsScreen(
                                userProfile: userProfile,
                                selectedBook: book,
                              ),
                            ),
                          );
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

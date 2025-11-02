import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('UserProfile id getter returns email', () {
      final profile = UserProfile(
        email: 'test@example.com',
        name: 'Test User',
        passwordHash: 'hash123',
        createdAt: DateTime.now(),
      );

      expect(profile.id, 'test@example.com');
      expect(profile.id, profile.email);
    });

    test('UserProfile serializes to JSON correctly', () {
      final createdAt = DateTime(2025, 11, 2, 10, 0, 0);
      final profile = UserProfile(
        email: 'john@example.com',
        name: 'John Doe',
        passwordHash: '\$2a\$12\$hashvalue',
        createdAt: createdAt,
      );

      final json = profile.toJson();

      expect(json['email'], 'john@example.com');
      expect(json['name'], 'John Doe');
      expect(json['passwordHash'], '\$2a\$12\$hashvalue');
      expect(json['createdAt'], createdAt.toIso8601String());
    });

    test('UserProfile deserializes from JSON correctly', () {
      final json = {
        'email': 'jane@example.com',
        'name': 'Jane Smith',
        'passwordHash': '\$2a\$12\$anotherhash',
        'createdAt': '2025-11-01T08:30:00.000',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.email, 'jane@example.com');
      expect(profile.name, 'Jane Smith');
      expect(profile.passwordHash, '\$2a\$12\$anotherhash');
      expect(profile.createdAt, DateTime.parse('2025-11-01T08:30:00.000'));
      expect(profile.id, 'jane@example.com');
    });

    test('UserProfile toJson and fromJson are inverse operations', () {
      final original = UserProfile(
        email: 'roundtrip@test.com',
        name: 'Round Trip User',
        passwordHash: '\$2a\$12\$testroundtrip',
        createdAt: DateTime(2025, 10, 15, 14, 30, 0),
      );

      final json = original.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.email, original.email);
      expect(restored.name, original.name);
      expect(restored.passwordHash, original.passwordHash);
      expect(restored.createdAt, original.createdAt);
      expect(restored.id, original.id);
    });

    test('UserProfile handles email as primary identifier', () {
      final profile1 = UserProfile(
        email: 'user1@test.com',
        name: 'User One',
        passwordHash: 'hash1',
        createdAt: DateTime.now(),
      );

      final profile2 = UserProfile(
        email: 'user2@test.com',
        name: 'User Two',
        passwordHash: 'hash2',
        createdAt: DateTime.now(),
      );

      expect(profile1.id, isNot(profile2.id));
      expect(profile1.id, 'user1@test.com');
      expect(profile2.id, 'user2@test.com');
    });
  });
}

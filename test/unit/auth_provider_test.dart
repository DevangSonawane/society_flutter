import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scasa_flutter_app/features/auth/providers/auth_provider.dart';
import 'package:scasa_flutter_app/features/auth/data/models/user_model.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([SupabaseClient, GoTrueClient, User])
void main() {
  group('AuthNotifier', () {
    late MockSupabaseClient mockSupabase;
    late MockGoTrueClient mockAuth;
    late ProviderContainer container;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      when(mockSupabase.auth).thenReturn(mockAuth);
      
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null', () {
      final notifier = AuthNotifier();
      expect(notifier.state, isNull);
    });

    test('isAuthenticated returns false when state is null', () {
      final notifier = AuthNotifier();
      expect(notifier.isAuthenticated, isFalse);
    });

    test('logout sets state to null', () async {
      final notifier = AuthNotifier();
      // Set a user first
      notifier.state = UserModel(
        userId: 'test-id',
        userName: 'Test User',
        email: 'test@example.com',
        mobileNumber: '1234567890',
        passwordHash: '',
        role: 'user',
        flatNo: null,
        createdAt: DateTime.now(),
      );
      
      await notifier.logout();
      expect(notifier.state, isNull);
      expect(notifier.isAuthenticated, isFalse);
    });
  });
}


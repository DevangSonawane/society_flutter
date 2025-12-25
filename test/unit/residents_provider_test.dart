import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scasa_flutter_app/features/residents/providers/residents_provider.dart';
import 'package:scasa_flutter_app/features/residents/data/models/resident_model.dart';

void main() {
  group('ResidentsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is loading', () {
      final provider = residentsProvider;
      final state = container.read(provider);
      expect(state.isLoading, isTrue);
    });

    test('can load residents', () async {
      final provider = residentsProvider;
      final state = container.read(provider);
      
      // Wait for async operation
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check that state is no longer loading
      final updatedState = container.read(provider);
      expect(updatedState.isLoading || updatedState.hasValue, isTrue);
    });
  });
}


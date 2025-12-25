import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper to create a ProviderContainer for testing
ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(
    overrides: overrides,
  );
}

/// Helper to read a provider value in tests
T readProvider<T>(ProviderContainer container, ProviderBase<T> provider) {
  return container.read(provider);
}

/// Helper to wait for async operations
Future<void> waitFor(Future<void> Function() fn) async {
  await fn();
  await Future.delayed(const Duration(milliseconds: 100));
}

/// Helper to pump and settle widgets
Future<void> pumpAndSettle(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 1));
}


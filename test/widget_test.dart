// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lunchquest/main.dart';
import 'package:lunchquest/di/injection_container.dart';
import 'package:lunchquest/features/home/presentation/viewmodels/home_viewmodel.dart';

void main() {
  setUpAll(() async {
    // Mock SharedPreferences to avoid MissingPluginException in tests
    SharedPreferences.setMockInitialValues({});

    // Initialize Supabase with mock/dummy configuration for test context
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      anonKey: 'placeholder',
    );
  });

  setUp(() {
    // Initialize GetIt dependency injection
    configureDependencies();
  });

  tearDown(() async {
    // Manually dispose HomeViewModel if registered to cancel its status timer
    if (sl.isRegistered<HomeViewModel>()) {
      try {
        sl<HomeViewModel>().dispose();
      } catch (_) {}
    }
    // Reset GetIt and dispose singletons
    await sl.reset();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LunchQuestApp());
    expect(find.byType(MaterialApp), findsOneWidget);

    // Let any pending timers/animations (like SplashScreen delayed navigation) complete
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}


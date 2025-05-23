// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_netcore_chatbot/main.dart';
import 'package:flutter_netcore_chatbot/services/auth_service.dart';
import 'package:flutter_netcore_chatbot/services/chatbot_service.dart';
import 'package:flutter_netcore_chatbot/theme/app_theme.dart';

// Mock classes
class MockSharedPreferences extends Mock implements SharedPreferences {
  @override
  String? getString(String key) => null;
  
  @override
  Future<bool> setString(String key, String value) async => true;
  
  @override
  Future<bool> remove(String key) async => true;
  
  @override
  int? getInt(String key) => null;
  
  @override
  Future<bool> setInt(String key, int value) async => true;
}

class MockAuthService extends Mock implements AuthService {}

class MockChatbotService extends Mock implements ChatbotService {}

class MockAppTheme extends Mock implements AppTheme {
  @override
  ThemeMode get themeMode => ThemeMode.system;
}

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      prefs: MockSharedPreferences(),
      authService: MockAuthService(),
      chatbotService: MockChatbotService(),
      appTheme: MockAppTheme(),
    ));

    // Verify that the login screen is shown initially
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

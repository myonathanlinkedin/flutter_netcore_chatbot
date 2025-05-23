// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_netcore_chatbot/main.dart';
import 'package:flutter_netcore_chatbot/theme/app_theme.dart';
import 'package:flutter_netcore_chatbot/services/auth_service.dart';
import 'package:flutter_netcore_chatbot/services/chatbot_service.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appTheme = AppTheme(prefs: prefs);
    final authService = AuthService();
    final chatbotService = ChatbotService();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MyApp(
        prefs: prefs,
        authService: authService,
        chatbotService: chatbotService,
        appTheme: appTheme,
      ),
    );

    // Verify that the app builds
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

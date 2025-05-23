import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/chat/chat_bloc.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'services/auth_service.dart';
import 'services/chatbot_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService();
  final chatbotService = ChatbotService();
  final appTheme = AppTheme(prefs: prefs);

  runApp(MyApp(
    prefs: prefs,
    authService: authService,
    chatbotService: chatbotService,
    appTheme: appTheme,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AuthService authService;
  final ChatbotService chatbotService;
  final AppTheme appTheme;

  const MyApp({
    super.key,
    required this.prefs,
    required this.authService,
    required this.chatbotService,
    required this.appTheme,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appTheme),
        BlocProvider(
          create: (context) => AuthBloc(
            authService: authService,
            prefs: prefs,
          ),
        ),
        BlocProvider(
          create: (context) {
            final authState = context.read<AuthBloc>().state;
            return ChatBloc(
              chatbotService: chatbotService,
              token: authState.token ?? '',
            );
          },
        ),
      ],
      child: Consumer<AppTheme>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Flutter NetCore Chatbot',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.isAuthenticated) {
                  return const ChatScreen();
                }
                return const LoginScreen();
              },
            ),
            routes: {
              '/register': (context) => const RegisterScreen(),
              '/reset-password': (context) => const ResetPasswordScreen(),
              '/change-password': (context) => const ChangePasswordScreen(),
            },
          );
        },
      ),
    );
  }
}

class ChatbotHome extends StatelessWidget {
  const ChatbotHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NetCore Chatbot'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'change_password':
                  Navigator.pushNamed(context, '/change-password');
                  break;
                case 'logout':
                  context.read<AuthBloc>().add(const AuthEvent.logout());
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'change_password',
                  child: Text('Change Password'),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to the Chatbot!'),
      ),
    );
  }
}

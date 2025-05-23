import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService();

  runApp(MyApp(
    prefs: prefs,
    authService: authService,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AuthService authService;

  const MyApp({
    super.key,
    required this.prefs,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authService: authService,
            prefs: prefs,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter NetCore Chatbot',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.isAuthenticated) {
              return const ChatbotHome();
            }
            return const LoginScreen();
          },
        ),
        routes: {
          '/register': (context) => const RegisterScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
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

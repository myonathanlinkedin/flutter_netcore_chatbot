import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../data/models/auth/auth_request.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthEvent.login(
          LoginRequest(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer<AppTheme>(
                  builder: (context, appTheme, _) {
                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                                radius: 24,
                                child: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Agent Book Online',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return Card(
                                  elevation: isDark ? 2 : 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: isDark ? Colors.white10 : Colors.black12,
                                    ),
                                  ),
                                  color: isDark ? const Color(0xFF23272F) : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'Sign in',
                                            style: theme.textTheme.headlineLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Stay updated on your appointments',
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              color: isDark ? Colors.white70 : Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          if (state.error != null)
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.red[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                state.error!,
                                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          TextFormField(
                                            controller: _emailController,
                                            keyboardType: TextInputType.emailAddress,
                                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                            decoration: InputDecoration(
                                              labelText: 'Email',
                                              labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                                              prefixIcon: Icon(Icons.email_outlined, color: isDark ? Colors.white70 : Colors.black45),
                                              filled: true,
                                              fillColor: isDark ? const Color(0xFF23272F) : Colors.grey[50],
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your email';
                                              }
                                              if (!value.contains('@')) {
                                                return 'Please enter a valid email';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          TextFormField(
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                                              prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white70 : Colors.black45),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                                  color: isDark ? Colors.white54 : Colors.black38,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscurePassword = !_obscurePassword;
                                                  });
                                                },
                                              ),
                                              filled: true,
                                              fillColor: isDark ? const Color(0xFF23272F) : Colors.grey[50],
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              if (value.length < 6) {
                                                return 'Password must be at least 6 characters';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 32),
                                          SizedBox(
                                            height: 48,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: theme.colorScheme.primary,
                                                foregroundColor: Colors.white,
                                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: state.isLoading ? null : _onLoginPressed,
                                              icon: const Icon(Icons.login_rounded),
                                              label: state.isLoading
                                                  ? const SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                    )
                                                  : const Text('Sign in'),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushNamed(context, '/register');
                                                },
                                                child: Text('Create account', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushNamed(context, '/reset-password');
                                                },
                                                child: Text('Forgot password?', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Theme toggle in top right
          Consumer<AppTheme>(
            builder: (context, appTheme, _) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              return Positioned(
                top: 24,
                right: 24,
                child: IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: isDark ? Colors.white70 : theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    appTheme.toggleTheme();
                  },
                ),
              );
            },
          ),
          // Copyright at bottom
          Consumer<AppTheme>(
            builder: (context, appTheme, _) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              return Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Developed by Mateus Yonathan',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 
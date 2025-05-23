import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:markdown/markdown.dart' as md;
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../data/models/chat/chat_message.dart';
import '../../services/chatbot_service.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_isSending) return;
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() => _isSending = true);
      context.read<ChatBloc>().add(ChatEvent.sendMessage(message));
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.select((AuthBloc bloc) => bloc.state.user);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.light 
        ? const Color(0xFFF8F9FA) 
        : const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.light 
          ? Colors.white 
          : const Color(0xFF2D2D2D),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              'Agent Book',
              style: TextStyle(
                color: theme.brightness == Brightness.light 
                  ? Colors.black 
                  : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00B37E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ONLINE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                if (user?.email?.isNotEmpty ?? false) Text(
                  user!.email!,
                  style: TextStyle(
                    color: theme.brightness == Brightness.light 
                      ? Colors.black54 
                      : Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  radius: 16,
                  child: Text(
                    user?.email?.isNotEmpty == true 
                      ? user!.email!.substring(0, 1).toUpperCase()
                      : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    theme.brightness == Brightness.light 
                      ? Icons.dark_mode_outlined 
                      : Icons.light_mode_outlined,
                  ),
                  onPressed: () {
                    final appTheme = context.read<AppTheme>();
                    appTheme.toggleTheme();
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.settings_outlined),
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
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: BlocConsumer<ChatBloc, ChatState>(
                  listener: (context, state) {
                    if (!state.isLoading && _isSending) {
                      setState(() => _isSending = false);
                    }
                    if (state.error != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(state.error!),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (!state.isLoading) {
                      _scrollToBottom();
                    }
                  },
                  builder: (context, state) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        return _ChatMessageWidget(message: message);
                      },
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light 
                    ? Colors.white 
                    : const Color(0xFF2D2D2D),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              enabled: !_isSending,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: theme.brightness == Brightness.light 
                                  ? const Color(0xFFF8F9FA) 
                                  : const Color(0xFF1A1A1A),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          BlocBuilder<ChatBloc, ChatState>(
                            builder: (context, state) {
                              return Material(
                                color: _isSending 
                                  ? theme.colorScheme.primary.withOpacity(0.5) 
                                  : theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(24),
                                child: InkWell(
                                  onTap: _isSending ? null : _sendMessage,
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: _isSending
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.light 
                          ? Colors.white 
                          : const Color(0xFF2D2D2D),
                        border: Border(
                          top: BorderSide(
                            color: theme.brightness == Brightness.light 
                              ? Colors.grey[200]! 
                              : Colors.grey[800]!,
                          ),
                        ),
                      ),
                      child: Text(
                        '© 2025 Agent Book. All rights reserved. Developed by Mateus Yonathan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Developed by Mateus Yonathan',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.brightness == Brightness.dark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageWidget({required this.message});

  bool _containsHtmlTable(String text) => text.contains('<table');
  bool _containsMarkdownTable(String text) {
    final lines = text.split('\n');
    return lines.any((l) => l.trim().startsWith('|')) && lines.any((l) => l.contains('---'));
  }

  List<List<String>> _parseMarkdownTable(String text) {
    final lines = text.trim().split('\n');
    final tableLines = lines.where((l) => l.contains('|')).toList();
    // Remove header separator (---)
    final filtered = tableLines.where((l) => !l.contains('---')).toList();
    return filtered.map((line) =>
      line.split('|').map((cell) => cell.trim()).where((cell) => cell.isNotEmpty).toList()
    ).toList();
  }

  List<List<String>> _parseHtmlTable(String html) {
    final document = html_parser.parse(html);
    final table = document.querySelector('table');
    if (table == null) return [];
    final rows = table.querySelectorAll('tr');
    return rows.map((row) {
      final cells = row.querySelectorAll('th, td');
      return cells.map((cell) => cell.text.trim()).toList();
    }).toList();
  }

  Widget _buildTable(List<List<String>> rows, BuildContext context) {
    if (rows.isEmpty) return const Text('');
    final theme = Theme.of(context);
    return Table(
      border: TableBorder.all(color: theme.dividerColor),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows.map((row) => TableRow(
        children: row.map((cell) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(cell, style: theme.textTheme.bodyMedium),
        )).toList(),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    Widget contentWidget;
    if (_containsHtmlTable(message.text)) {
      final rows = _parseHtmlTable(message.text);
      contentWidget = _buildTable(rows, context);
    } else if (_containsMarkdownTable(message.text)) {
      final rows = _parseMarkdownTable(message.text);
      contentWidget = _buildTable(rows, context);
    } else {
      contentWidget = Text(
        message.text,
        style: TextStyle(
          color: message.isUser
              ? Colors.white
              : theme.textTheme.bodyLarge?.color,
        ),
      );
    }

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isUser
              ? theme.colorScheme.primary
              : isLight
                  ? Colors.white
                  : const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: message.isUser 
                    ? Colors.white.withOpacity(0.2)
                    : theme.colorScheme.primary,
                  child: Icon(
                    message.isUser ? Icons.person : Icons.chat_bubble_outline,
                    size: 18,
                    color: message.isUser 
                      ? Colors.white 
                      : Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  message.isUser ? 'You' : 'Agent',
                  style: TextStyle(
                    color: message.isUser
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            contentWidget,
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? Colors.white.withOpacity(0.7)
                    : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
} 
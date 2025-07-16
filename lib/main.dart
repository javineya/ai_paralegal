import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const AIParalegalApp());
}

class AIParalegalApp extends StatelessWidget {
  const AIParalegalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Paralegal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const SimpleChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleChatScreen extends StatefulWidget {
  const SimpleChatScreen({super.key});

  @override
  State<SimpleChatScreen> createState() => _SimpleChatScreenState();
}

class _SimpleChatScreenState extends State<SimpleChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('chat_history');
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        setState(() {
          _messages.clear();
          _messages.addAll(
            historyList.map((item) => ChatMessage.fromJson(item)).toList(),
          );
        });
      }
    } catch (e) {
      // If loading fails, just start with empty history
      print('Failed to load chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _messages.map((message) => message.toJson()).toList(),
      );
      await prefs.setString('chat_history', historyJson);
    } catch (e) {
      print('Failed to save chat history: $e');
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text,
        isUser: true,
      ));
      
      // Add a mock AI response
      _messages.add(ChatMessage(
        text: "I'm an AI paralegal assistant. Based on your question about \"${_messageController.text}\", I can help with legal research and analysis. This is a demo version for your presentation.",
        isUser: false,
      ));
    });
    
    _messageController.clear();
    _saveChatHistory(); // Save after adding messages
  }

  Future<void> _clearHistory() async {
    setState(() {
      _messages.clear();
    });
    await _saveChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Paralegal Assistant'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.gavel,
                          size: 64,
                          color: Color(0xFF1976D2),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Welcome to AI Paralegal Assistant',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ask your legal question to get started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? const Color(0xFF1976D2)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: message.isUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask your legal question...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
    };
  }

  // Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
    );
  }
}

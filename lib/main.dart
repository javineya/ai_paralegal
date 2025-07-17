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
          seedColor: const Color(0xFF8E4EC6), // Rich purple
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF0E6), // Linen background
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFF8E4EC6), // Purple app bar
          foregroundColor: Colors.white,
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
  
  // Mock conversation history for demo
  final List<MockConversation> _mockConversations = [
    MockConversation(
      title: 'Contract Review - NDA',
      preview: 'Can you help me review this non-disclosure agreement?',
      timestamp: '2 hours ago',
    ),
    MockConversation(
      title: 'Employment Law Question',
      preview: 'What are the requirements for wrongful termination?',
      timestamp: 'Yesterday',
    ),
    MockConversation(
      title: 'Intellectual Property',
      preview: 'How do I file a trademark application?',
      timestamp: '3 days ago',
    ),
    MockConversation(
      title: 'Real Estate Dispute',
      preview: 'Tenant is refusing to pay rent, what are my options?',
      timestamp: '1 week ago',
    ),
    MockConversation(
      title: 'Corporate Formation',
      preview: 'Steps to incorporate a business in Delaware?',
      timestamp: '2 weeks ago',
    ),
  ];

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
        text: 'I\'m an AI paralegal assistant. Based on your question about "${_messageController.text}", I can help with legal research and analysis. This is a demo version for your presentation.',
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
        backgroundColor: const Color(0xFF8E4EC6), // Purple
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
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Color(0xFFF8F5F0), // Slightly darker linen for sidebar
              border: Border(
                right: BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // New Chat Button
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _clearHistory,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E4EC6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                // Chat History Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Conversations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                // Mock Conversation List
                Expanded(
                  child: ListView.builder(
                    itemCount: _mockConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _mockConversations[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,
                        ),
                        child: ListTile(
                          title: Text(
                            conversation.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D2D2D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conversation.preview,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                conversation.timestamp,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Mock conversation selection - could load different conversations
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Loading: ${conversation.title}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Chat Area
          Expanded(
            child: Column(
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
                                color: Color(0xFF8E4EC6), // Purple icon
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
                                      ? const Color(0xFF8E4EC6) // Purple for user messages
                                      : const Color(0xFFF5F5DC), // Beige for AI messages
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message.text,
                                  style: TextStyle(
                                    color: message.isUser ? Colors.white : const Color(0xFF4A4A4A), // Dark gray text for AI messages
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
                    color: const Color(0xFFFFFAF0), // Softer cream background
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
                          backgroundColor: const Color(0xFF8E4EC6), // Purple send button
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
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

class MockConversation {
  final String title;
  final String preview;
  final String timestamp;

  MockConversation({
    required this.title,
    required this.preview,
    required this.timestamp,
  });
}

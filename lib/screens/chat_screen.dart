import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../services/conversation_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/sidebar.dart';
import '../widgets/search_bar.dart' as custom;
import '../utils/app_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  final ConversationService _conversationService = ConversationService();
  
  bool _isLoading = false;
  bool _isSidebarVisible = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final conversations = await _conversationService.getConversations();
    appState.setConversations(conversations);
    
    if (conversations.isNotEmpty && appState.currentConversation == null) {
      appState.setCurrentConversation(conversations.first);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final userMessageText = _messageController.text.trim();
    final appState = Provider.of<AppState>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Create user message
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: userMessageText,
        isUser: true,
        timestamp: DateTime.now(),
      );

      // Create or update conversation
      Conversation conversation;
      if (appState.currentConversation == null) {
        // Create new conversation
        conversation = Conversation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _conversationService.generateConversationTitle(userMessageText),
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
          messages: [userMessage],
        );
      } else {
        // Add to existing conversation
        final updatedMessages = [...appState.currentConversation!.messages, userMessage];
        conversation = appState.currentConversation!.copyWith(
          messages: updatedMessages,
          lastUpdated: DateTime.now(),
        );
      }

      // Update UI immediately with user message
      appState.setCurrentConversation(conversation);
      await _conversationService.saveConversation(conversation);
      
      _messageController.clear();
      _scrollToBottom();

      // Get AI response
      final aiMessage = await _aiService.sendMessage(userMessageText);
      
      // Add AI response to conversation
      final finalMessages = [...conversation.messages, aiMessage];
      final finalConversation = conversation.copyWith(
        messages: finalMessages,
        lastUpdated: DateTime.now(),
      );

      appState.setCurrentConversation(finalConversation);
      await _conversationService.saveConversation(finalConversation);
      
      // Refresh conversations list
      await _loadConversations();
      
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: Row(
            children: [
              // Sidebar
              if (_isSidebarVisible)
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: Sidebar(
                    conversations: appState.conversations,
                    currentConversation: appState.currentConversation,
                    onConversationSelected: (conversation) {
                      appState.setCurrentConversation(conversation);
                    },
                    onNewConversation: () {
                      appState.setCurrentConversation(null);
                    },
                    onDeleteConversation: (conversationId) async {
                      await _conversationService.deleteConversation(conversationId);
                      await _loadConversations();
                      if (appState.currentConversation?.id == conversationId) {
                        appState.setCurrentConversation(null);
                      }
                    },
                  ),
                ),
              
              // Main chat area
              Expanded(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Sidebar toggle
                          IconButton(
                            icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
                            onPressed: _toggleSidebar,
                          ),
                          
                          // Company logo placeholder
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),                  child: const Icon(
                    Icons.gavel,
                    color: Colors.white,
                    size: 24,
                  ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Paralegal Assistant',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  appState.currentConversation?.title ?? 'New Conversation',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Search button
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              showSearch(
                                context: context,
                                delegate: custom.ConversationSearchDelegate(
                                  conversations: appState.conversations,
                                  onConversationSelected: (conversation) {
                                    appState.setCurrentConversation(conversation);
                                  },
                                ),
                              );
                            },
                          ),
                          
                          // More options
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              switch (value) {
                                case 'export':
                                  _showExportDialog();
                                  break;
                                case 'settings':
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'export',
                                child: Row(
                                  children: [
                                    Icon(Icons.download),
                                    SizedBox(width: 8),
                                    Text('Export Conversation'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    Icon(Icons.settings),
                                    SizedBox(width: 8),
                                    Text('Settings'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Messages
                    Expanded(
                      child: appState.currentConversation == null || 
                              appState.currentConversation!.messages.isEmpty
                          ? _buildWelcomeScreen()
                          : _buildMessagesList(appState.currentConversation!.messages),
                    ),
                    
                    // Input area
                    _buildInputArea(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.gavel,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to AI Paralegal Assistant',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ask legal questions and get detailed responses with case citations',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Contract law question'),
              _buildSuggestionChip('Property dispute'),
              _buildSuggestionChip('Negligence case'),
              _buildSuggestionChip('Employment issue'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
    );
  }

  Widget _buildMessagesList(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= messages.length) {
          // Loading indicator
          return MessageBubble.loading();
        }
        
        final message = messages[index];
        return MessageBubble(
          message: message,
          isUser: message.isUser,
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask your legal question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isLoading,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isLoading ? null : _sendMessage,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Conversation'),
        content: const Text('Export functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

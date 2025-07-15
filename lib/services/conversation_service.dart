import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ConversationService {
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  static const String _conversationsKey = 'conversations';
  static const String _currentConversationKey = 'current_conversation_id';

  Future<List<Conversation>> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getStringList(_conversationsKey) ?? [];
    
    return conversationsJson
        .map((jsonStr) => Conversation.fromJson(jsonDecode(jsonStr)))
        .toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
  }

  Future<void> saveConversation(Conversation conversation) async {
    final prefs = await SharedPreferences.getInstance();
    final conversations = await getConversations();
    
    final existingIndex = conversations.indexWhere((c) => c.id == conversation.id);
    if (existingIndex != -1) {
      conversations[existingIndex] = conversation;
    } else {
      conversations.insert(0, conversation);
    }

    final conversationsJson = conversations
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    
    await prefs.setStringList(_conversationsKey, conversationsJson);
  }

  Future<void> deleteConversation(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final conversations = await getConversations();
    
    conversations.removeWhere((c) => c.id == conversationId);
    
    final conversationsJson = conversations
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    
    await prefs.setStringList(_conversationsKey, conversationsJson);
  }

  Future<Conversation?> getCurrentConversation() async {
    final prefs = await SharedPreferences.getInstance();
    final currentId = prefs.getString(_currentConversationKey);
    
    if (currentId == null) return null;
    
    final conversations = await getConversations();
    return conversations.firstWhere(
      (c) => c.id == currentId,
      orElse: () => throw StateError('Current conversation not found'),
    );
  }

  Future<void> setCurrentConversation(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentConversationKey, conversationId);
  }

  Future<List<Conversation>> searchConversations(String query) async {
    final conversations = await getConversations();
    final lowercaseQuery = query.toLowerCase();
    
    return conversations.where((conversation) {
      // Search in title
      if (conversation.title.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }
      
      // Search in message content
      return conversation.messages.any((message) =>
          message.content.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  Future<List<Message>> searchCurrentConversation(String conversationId, String query) async {
    final conversations = await getConversations();
    final conversation = conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => throw StateError('Conversation not found'),
    );
    
    final lowercaseQuery = query.toLowerCase();
    return conversation.messages.where((message) =>
        message.content.toLowerCase().contains(lowercaseQuery)).toList();
  }

  Future<void> updateConversationTitle(String conversationId, String newTitle) async {
    final conversations = await getConversations();
    final index = conversations.indexWhere((c) => c.id == conversationId);
    
    if (index != -1) {
      final updatedConversation = conversations[index].copyWith(
        title: newTitle,
        lastUpdated: DateTime.now(),
      );
      await saveConversation(updatedConversation);
    }
  }

  Future<void> updateConversationCategory(String conversationId, String? category) async {
    final conversations = await getConversations();
    final index = conversations.indexWhere((c) => c.id == conversationId);
    
    if (index != -1) {
      final updatedConversation = conversations[index].copyWith(
        category: category,
        lastUpdated: DateTime.now(),
      );
      await saveConversation(updatedConversation);
    }
  }

  Future<void> addTagToConversation(String conversationId, String tag) async {
    final conversations = await getConversations();
    final index = conversations.indexWhere((c) => c.id == conversationId);
    
    if (index != -1) {
      final currentTags = List<String>.from(conversations[index].tags);
      if (!currentTags.contains(tag)) {
        currentTags.add(tag);
        final updatedConversation = conversations[index].copyWith(
          tags: currentTags,
          lastUpdated: DateTime.now(),
        );
        await saveConversation(updatedConversation);
      }
    }
  }

  String generateConversationTitle(String firstMessage) {
    // Extract key legal terms to create a meaningful title
    final legalTerms = [
      'contract', 'tort', 'negligence', 'property', 'criminal', 'constitutional',
      'employment', 'family', 'corporate', 'intellectual property', 'litigation',
      'settlement', 'damages', 'liability', 'breach', 'statute', 'regulation'
    ];
    
    final words = firstMessage.toLowerCase().split(' ');
    final foundTerms = words.where((word) => 
        legalTerms.any((term) => word.contains(term))).toList();
    
    if (foundTerms.isNotEmpty) {
      final mainTerm = foundTerms.first;
      return '${mainTerm.substring(0, 1).toUpperCase()}${mainTerm.substring(1)} Question';
    }
    
    // Fallback to first few words
    final firstWords = words.take(4).join(' ');
    if (firstWords.length > 30) {
      return '${firstWords.substring(0, 27)}...';
    }
    return firstWords.isEmpty ? 'New Conversation' : firstWords;
  }

  // TODO: Cloud storage integration
  /*
  Future<void> syncToCloud() async {
    // Implementation for syncing conversations to cloud storage
    // This would integrate with your backend API
    try {
      final conversations = await getConversations();
      final response = await http.post(
        Uri.parse('YOUR_SYNC_ENDPOINT'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'conversations': conversations.map((c) => c.toJson()).toList(),
        }),
      );
      
      if (response.statusCode == 200) {
        // Handle successful sync
      }
    } catch (e) {
      // Handle sync errors
    }
  }

  Future<void> syncFromCloud() async {
    // Implementation for downloading conversations from cloud
    try {
      final response = await http.get(
        Uri.parse('YOUR_SYNC_ENDPOINT'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cloudConversations = (data['conversations'] as List)
            .map((c) => Conversation.fromJson(c))
            .toList();
        
        // Merge with local conversations
        for (final conversation in cloudConversations) {
          await saveConversation(conversation);
        }
      }
    } catch (e) {
      // Handle sync errors
    }
  }
  */
}

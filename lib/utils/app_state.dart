import 'package:flutter/foundation.dart';
import '../models/conversation.dart';

class AppState extends ChangeNotifier {
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  String _searchQuery = '';
  bool _isDarkMode = false;

  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  String get searchQuery => _searchQuery;
  bool get isDarkMode => _isDarkMode;

  void setConversations(List<Conversation> conversations) {
    _conversations = conversations;
    notifyListeners();
  }

  void setCurrentConversation(Conversation? conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }

  void addConversation(Conversation conversation) {
    _conversations.insert(0, conversation);
    notifyListeners();
  }

  void updateConversation(Conversation conversation) {
    final index = _conversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1) {
      _conversations[index] = conversation;
      if (_currentConversation?.id == conversation.id) {
        _currentConversation = conversation;
      }
      notifyListeners();
    }
  }

  void removeConversation(String conversationId) {
    _conversations.removeWhere((c) => c.id == conversationId);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = null;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  List<Conversation> get filteredConversations {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }
    
    final query = _searchQuery.toLowerCase();
    return _conversations.where((conversation) {
      return conversation.title.toLowerCase().contains(query) ||
             conversation.messages.any((message) => 
                 message.content.toLowerCase().contains(query));
    }).toList();
  }
}

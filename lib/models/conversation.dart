import 'message.dart';

class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final List<Message> messages;
  final String? category;
  final List<String> tags;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastUpdated,
    required this.messages,
    this.category,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'category': category,
      'tags': tags,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      messages: (json['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList(),
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastUpdated,
    List<Message>? messages,
    String? category,
    List<String>? tags,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      messages: messages ?? this.messages,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }
}

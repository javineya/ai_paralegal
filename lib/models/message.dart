class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<LegalCitation>? citations;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.citations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'citations': citations?.map((c) => c.toJson()).toList(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      citations: json['citations'] != null
          ? (json['citations'] as List)
              .map((c) => LegalCitation.fromJson(c))
              .toList()
          : null,
    );
  }
}

class LegalCitation {
  final String caseTitle;
  final String citation;
  final String court;
  final String year;
  final String? summary;
  final CitationType type;

  LegalCitation({
    required this.caseTitle,
    required this.citation,
    required this.court,
    required this.year,
    this.summary,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'caseTitle': caseTitle,
      'citation': citation,
      'court': court,
      'year': year,
      'summary': summary,
      'type': type.toString(),
    };
  }

  factory LegalCitation.fromJson(Map<String, dynamic> json) {
    return LegalCitation(
      caseTitle: json['caseTitle'],
      citation: json['citation'],
      court: json['court'],
      year: json['year'],
      summary: json['summary'],
      type: CitationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => CitationType.caselaw,
      ),
    );
  }

  String get formattedCitation {
    switch (type) {
      case CitationType.caselaw:
        return '$caseTitle, $citation ($court $year)';
      case CitationType.statute:
        return '$citation ($year)';
      case CitationType.regulation:
        return '$citation ($year)';
      case CitationType.secondary:
        return '$caseTitle, $citation ($year)';
    }
  }
}

enum CitationType {
  caselaw,
  statute,
  regulation,
  secondary,
}

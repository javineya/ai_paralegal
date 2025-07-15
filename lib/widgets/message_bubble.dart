import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  MessageBubble.loading({super.key})
      : message = _LoadingMessage(),
        isUser = false;

  @override
  Widget build(BuildContext context) {
    if (message is _LoadingMessage) {
      return _buildLoadingBubble(context);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(context, isUser: false),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message header
                Row(
                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Text(
                      isUser ? 'You' : 'AI Assistant',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Message bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      topLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      topRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    border: isUser ? null : Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: SelectableText(
                    message.content,
                    style: TextStyle(
                      color: isUser 
                          ? Colors.white 
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.4,
                    ),
                  ),
                ),
                
                // Citations
                if (!isUser && message.citations != null && message.citations!.isNotEmpty)
                  _buildCitations(context),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildAvatar(context, isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, {required bool isUser}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isUser 
            ? Theme.of(context).primaryColor 
            : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.gavel,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildCitations(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.library_books,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                'Legal Citations',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...message.citations!.map((citation) => _buildCitation(context, citation)),
        ],
      ),
    );
  }

  Widget _buildCitation(BuildContext context, LegalCitation citation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            citation.formattedCitation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (citation.summary != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SelectableText(
                citation.summary!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color != null 
                      ? Color.fromRGBO(
                          Theme.of(context).textTheme.bodySmall!.color!.red,
                          Theme.of(context).textTheme.bodySmall!.color!.green,
                          Theme.of(context).textTheme.bodySmall!.color!.blue,
                          0.7,
                        )
                      : null,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          _buildCitationTypeBadge(context, citation.type),
        ],
      ),
    );
  }

  Widget _buildCitationTypeBadge(BuildContext context, CitationType type) {
    Color color;
    String label;
    
    switch (type) {
      case CitationType.caselaw:
        color = Colors.blue;
        label = 'Case Law';
        break;
      case CitationType.statute:
        color = Colors.green;
        label = 'Statute';
        break;
      case CitationType.regulation:
        color = Colors.orange;
        label = 'Regulation';
        break;
      case CitationType.secondary:
        color = Colors.purple;
        label = 'Secondary';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoadingBubble(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(context, isUser: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      topLeft: const Radius.circular(4),
                    ),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Analyzing your question...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
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

class _LoadingMessage extends Message {
  _LoadingMessage()
      : super(
          id: 'loading',
          content: '',
          isUser: false,
          timestamp: _LoadingDateTime(),
        );
}

class _LoadingDateTime extends DateTime {
  _LoadingDateTime() : super(0);
}

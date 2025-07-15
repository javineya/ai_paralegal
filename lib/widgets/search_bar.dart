import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ConversationSearchDelegate extends SearchDelegate<Conversation?> {
  final List<Conversation> conversations;
  final Function(Conversation) onConversationSelected;

  ConversationSearchDelegate({
    required this.conversations,
    required this.onConversationSelected,
  });

  @override
  String get searchFieldLabel => 'Search conversations and messages...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter search terms to find conversations'),
      );
    }

    final results = _searchConversations(query);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for \'$query\'',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or check spelling',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildSearchResultItem(context, result);
      },
    );
  }

  Widget _buildSearchResultItem(BuildContext context, SearchResult result) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(
          Icons.chat_bubble_outline,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        result.conversation.title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.matchingMessage != null) ...[
            Text(
              _highlightSearchTerm(result.matchingMessage!.content, query),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(result.conversation.lastUpdated),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
              const Spacer(),
              Text(
                '${result.conversation.messages.length} messages',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: result.matchCount > 1
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${result.matchCount} matches',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      onTap: () {
        onConversationSelected(result.conversation);
        close(context, result.conversation);
      },
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    // Show recent conversations or popular categories
    final recentConversations = conversations.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Recent Conversations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recentConversations.length,
            itemBuilder: (context, index) {
              final conversation = recentConversations[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.history,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(conversation.title),
                subtitle: Text(
                  _formatDate(conversation.lastUpdated),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  query = conversation.title;
                  onConversationSelected(conversation);
                  close(context, conversation);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<SearchResult> _searchConversations(String searchQuery) {
    final results = <SearchResult>[];
    final lowercaseQuery = searchQuery.toLowerCase();

    for (final conversation in conversations) {
      int matchCount = 0;
      String? matchingMessageContent;

      // Check title
      if (conversation.title.toLowerCase().contains(lowercaseQuery)) {
        matchCount++;
      }

      // Check messages
      for (final message in conversation.messages) {
        if (message.content.toLowerCase().contains(lowercaseQuery)) {
          matchCount++;
          matchingMessageContent ??= message.content;
        }
      }

      // Check category
      if (conversation.category?.toLowerCase().contains(lowercaseQuery) == true) {
        matchCount++;
      }

      // Check tags
      for (final tag in conversation.tags) {
        if (tag.toLowerCase().contains(lowercaseQuery)) {
          matchCount++;
        }
      }

      if (matchCount > 0) {
        results.add(SearchResult(
          conversation: conversation,
          matchCount: matchCount,
          matchingMessage: matchingMessageContent != null
              ? conversation.messages.firstWhere(
                  (m) => m.content.toLowerCase().contains(lowercaseQuery),
                )
              : null,
        ));
      }
    }

    // Sort by relevance (match count) and then by date
    results.sort((a, b) {
      final matchComparison = b.matchCount.compareTo(a.matchCount);
      if (matchComparison != 0) return matchComparison;
      return b.conversation.lastUpdated.compareTo(a.conversation.lastUpdated);
    });

    return results;
  }

  String _highlightSearchTerm(String text, String searchTerm) {
    // For now, just return the text. In a real implementation,
    // you might want to use RichText to highlight the search terms
    return text;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}

class SearchResult {
  final Conversation conversation;
  final int matchCount;
  final Message? matchingMessage;

  SearchResult({
    required this.conversation,
    required this.matchCount,
    this.matchingMessage,
  });
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/conversation.dart';

class Sidebar extends StatefulWidget {
  final List<Conversation> conversations;
  final Conversation? currentConversation;
  final Function(Conversation) onConversationSelected;
  final VoidCallback onNewConversation;
  final Function(String) onDeleteConversation;

  const Sidebar({
    super.key,
    required this.conversations,
    required this.currentConversation,
    required this.onConversationSelected,
    required this.onNewConversation,
    required this.onDeleteConversation,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Set<String> _selectedTags = {};

  List<Conversation> get filteredConversations {
    var filtered = widget.conversations;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((conversation) {
        return conversation.title.toLowerCase().contains(query) ||
               conversation.messages.any((message) => 
                   message.content.toLowerCase().contains(query));
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((conversation) => 
          conversation.category == _selectedCategory).toList();
    }

    // Filter by tags
    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((conversation) =>
          _selectedTags.any((tag) => conversation.tags.contains(tag))).toList();
    }

    return filtered;
  }

  Set<String> get availableCategories {
    final categories = {'All'};
    for (final conversation in widget.conversations) {
      if (conversation.category != null) {
        categories.add(conversation.category!);
      }
    }
    return categories;
  }

  Set<String> get availableTags {
    final tags = <String>{};
    for (final conversation in widget.conversations) {
      tags.addAll(conversation.tags);
    }
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Search
          _buildSearch(),
          
          // Filters
          if (availableCategories.length > 1 || availableTags.isNotEmpty)
            _buildFilters(),
          
          // Conversations list
          Expanded(
            child: _buildConversationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          Expanded(
            child: Text(
              'Conversations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: widget.onNewConversation,
            tooltip: 'New Conversation',
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter
          if (availableCategories.length > 1) ...[
            Text(
              'Category',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: availableCategories.map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Tags filter
          if (availableTags.isNotEmpty) ...[
            Text(
              'Tags',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color != null 
                    ? Color.fromRGBO(
                        Theme.of(context).textTheme.bodySmall!.color!.red,
                        Theme.of(context).textTheme.bodySmall!.color!.green,
                        Theme.of(context).textTheme.bodySmall!.color!.blue,
                        0.7,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    final conversations = filteredConversations;
    
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'No conversations found'
                  : 'No conversations yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Start a new conversation',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final isSelected = widget.currentConversation?.id == conversation.id;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => widget.onConversationSelected(conversation),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and menu
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected 
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            size: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'rename':
                                _showRenameDialog(conversation);
                                break;
                              case 'delete':
                                _showDeleteDialog(conversation);
                                break;
                              case 'export':
                                // TODO: Implement export
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Rename'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'export',
                              child: Row(
                                children: [
                                  Icon(Icons.download, size: 16),
                                  SizedBox(width: 8),
                                  Text('Export'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Last message preview
                    if (conversation.messages.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        conversation.messages.last.content,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Metadata
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(conversation.lastUpdated),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${conversation.messages.length} messages',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    
                    // Tags
                    if (conversation.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: conversation.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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

  void _showRenameDialog(Conversation conversation) {
    final controller = TextEditingController(text: conversation.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement rename functionality
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Conversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text('Are you sure you want to delete \'${conversation.title}\'?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteConversation(conversation.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/navigation_service.dart';
import '../../theme/adaptive_colors.dart';

import '../../widget/newnotifitem.dart';
import '../../widget/responsive_navigation_scaffold.dart';
import '../../widget/user_profile_header.dart';
import '../../widget/translate_text.dart';
import '../../provider/notification_provider.dart';
import '../../models/notification_model.dart';

class EnhancedNotificationsScreen extends StatefulWidget {
  const EnhancedNotificationsScreen({super.key});

  @override
  State<EnhancedNotificationsScreen> createState() => _EnhancedNotificationsScreenState();
}

class _EnhancedNotificationsScreenState extends State<EnhancedNotificationsScreen> {
  int _selectedIndex = 0;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();

  // Filter state
  String? _selectedTypeFilter;
  bool? _selectedSeenFilter;
  bool _showFilters = false;

  // Notification types for filtering
  final List<String> _notificationTypes = ['info', 'success', 'warning', 'error'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 0;
    });

    // Load more notifications when reaching bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().loadMoreNotifications();
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
  }

  Future<void> _handleRefresh() async {
    await context.read<NotificationProvider>().refresh();
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read if not already read
    if (!notification.seen) {
      context.read<NotificationProvider>().toggleNotificationStatus(notification.id);
    }

    // Handle navigation if actionUrl is provided
    if (notification.actionUrl != null) {
      // Implement navigation logic based on actionUrl
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigate to: ${notification.actionUrl}'),
          backgroundColor: AdaptiveColors.primaryGreen,
        ),
      );
    } else {
      // Show notification details
      _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AdaptiveColors.cardColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AdaptiveColors.primaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.formattedTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: AdaptiveColors.secondaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 16,
                          color: AdaptiveColors.primaryTextColor(context),
                        ),
                      ),
                      if (notification.metadata != null && notification.metadata!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Additional Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...notification.metadata!.entries.map((entry) =>
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key}: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AdaptiveColors.primaryTextColor(context),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value.toString(),
                                      style: TextStyle(
                                        color: AdaptiveColors.secondaryTextColor(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMarkAllAsRead() {
    context.read<NotificationProvider>().markAllAsRead().then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All notifications marked as read'),
            backgroundColor: AdaptiveColors.primaryGreen,
          ),
        );
      }
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
            const SizedBox(height: 16),

            // Type filter
            Text(
              'Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedTypeFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTypeFilter = null;
                    });
                    context.read<NotificationProvider>().filterByType(null);
                    Navigator.pop(context);
                  },
                ),
                ..._notificationTypes.map((type) => FilterChip(
                  label: Text(type.toUpperCase()),
                  selected: _selectedTypeFilter == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTypeFilter = selected ? type : null;
                    });
                    context.read<NotificationProvider>().filterByType(
                        selected ? type : null
                    );
                    Navigator.pop(context);
                  },
                )),
              ],
            ),

            const SizedBox(height: 16),

            // Read status filter
            Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedSeenFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSeenFilter = null;
                    });
                    context.read<NotificationProvider>().filterBySeen(null);
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Unread'),
                  selected: _selectedSeenFilter == false,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSeenFilter = selected ? false : null;
                    });
                    context.read<NotificationProvider>().filterBySeen(
                        selected ? false : null
                    );
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Read'),
                  selected: _selectedSeenFilter == true,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSeenFilter = selected ? true : null;
                    });
                    context.read<NotificationProvider>().filterBySeen(
                        selected ? true : null
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Clear filters button
            if (_selectedTypeFilter != null || _selectedSeenFilter != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTypeFilter = null;
                      _selectedSeenFilter = null;
                    });
                    context.read<NotificationProvider>().clearFilters();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdaptiveColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear Filters'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.03,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslateText(
                    "notifications",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                  ),
                  Text(
                    "${provider.totalElements} notifications",
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Filter button
                  IconButton(
                    onPressed: _showFilterOptions,
                    icon: Icon(
                      Icons.filter_list,
                      color: (_selectedTypeFilter != null || _selectedSeenFilter != null)
                          ? AdaptiveColors.primaryGreen
                          : AdaptiveColors.secondaryTextColor(context),
                    ),
                  ),

                  // Mark all as read button
                  if (provider.unreadCount > 0)
                    TextButton(
                      onPressed: _handleMarkAllAsRead,
                      style: TextButton.styleFrom(
                        foregroundColor: AdaptiveColors.primaryGreen,
                      ),
                      child: Text(
                        "Mark all as read",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: screenWidth * 0.15,
            color: AdaptiveColors.isDarkMode(context)
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
          SizedBox(height: screenWidth * 0.04),
          TranslateText(
            "noNotifications",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: AdaptiveColors.primaryTextColor(context),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          TranslateText(
            "allCaughtUp",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: screenWidth * 0.15,
            color: Colors.red,
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            'Error loading notifications',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: AdaptiveColors.primaryTextColor(context),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            error,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenWidth * 0.04),
          ElevatedButton(
            onPressed: _handleRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdaptiveColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SafeArea(
        child: Column(
          children: [
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {
                // Already on notifications screen
              },
            ),

            // Content
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && !provider.hasLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error.isNotEmpty && !provider.hasLoaded) {
                    return _buildErrorState(provider.error);
                  }

                  if (provider.notifications.isEmpty && provider.hasLoaded) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildPageHeader(),
                        ),
                        SliverToBoxAdapter(
                          child: Divider(
                            color: AdaptiveColors.dividerColor(context),
                            height: 1,
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              if (index < provider.notifications.length) {
                                final notification = provider.notifications[index];
                                return EnhancedNotificationItem(
                                  notification: notification,
                                  onTap: () => _handleNotificationTap(notification),
                                  onToggleRead: () => provider.toggleNotificationStatus(notification.id),
                                );
                              } else if (provider.hasMoreData && provider.isLoading) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return null;
                            },
                            childCount: provider.notifications.length +
                                (provider.hasMoreData && provider.isLoading ? 1 : 0),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
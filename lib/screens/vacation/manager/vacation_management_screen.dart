// lib/screens/vacation/manager/vacation_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/vacation_model.dart';
import '../../../models/vacation_balance_model.dart';
import '../../../services/vacation_service.dart';
import '../../../theme/adaptive_colors.dart';
import '../../../widget/responsive_navigation_scaffold.dart';
import '../../../widget/user_profile_header.dart';
import '../../../widget/bottom_navigation_bar.dart';
import 'employee_request_card.dart';

class VacationManagementScreen extends StatefulWidget {
  const VacationManagementScreen({super.key});

  @override
  State<VacationManagementScreen> createState() => _VacationManagementScreenState();
}

class _VacationManagementScreenState extends State<VacationManagementScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  final VacationService _vacationService = VacationService();
  List<VacationRequest> _allRequests = [];
  List<VacationRequest> _pendingRequests = [];
  List<VacationRequest> _processedRequests = [];
  bool _isLoading = true;
  String _error = '';
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 0;
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await _vacationService.getEmployeeRequests();
      if (result['success']) {
        _allRequests = result['requests'];
        _filterRequests();
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Error loading data: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterRequests() {
    _pendingRequests = _allRequests
        .where((r) => r.status == VacationStatus.pending)
        .toList();

    _processedRequests = _allRequests
        .where((r) => r.status != VacationStatus.pending)
        .toList();

    // Sort by date
    _pendingRequests.sort((a, b) => a.startDate.compareTo(b.startDate));
    _processedRequests.sort((a, b) => b.updatedAt?.compareTo(a.updatedAt ?? DateTime.now()) ?? 0);
  }

  Future<void> _handleRequestAction(VacationRequest request, String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action == VacationStatus.approved ? 'Approve' : 'Reject'} Request'),
        content: Text(
          'Are you sure you want to ${action == VacationStatus.approved ? 'approve' : 'reject'} '
              '${request.userName}\'s vacation request for ${request.numberOfDays} days?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == VacationStatus.approved
                  ? Colors.green
                  : Colors.red,
            ),
            child: Text(action == VacationStatus.approved ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _vacationService.manageRequest(request.id!, action);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEmployeeBalance(int userId, String userName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await _vacationService.getEmployeeBalance(userId);
    Navigator.pop(context); // Close loading

    if (result['success']) {
      final balance = result['balance'] as VacationBalance;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('$userName\'s Balance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBalanceRow('Total Days', balance.totalDays),
              _buildBalanceRow('Used Days', balance.usedDays),
              _buildBalanceRow('Available Days', balance.availableDays),
              _buildBalanceRow('Pending Days', balance.pendingDays),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load balance: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBalanceRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} days',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: (index) {
        // Handle navigation
      },
      body: SafeArea(
        child: Column(
          children: [
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
            ),

            // Header
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vacation Management',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                  ),
                  // Filter dropdown
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenWidth * 0.01,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AdaptiveColors.borderColor(context)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _filterType,
                      underline: const SizedBox(),
                      isDense: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Types')),
                        DropdownMenuItem(value: VacationType.annualLeave, child: Text('Annual Leave')),
                        DropdownMenuItem(value: VacationType.sickLeave, child: Text('Sick Leave')),
                        DropdownMenuItem(value: VacationType.personalLeave, child: Text('Personal Leave')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: AdaptiveColors.primaryGreen,
              unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
              indicatorColor: AdaptiveColors.primaryGreen,
              tabs: [
                Tab(text: 'Pending (${_pendingRequests.length})'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
                  : TabBarView(
                controller: _tabController,
                children: [
                  // Pending
                  _buildRequestsList(
                    _pendingRequests.where((r) =>
                    _filterType == 'all' || r.type == _filterType
                    ).toList(),
                    true,
                  ),
                  // Approved
                  _buildRequestsList(
                    _processedRequests.where((r) =>
                    r.status == VacationStatus.approved &&
                        (_filterType == 'all' || r.type == _filterType)
                    ).toList(),
                    false,
                  ),
                  // Rejected
                  _buildRequestsList(
                    _processedRequests.where((r) =>
                    r.status == VacationStatus.rejected &&
                        (_filterType == 'all' || r.type == _filterType)
                    ).toList(),
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildRequestsList(List<VacationRequest> requests, bool showActions) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.beach_access,
              size: 48,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No requests to display',
              style: TextStyle(
                color: AdaptiveColors.secondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return EmployeeRequestCard(
          request: request,
          onApprove: showActions
              ? () => _handleRequestAction(request, VacationStatus.approved)
              : null,
          onReject: showActions
              ? () => _handleRequestAction(request, VacationStatus.rejected)
              : null,
          onViewBalance: request.userId != null
              ? () => _showEmployeeBalance(request.userId!, request.userName ?? 'Employee')
              : null,
        );
      },
    );
  }
}
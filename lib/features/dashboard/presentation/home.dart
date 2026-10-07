import 'package:dio/dio.dart';
import 'package:fire_evacuation_app/core/fire_evacuation_api.dart';
import 'package:fire_evacuation_app/core/supabase_service.dart';
import 'package:fire_evacuation_app/features/dashboard/data/dashboard_snapshot.dart';
import 'package:fire_evacuation_app/features/dashboard/presentation/widgets/dashboard_overview.dart';
import 'package:fire_evacuation_app/features/dashboard/presentation/widgets/dashboard_sidebar.dart';
import 'package:fire_evacuation_app/features/dashboard/presentation/widgets/dashboard_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _api = FireEvacuationApi();
  int _selectedSection = 0;
  DashboardSnapshot? _snapshot;
  Map<String, dynamic>? _apiStatus;
  String? _databaseError;
  String? _apiError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _databaseError = null;
      _apiError = null;
    });
    await Future.wait([_loadDashboardData(), _loadApiStatus()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadDashboardData() async {
    try {
      final snapshot = await DashboardSnapshot.load();
      if (mounted) setState(() => _snapshot = snapshot);
    } on PostgrestException catch (error) {
      if (mounted) setState(() => _databaseError = error.message);
    } on Exception catch (error) {
      if (mounted) setState(() => _databaseError = error.toString());
    }
  }

  Future<void> _loadApiStatus() async {
    try {
      final status = await _api.getStatus();
      if (mounted) setState(() => _apiStatus = status);
    } on DioException catch (error) {
      if (mounted) {
        setState(
          () => _apiError = error.message ?? 'The fire server did not respond.',
        );
      }
    } on FormatException catch (error) {
      if (mounted) setState(() => _apiError = error.message);
    }
  }

  Future<void> _signOut() async {
    try {
      await SupabaseService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } on AuthException catch (error) {
      _showError(error.message);
    } on Exception catch (error) {
      _showError(error.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to sign out: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 850;
        return Scaffold(
          drawer: isWide
              ? null
              : Drawer(
                  child: SafeArea(
                    child: DashboardSidebar(
                      selectedIndex: _selectedSection,
                      onDestinationSelected: (index) {
                        setState(() => _selectedSection = index);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (isWide)
                  DashboardSidebar(
                    selectedIndex: _selectedSection,
                    onDestinationSelected: (index) {
                      setState(() => _selectedSection = index);
                    },
                  ),
                Expanded(
                  child: Column(
                    children: [
                      DashboardTopBar(
                        showMenuIcon: !isWide,
                        onRefresh: _refreshData,
                        onSignOut: _signOut,
                      ),
                      Expanded(
                        child: DashboardOverview(
                          selectedSection: _selectedSection,
                          snapshot: _snapshot,
                          isLoading: _isLoading,
                          databaseError: _databaseError,
                          apiError: _apiError,
                          apiStatus: _apiStatus,
                          onRefresh: _refreshData,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

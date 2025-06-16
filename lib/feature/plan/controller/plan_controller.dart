import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanController extends GetxController {
  // Reactive state variables
  final RxBool isDarkMode = false.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> planList = <Map<String, dynamic>>[].obs;

  // Computed lists for different plan statuses
  List<Map<String, dynamic>> get startedPlans =>
      planList.where((p) => p['plan_status'] == 'NULL').toList();

  List<Map<String, dynamic>> get inProgressPlans =>
      planList.where((p) => p['plan_status'] == 'Active').toList();

  List<Map<String, dynamic>> get donePlans =>
      planList.where((p) => p['plan_status'] == 'Done').toList();

  final SupabaseClient _supabase = Supabase.instance.client;
  final String _userId;

  PlanController()
    : _userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    _fetchPlans();
  }

  Future<void> refreshPlans() async => await _fetchPlans();

  Future<void> _fetchPlans() async {
    if (_userId.isEmpty) {
      _showError('Authentication required');
      return;
    }

    isLoading.value = true;

    try {
      final response = await _supabase
          .from('plan')
          .select('*')
          .eq('user_id', _userId)
          .order('created_at', ascending: false);
      if (response.isEmpty) {
        _showInfo('No plans found');
        planList.clear();
      } else {
        planList.assignAll(response.cast<Map<String, dynamic>>());
        print(planList);
      }
    } on PostgrestException catch (e) {
      _showError('Database error: ${e.message}');
    } catch (e) {
      _showError('Unexpected error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
    );
  }

  void _showInfo(String message) {
    Get.snackbar('Info', message, snackPosition: SnackPosition.BOTTOM);
  }
}

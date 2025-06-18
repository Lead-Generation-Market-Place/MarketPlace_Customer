import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SinglePlanController extends GetxController {
  final RxBool isNavigatedFromCreatePlan = false.obs;
  final RxMap selectedService = {}.obs;
  final RxBool isLoading = false.obs;

  SupabaseClient get _client => Supabase.instance.client;
  User? get _currentUser => _client.auth.currentUser;

  Future<void> savePlan(int serviceId) async {
    if (_currentUser == null) {
      _showSnackbar('Authentication Error', 'User is not authenticated.');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _client.from('plan').insert({
        'user_id': _currentUser!.id,
        'service_id': serviceId,
        'created_at': DateTime.now().toIso8601String(),
        'plan_status': 'active',
      }).select();

      if (response.isEmpty) {
        _showSnackbar(
          'Insert Failed',
          'Unable to add plan. Response: $response',
        );
      } else {
        _showSnackbar('Success', 'Plan has been successfully added.');
      }
    } catch (e) {
      _showSnackbar('Error', 'Exception occurred while saving plan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPlan(int serviceId) async {
    if (_currentUser == null) {
      _showSnackbar('Authentication Error', 'User is not authenticated.');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _client
          .from('services')
          .select()
          .eq('id', serviceId);

      if (response.isEmpty) {
        _showSnackbar('Not Found', 'No service found for ID $serviceId.');
      } else {
        selectedService.assignAll(response.single);
        _showSnackbar('Success', 'Service details loaded.');
      }
    } catch (e) {
      _showSnackbar('Error', 'Exception occurred while fetching plan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(title, message);
  }
}

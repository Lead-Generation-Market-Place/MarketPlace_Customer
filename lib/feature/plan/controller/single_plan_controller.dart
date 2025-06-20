import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:us_connector/feature/home/controllers/home_controller.dart';

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

  hirePro(final Map<String, dynamic> service) async {
    if (_currentUser == null) {
      _showSnackbar('Authentication Error', 'User is not authenticated.');
      return;
    }
    try {
      isLoading.value = true;
      if (service.isNotEmpty) {
        final homeControl = Get.find<HomeController>();
        await homeControl.fetchQuestions(service['service_id']);
      } else {
        _showSnackbar('Not Found', "No Service Found");
      }
    } catch (e) {
      _showSnackbar('Exception', 'Exception Error Ocurred $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removePlan(final Map<String, dynamic> plan) async {
    if (_currentUser == null) {
      _showSnackbar('Authentication Error', 'User is not authenticated.');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _client
          .from('plan')
          .delete()
          .eq('id', plan['id'])
          .select();
      if (response.isEmpty) {
        _showSnackbar(
          'Remove Failed',
          'Unable to Remove plan. Response: $response',
        );
      } else {
        Get.back(closeOverlays: true, result: true);
        _showSnackbar('Success', 'Plan has been successfully Deleted.');
      }
    } catch (e) {
      _showSnackbar('Error', 'Exception occurred while Deleting plan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(title, message);
  }
}

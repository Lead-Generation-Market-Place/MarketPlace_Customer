import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfessionalController extends GetxController {
  final Supabase _supabase = Supabase.instance;
  final RxList<Map<String, dynamic>> serviceData = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> professionals =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> professionalsByArea =
      <Map<String, dynamic>>[].obs;
  late final dynamic serviceId;
  final RxInt loadingPhase = 0.obs;

  @override
  void onInit() {
    super.onInit();
    serviceId = Get.arguments;
    _initData();
  }

  Future<void> _initData() async {
    await fetchServiceData();
    await fetchProfessionalsByService();
    await fetchProfessionalsByZip('1002'); // Consider making zip dynamic
  }

  /// Fetch service details by serviceId
  Future<void> fetchServiceData() async {
    loadingPhase.value = 1;
    try {
      final response = await _supabase.client
          .from('services')
          .select()
          .eq('id', serviceId)
          .single();
      serviceData.value = [response];
    } catch (e) {
      Logger().w('Failed to fetch service data: $e');
      Get.snackbar('Error', 'Failed to fetch service data');
    } finally {
      loadingPhase.value = 0;
    }
  }

  /// Fetch professionals related to the service
  Future<void> fetchProfessionalsByService() async {
    loadingPhase.value = 2;
    try {
      final response = await _supabase.client
          .from('pro_services')
          .select('*, users_profiles!inner(*)')
          .eq('service_id', serviceId)
          .order('id', ascending: false);
      //  professionals.value = List<Map<String, dynamic>>.from(response);

      List professionalUsersId = response.map((e) => e['user_id']).toList();
      if (professionalUsersId.isNotEmpty) {
        final serviceProviders = await _supabase.client
            .from('service_providers')
            .select()
            .inFilter('user_id', professionalUsersId);

        professionals.value = serviceProviders;
        print("professionals: $professionals");
      }
    } catch (e) {
      Logger().w('Failed to fetch professionals by service: $e');
      Get.snackbar('Error', 'Failed to fetch professionals');
    } finally {
      loadingPhase.value = 0;
    }
  }

  /// Fetch professionals by area (zip code)
  Future<void> fetchProfessionalsByZip(String zipCode) async {
    loadingPhase.value = 3;
    try {
      // Get location IDs matching the zip
      final locations = await _supabase.client
          .from('locations')
          .select('id')
          .eq('zip', zipCode);
      if (locations.isEmpty) {
        professionalsByArea.clear();
        return;
      }
      // Get provider IDs with those locations
      final locationIds = locations.map((l) => l['id']).toList();
      final providers = await _supabase.client
          .from('provider_locations')
          .select('provider_id')
          .inFilter('state_id', locationIds);
      if (providers.isEmpty) {
        professionalsByArea.clear();
        return;
      }
      final providerIds = providers.map((p) => p['provider_id']).toList();
      // Get professionals offering the service in those locations
      final response = await _supabase.client
          .from('pro_services')
          .select('*, users_profiles!inner(*)')
          .eq('service_id', serviceId)
          .inFilter('user_id', providerIds);
      professionalsByArea.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Logger().w('Failed to fetch professionals by area: $e');
      Get.snackbar('Error', 'Failed to fetch professionals by area');
    } finally {
      loadingPhase.value = 4;
    }
  }
}

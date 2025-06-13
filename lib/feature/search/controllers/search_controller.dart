import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class SearchController extends GetxController {
  final searchController = TextEditingController();
  final zipCodeController = TextEditingController();

  final RxList<Map<String, dynamic>> allServices = <Map<String, dynamic>>[].obs; // Changed to Map<String, dynamic>
  final RxList<Map<String, dynamic>> filteredServices = <Map<String, dynamic>>[].obs; // Changed to Map<String, dynamic>
  final RxBool showClearButton = false.obs;
  final RxBool isLoading = false.obs;

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    // Initial fetch of popular services or all services if search is empty
    _fetchServices('');
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchServices(String query) async {
    isLoading.value = true;
    try {
      if (query.isEmpty) {
        // Fetch initial popular services or all services when search is empty
        final response = await supabase.from('services').select('id, name').order('name', ascending: true).limit(5); // Fetch ID as well
        allServices.assignAll(List<Map<String, dynamic>>.from(response)); // Assign as List<Map<String, dynamic>>
        filteredServices.assignAll(allServices);
      } else {
        // Real-time search from Supabase
        final response = await supabase.from('services').select('id, name').ilike('name', '%' + query + '%').order('name', ascending: true); // Fetch ID as well
        filteredServices.assignAll(List<Map<String, dynamic>>.from(response)); // Assign as List<Map<String, dynamic>>
      }
    } catch (e) {
      print('Error fetching services: $e');
      // Optionally, show a Get.snackbar or other UI feedback
    } finally {
      isLoading.value = false;
    }
  }

  void _onSearchChanged() {
    _fetchServices(searchController.text);
    showClearButton.value = searchController.text.isNotEmpty;
  }

  void filterServices(String query) {
    // This method is now redundant as _fetchServices handles filtering from Supabase
    // Keeping it for now to avoid breaking existing calls, but its logic is moved
  }

  void clearSearch() {
    searchController.clear();
    _fetchServices(''); // Fetch all services again
    showClearButton.value = false;
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    zipCodeController.dispose();
    super.onClose();
  }
}
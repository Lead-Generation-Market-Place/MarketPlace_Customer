import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:us_connector/core/routes/routes.dart';

class InboxController extends GetxController {
  final RxList<Map<String, dynamic>> conversations =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final SupabaseClient _client = Supabase.instance.client;
  final RxBool isSearchingInConversation = false.obs;

  // Search-related observables
  final RxBool isSearchActive = false.obs;
  final RxString searchText = ''.obs;

  // Filtered conversations based on search
  List<Map<String, dynamic>> get filteredConversations {
    if (!isSearchActive.value || searchText.value.isEmpty) {
      return conversations;
    }
    final query = searchText.value.toLowerCase();
    return conversations.where((conv) {
      final professional = conv['professional'];
      final customer = conv['customer'];
      final professionalName = (professional?['username'] ?? '')
          .toString()
          .toLowerCase();
      final customerName = (customer?['username'] ?? '')
          .toString()
          .toLowerCase();
      return professionalName.contains(query) || customerName.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    getConversations();
    super.onInit();
  }

  Future<void> getConversations() async {
    isLoading.value = true;

    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        Get.toNamed(Routes.login);
        return;
      }
      final response = await _client
          .from('conversations')
          .select('''
      *,
      customer:users_profiles!conversations_customer_id_fkey(*),
      professional:users_profiles!conversations_professional_id_fkey(*)
    ''')
          .or(
            'customer_id.eq.${currentUser.id},professional_id.eq.${currentUser.id}',
          )
          .order('created_at', ascending: false);

      conversations.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Logger().w("Error occurred while getting conversations: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

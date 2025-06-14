import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxService {
  final supabase = Supabase.instance.client;
  final _logger = Logger();
  
  // Observable authentication state
  final isAuthenticated = false.obs;
  final currentUser = Rxn<User>();
  
  @override
  void onInit() {
    super.onInit();
    // Initialize auth state
    _initializeAuthState();
    
    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      _logger.d('Auth state changed: $event');
      
      switch (event) {
        case AuthChangeEvent.signedIn:
          isAuthenticated.value = true;
          currentUser.value = session?.user;
          break;
        case AuthChangeEvent.signedOut:
          isAuthenticated.value = false;
          currentUser.value = null;
          break;
        default:
          break;
      }
    });
  }
  
  void _initializeAuthState() {
    final session = supabase.auth.currentSession;
    isAuthenticated.value = session != null && !session.isExpired;
    currentUser.value = session?.user;
  }
  
  bool get isUserAuthenticated => isAuthenticated.value;
  
  User? get user => currentUser.value;
  
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      isAuthenticated.value = false;
      currentUser.value = null;
    } catch (e) {
      _logger.e('Error signing out: $e');
      rethrow;
    }
  }
}

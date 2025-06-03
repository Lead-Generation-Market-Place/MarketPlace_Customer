import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxController {
  final supabase = Supabase.instance.client;

  Future<void> signInWithEmail(String email, String password) async {
    try {
    } catch (e) {
      print(e);
    }
  }
}

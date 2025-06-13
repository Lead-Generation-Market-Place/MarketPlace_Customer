import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxController {
  final supabase = Supabase.instance.client;
  var isLoading = false.obs;


}

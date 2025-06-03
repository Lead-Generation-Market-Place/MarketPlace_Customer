import 'dart:async';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:us_connector/main.dart';
import '../../../core/routes/routes.dart';

class AuthController extends GetxController {
  // Text Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final acceptedTerms = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Login Methods
  Future<void> login() async {
    if (!_validateLoginInputs()) return;

    try {
      isLoading.value = true;

      final response = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final user = response.user;
      if (user == null) {
        throw 'Login failed. Please try again.';
      }

      final userProfile = await supabase
          .from('user_profiles')
          .select()
          .eq('email', user.email ?? '')
          .maybeSingle();

      if (userProfile == null) {
        await supabase.from('user_profiles').insert({
          'email': user.email,
          'username': user.userMetadata?['username'],
        });
      }

      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateLoginInputs() {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  // Signup Methods
  Future<void> signupWithGoogle() async {
    try {
      isLoading.value = true;

      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.user != null) {
        Get.toNamed(Routes.login);
      } else {
        throw Exception('Failed to sign up');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign up. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (!_validateSignupInputs()) return;

    try {
      isLoading.value = true;

      final response = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
        data: {'username': nameController.text},
      );

      if (response != null) {
        throw response;
      }

      if (response.user?.identities?.isEmpty ?? true) {
        throw 'User with this email already exists';
      }

      if (response.session != null) {
        Get.toNamed(Routes.home);
      } else {
        Get.snackbar(
          'Success',
          'Please check your email to verify your account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateSignupInputs() {
    if (nameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your full name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (confirmPasswordController.text != passwordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!acceptedTerms.value) {
      Get.snackbar(
        'Error',
        'Please accept the Terms of Service and Privacy Policy',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  // Navigation Methods
  void onForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  void goToSignup() {
    NavigationHelper.goToSignup();
  }

  void goToLogin() {
    NavigationHelper.goToLogin();
  }

  // Social Auth Methods
  StreamSubscription? _sub;

  Future<void> signInWithGoogle() async {
    /// TODO: update the Web client ID with your own.
    ///
    /// Web Client ID that you registered with Google Cloud.
    const webClientId =
        '117669178530-m7i284g3857t4f3ol9e2vo7j9v38h0af.apps.googleusercontent.com';

    /// TODO: update the iOS client ID with your own.
    ///
    /// iOS Client ID that you registered with Google Cloud.
    const iosClientId =
        '117669178530-b37fu5du424kf8q4gmjnee5c5stqnd1q.apps.googleusercontent.com';

    // Google sign in on Android will work without providing the Android
    // Client ID registered on Google Cloud.

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    Get.offAllNamed(Routes.home);
  }

  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb
            ? null
            : Platform.isAndroid
            ? 'us-connector://login-callback'
            : 'us.connector://login-callback',
        authScreenLaunchMode: LaunchMode.inAppWebView,
      );

      if (!response) {
        throw 'Apple sign in failed';
      }

      NavigationHelper.goToHome();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in with Apple. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGithub() async {
    try {
      isLoading.value = true;
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: kIsWeb
            ? null
            : Platform.isAndroid
            ? '117669178530-gpcq5ohgo1up86tk3psv61e91qfoqlce.apps.googleusercontent.com'
            : 'https://hdwfpfxyzubfksctezkz.supabase.co/auth/v1/callback',
      );

      if (!response) {
        throw 'Github sign in failed';
      }

      NavigationHelper.goToHome();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in with Github. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Terms and Privacy Policy
  void onTermsClick() {
    // Navigate to Terms of Service
  }

  void onPrivacyClick() {
    // Navigate to Privacy Policy
  }
}

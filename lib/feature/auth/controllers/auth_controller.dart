import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      // Add your login logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      NavigationHelper.goToHome();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
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
    if (!_validateSignupInputs()) return;

    try {
      isLoading.value = true;

      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
        data: {
          'username': nameController.text,
        },
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
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Sign in with Supabase Google OAuth
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb 
          ? null 
          : Platform.isAndroid
            ? '117669178530-gpcq5ohgo1up86tk3psv61e91qfoqlce.apps.googleusercontent.com'
            : 'https://hdwfpfxyzubfksctezkz.supabase.co/auth/v1/callback',
      );

      if (!response) {
        throw 'Google sign in failed';
      }

      // Navigate to home on success
      NavigationHelper.goToHome();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in with Google. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;
      // Add your Apple sign-in logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
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

  // Terms and Privacy Policy
  void onTermsClick() {
    // Navigate to Terms of Service
  }

  void onPrivacyClick() {
    // Navigate to Privacy Policy
  }
}
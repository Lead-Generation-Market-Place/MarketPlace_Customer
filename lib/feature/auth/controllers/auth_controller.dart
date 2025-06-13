import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:us_connector/core/widgets/custom_flutter_toast.dart';

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
  final emailError = RxnString();
  final passwordError = RxnString();
  final nameError = RxnString();
  final confirmPasswordError = RxnString();
  final termsError = RxnString();
  RxString email = ''.obs;
  RxString name = ''.obs;
  RxString profilePictureUrl = ''.obs;
  // Reset password variables
  final resetEmailError = RxnString();
  final resetTokenError = RxnString();
  final resetPasswordError = RxnString();
  final resetConfirmPasswordError = RxnString();

  RxString authUserId = ''.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
Future<void> loadUserData() async {
    try {
      final session = supabase.auth.currentSession;
      if (session != null) {
        final user = session.user;
        email.value = user.email ?? '';

        // Get user profile from database
        final userProfile = await supabase
            .from('users_profiles')
            .select('profile_picture_url,username')
            .eq('email', user.email ?? '')
            .single();

        if (userProfile != null) {
          profilePictureUrl.value = userProfile['profile_picture_url'];
          name.value = userProfile['username'];
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }
  // Login Methods
  Future<Map<String, dynamic>> login() async {
    try {
      isLoading.value = true;

      final credentials = {
        'email': emailController.text,
        'password': passwordController.text,
      };

      final response = await supabase.auth.signInWithPassword(
        email: credentials['email'] ?? '',
        password: credentials['password'] ?? '',
      );

      if (response.session == null) {
        return {'status': 'Login failed', 'user': null};
      }

      final userProfile = await supabase
          .from('users_profiles')
          .select()
          .eq('email', credentials['email'] ?? '')
          .select();
   name.value = response.user?.userMetadata?['username'] ?? response.user?.email ?? '';
        email.value = response.user?.email ?? '';

        profilePictureUrl.value = userProfile[0]['profile_picture_url'];
      if (userProfile.isEmpty) {
        final insertResponse = await supabase.from('users_profiles').insert({
          'email': response.user?.email,
          'username': response.user?.userMetadata?['username'],
        }).select();

     
        
        if (insertResponse.isNotEmpty) {
          return {'status': insertResponse, 'user': null};
        }
      } else {
        name.value = userProfile[0]['username'] ?? response.user?.email ?? '';
        email.value = response.user?.email ?? '';
      }

      Get.offAllNamed(Routes.home);
      emailController.value = TextEditingValue.empty;
      passwordController.value = TextEditingValue.empty;
      return {'status': 'success', 'user': response.user};
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to login. Please try again. $e');
      return {'status': e.toString(), 'user': null};
    } finally {
      isLoading.value = false;
    }
  }

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
        Fluttertoast.showToast(msg: 'Failed to sign up. Please try again.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to sign up. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    try {
      isLoading.value = true;

      final response = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
        data: {'username': nameController.text},
      );

      if (response.user?.identities?.isEmpty ?? true) {
        Fluttertoast.showToast(msg: 'User with this email already exists');
      }

      // Sign out the user after successful signup
      await supabase.auth.signOut();
      emailController.value = TextEditingValue.empty;
      passwordController.value = TextEditingValue.empty;
      nameController.value = TextEditingValue.empty;
      confirmPasswordController.value = TextEditingValue.empty;

      Get.toNamed(Routes.login);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to sign up. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigation Methods
  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await supabase.auth.resetPasswordForEmail(email);

      emailController.clear();
      Fluttertoast.showToast(msg: 'Reset email sent');
    } catch (e) {
      emailController.clear();
      Fluttertoast.showToast(msg: 'Reset email sent');
    } finally {
      isLoading.value = false;
      Fluttertoast.showToast(msg: 'Reset email sent');
    }
  }

  // Social Auth Methods
  StreamSubscription? _sub;

  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signOut();

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
        // Force select account to show account picker every time
        forceCodeForRefreshToken: true,
        // Clear cached credentials to show account picker
        signInOption: SignInOption.standard,
      );

      // Sign out from Google first to clear any cached credentials
      await googleSignIn.signOut();

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
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to sign in with Google. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
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

      Get.offAllNamed(Routes.home);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to sign in with Apple. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> signInWithGithub() async {
  //   try {
  //     isLoading.value = true;

  //     // TODO: Update with your GitHub OAuth credentials
  //     const githubClientId = 'YOUR_GITHUB_CLIENT_ID';
  //     const githubClientSecret = 'YOUR_GITHUB_CLIENT_SECRET';
  //     final response = await supabase.auth.signInWithOAuth(
  //       OAuthProvider.github,
  //       scopes: 'user:email',
  //       queryParams: {
  //         'client_id': githubClientId,
  //         'client_secret': githubClientSecret
  //       }
  //     );

  //     if (!response) {
  //       throw 'GitHub sign in failed';
  //     }

  //    final userProfile = await supabase
  //         .from('users_profiles')
  //         .select()
  //         .eq('email', response.user?.email ?? '')
  //         .select();

  //     if (userProfile == null) {
  //       await supabase.from('users_profiles').insert({
  //         'email': response.user?.email,
  //         'username': response.user?.userMetadata?['user_name'],
  //       });
  //     }

  //     Get.offAllNamed(Routes.home);
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to sign in with Github. Please try again.',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Terms and Privacy Policy
  void onTermsClick() {
    // Navigate to Terms of Service
  }

  void onPrivacyClick() {
    // Navigate to Privacy Policy
  }

  Future<void> resetPasswordWithToken(
    String email,
    String token,
    String newPassword,
  ) async {
    try {
      isLoading.value = true;
      await supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      Get.offAllNamed(Routes.login);
      Get.snackbar(
        'Success',
        'Password has been reset successfully. Please login with your new password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to reset password. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}

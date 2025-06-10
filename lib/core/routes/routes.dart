import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:us_connector/feature/auth/views/login.dart';
import 'package:us_connector/feature/auth/views/reset_password.dart';
import 'package:us_connector/feature/auth/views/reset_password_token.dart';
import 'package:us_connector/feature/auth/views/signup.dart';
import 'package:us_connector/feature/home/controllers/home_binding.dart';
import 'package:us_connector/feature/home/views/home_view.dart';
import 'package:us_connector/feature/inbox/views/inbox_view.dart';
import 'package:us_connector/feature/one_time_initial_view/controllers/one_time_initial_binding.dart';
import 'package:us_connector/feature/plan/views/plan_view.dart';
import 'package:us_connector/feature/search/views/search_view.dart';
import 'package:us_connector/feature/settings/views/settings_view.dart';
import 'package:us_connector/feature/team/views/team_view.dart';
import '../../feature/splash/views/splash_view.dart';
import '../../feature/splash/controllers/splash_controller.dart';
import '../../feature/one_time_initial_view/views/one_time_initial_view.dart';
import '../../feature/one_time_initial_view/controllers/one_time_initial_controller.dart';
import '../../feature/auth/controllers/auth_binding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Route Names
abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const profile = '/profile';
  static const settings = '/settings';
  static const search = '/search';
  static const plan = '/plan';
  static const inbox = '/inbox';
  static const team = '/team';
  static const resetPassword = '/reset-password';
  static const resetPasswordToken = '/reset-password-token';
}

// Middleware
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    
    if (session == null) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
}

class NoAuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    
    if (session != null) {
      return const RouteSettings(name: Routes.home);
    }
    return null;
  }
}

// App Pages
abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
      transition: Transition.fade,
    ),

    GetPage(
      name: Routes.onboarding,
      page: () => const OneTimeInitialView(),
      binding: OneTimeInitialBinding(),
      transition: Transition.fadeIn,
    ),

    // Auth Pages
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      middlewares: [NoAuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.signup,
      page: () => SignupView(),
      middlewares: [NoAuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.home,
      page: () => HomeView(),
      // middlewares: [AuthMiddleware()],
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.profile,
      page: () => PlanView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.signup,
      page: () => SignupView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.search,
      page: () => SearchView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.downToUp,
    ),

    GetPage(
      name: Routes.plan,
      page: () => PlanView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.settings,
      page: () => SettingsView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.inbox,
      page: () => InboxView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.team,
      page: () => TeamView(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.resetPassword,
      page: () => ResetPassword(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.resetPasswordToken,
      page: () => ResetPasswordToken(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}

// Navigation Helper
class NavigationHelper {
  static void goToLogin() => Get.offAllNamed(Routes.login);
  static void goToSignup() => Get.toNamed(Routes.signup);

  static void goToProfile() => Get.toNamed(Routes.profile);
  static void goToSettings() => Get.toNamed(Routes.settings);
  static void goToSearch() => Get.toNamed(Routes.search);
  static void goTotasks() => Get.toNamed(Routes.plan);

  static void goBack() => Get.back();

  static void logout() {
    // Add your logout logic here
    goToLogin();
  }
}

// Route Observer
class RouteObserver extends GetObserver {
  @override
  void onPageCalled(Route? route, Route? previousRoute) {
    debugPrint('New route called: ${route?.settings.name}');
  }

  @override
  void onPagePopped(Route? route, Route? previousRoute) {
    debugPrint('Page popped: ${route?.settings.name}');
  }
}

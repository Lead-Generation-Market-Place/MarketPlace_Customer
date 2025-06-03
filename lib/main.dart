import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/controllers/theme_controller.dart';
import 'core/localization/localization.dart';
import 'core/routes/routes.dart' hide RouteObserver;
import 'core/services/service_bindings.dart';
import 'core/utils/app_constants.dart';

// Global navigator key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Supabase instance
final supabase = Supabase.instance.client;

Future<void> initServices() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Supabase
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      debug: kDebugMode,
    );

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await Get.putAsync(() => Future.value(prefs));

    // Initialize other services
    await ServiceBindings().dependencies();

    // Initialize Theme Controller last since it depends on SharedPreferences
    final themeController = Get.put(ThemeController(), permanent: true);
    await themeController.initTheme();

  } catch (e, stackTrace) {
    debugPrint('Initialization Error: $e');
    debugPrint('Stack Trace: $stackTrace');
    rethrow;
  }
}

void main() {
  runZonedGuarded(
    () async {
      await initServices();
      runApp(const MyApp());
    },
    (error, stackTrace) {
      debugPrint('Error: $error');
      debugPrint('Stack Trace: $stackTrace');
      // Here you can implement error reporting service
      // Example: Sentry.captureException(error, stackTrace: stackTrace);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);




  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: AppConstants.appName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      // Localization
      translations: LocalizationService(),
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.fallbackLocale,

      // Theme
      theme: ThemeController.lightTheme,
      darkTheme: ThemeController.darkTheme,
      themeMode: themeController.themeMode,

      // Navigation and Routing
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
      navigatorObservers: [Get.put(RouteObserver<Route>())],
      
      // Global Error Handling
      onUnknownRoute: (settings) {
        return GetPageRoute(
          page: () => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Get.theme.colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Page not found: ${settings.name}'.tr,
                    style: Get.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Get.offAllNamed(Routes.home),
                    child: Text('Go to Home'.tr),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      // Error Widget and Screen Utilities
      builder: (context, widget) {
        // Error Builder
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Get.theme.colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong'.tr,
                      style: Get.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (kDebugMode)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          details.exception.toString(),
                          style: Get.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () => Get.offAllNamed(Routes.home),
                      child: Text('Restart App'.tr),
                    ),
                  ],
                ),
              ),
            ),
          );
        };

        // Screen Utilities
        widget = ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
            overscroll: true,
          ),
          child: widget!,
        );

        // Media Query
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: widget,
        );
      },

      // Logging and Analytics
      routingCallback: (routing) {
        if (routing?.current != null) {
          // Log navigation
          debugPrint('Navigation: ${routing?.previous} -> ${routing?.current}');
          
          // Implement analytics page tracking
          _trackScreenView(routing!.current!);
        }
      },
    );
  }

  void _trackScreenView(String screenName) {
    // Implement your analytics tracking here
    // Example: Analytics.logScreenView(screenName: screenName);
    debugPrint('Screen View: $screenName');
  }
}

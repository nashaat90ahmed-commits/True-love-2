import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:true_love_app/src/config/routes/app_routes.dart';
import 'package:true_love_app/src/config/themes/app_theme.dart';
import 'package:true_love_app/src/config/localization/app_localizations.dart';
import 'package:true_love_app/src/core/providers/providers.dart';
import 'package:true_love_app/src/core/services/ads_service.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // حفظ الشاشة الترحيبية حتى ينتهي التحميل
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // تهيئة Supabase بالروابط الخاصة بمشروعك
  await Supabase.initialize(
    url: 'https://vuclwhpfdghyzeemaboa.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ1Y2x3aHBmZGdoeXplZW1hYm9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5OTQ5NzcsImV4cCI6MjA4MTU3MDk3N30.5AhHEKs3RcIpq4RkOTF1ZR8UCpWpdePrZKAE2LoSPY0',
  );
  
  // تهيئة الإعدادات المحلية
  final prefs = await SharedPreferences.getInstance();
  
  // تهيئة نظام الإعلانات
  try {
    await MobileAds.instance.initialize();
    await AdsService.initialize();
  } catch (e) {
    debugPrint("Ads initialization skipped or failed: $e");
  }
  
  // إزالة الشاشة الترحيبية
  FlutterNativeSplash.remove();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      title: 'الحب الحقيقي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('fr'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorKey: AppRoutes.navigatorKey,
    );
  }
}

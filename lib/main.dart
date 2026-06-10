import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart';
import 'features/home/presentation/viewmodels/home_viewmodel.dart';
import 'firebase_options.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.instance.initialize();
  configureDependencies();
  runApp(const LunchQuestApp());
}

class LunchQuestApp extends StatelessWidget {
  const LunchQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Singleton VM shared across all screens via Provider
      create: (_) => sl<HomeViewModel>(),
      child: MaterialApp.router(
        title: 'Lunch Quest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
        locale: const Locale('tr', 'TR'),
        routerConfig: appRouter,
      ),
    );
  }
}

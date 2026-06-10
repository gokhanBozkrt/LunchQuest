import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart';
import 'features/home/presentation/viewmodels/home_viewmodel.dart';
import 'routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
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
        routerConfig: appRouter,
      ),
    );
  }
}

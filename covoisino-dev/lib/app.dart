// app.dart
import 'package:covoisino/config/app_theme.dart';
import 'package:covoisino/core/localization.dart';
import 'package:covoisino/core/providers.dart';
import 'package:covoisino/main.dart';
import 'package:covoisino/ui/auth_screen.dart';
import 'package:covoisino/ui/home_screen.dart';
import 'package:covoisino/ui/ride_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:covoisino/core/auth_wrapper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProxyProvider<VehicleProvider, AppAuthProvider>(
          create: (context) => AppAuthProvider(
            context.read<VehicleProvider>(),
            context,
          ),
          update: (context, vehicle, previous) =>
              previous ?? AppAuthProvider(vehicle, context),
        ),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Covoisino',
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.onboarding,
          
          locale: Provider.of<LocaleProvider>(context).currentLocale,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
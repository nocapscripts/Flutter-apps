import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memoapp/models/screens/memo_list_screen.dart';
import 'package:memoapp/l10n/locales.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo Notes',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Set MemoListScreen as the initial screen
      home: MemoListScreen(),
      // Define supported locales and localization delegates
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // Add your app's specific localization delegates
        // Assuming you have defined them in locales.dart
        AppLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('et', 'EE'), // Estonian
        // Add more locales as needed
      ],
      // Define the locale resolution callback
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode &&
              supportedLocale.countryCode == locale?.countryCode) {
            return locale;
          }
        }
        // If the device locale is not supported, use the first one from the list
        return supportedLocales.first;
      },
    );
  }
}

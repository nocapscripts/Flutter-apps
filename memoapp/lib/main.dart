import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memoapp/models/screens/memo_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Märkmed',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          background: Color.fromARGB(
              255, 0, 0, 0), // Set your desired background color here
        ),
      ),
      // Set MemoListScreen as the initial screen
      home: MemoListScreen(
        titleTranslation: 'Märkmed', // Pass translated string directly
        notesTranslation: 'Märkmed', // Pass translated string directly
        createdTranslation:
            'Aeg: {createdAt}', // Pass translated string directly
      ),
      // Define supported locales and localization delegates
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // Add your app's specific localization delegates
        // You can add more delegates here if needed
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

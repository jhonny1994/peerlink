import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/firebase_options.dart';
import 'package:peerlink/src/src.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override the SharedPreferencesProvider with actual instance
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      // OS-level app identifier - uses constant from ARB
      onGenerateTitle: (context) => S.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        LocaleNamesLocalizationsDelegate(),
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF008080), // Teal seed color
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF008080), // Teal seed color
        brightness: Brightness.dark,
      ),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
        // Sender routes
        AppRoutes.senderFilePicker: (context) => const SenderFilePickerScreen(),
        AppRoutes.senderCode: (context) => const SenderCodeScreen(),
        AppRoutes.senderProgress: (context) => const SenderProgressScreen(),
        AppRoutes.senderComplete: (context) => const SenderCompleteScreen(),
        // Receiver routes
        AppRoutes.receiverCodeEntry: (context) =>
            const ReceiverCodeEntryScreen(),
        AppRoutes.qrScanner: (context) => const QrScannerScreen(),
        AppRoutes.receiverAccept: (context) => const ReceiverAcceptScreen(),
        AppRoutes.receiverProgress: (context) => const ReceiverProgressScreen(),
        AppRoutes.receiverComplete: (context) => const ReceiverCompleteScreen(),
      },
    );
  }
}

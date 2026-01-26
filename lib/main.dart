import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/app_localizations.dart';
import 'home_page.dart';
import 'sound_vibration_settings.dart';
import 'onesignal_service.dart';
import 'language_settings.dart';
import 'language_selection_page.dart';
import 'app_localizations_helper.dart';
import 'app_theme.dart';
import 'firebase_remote_config_service.dart';
import 'subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundVibrationSettings.initialize();
  await LanguageSettings.initialize();
  await AppTheme.initialize();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Firebase Remote Config
  await FirebaseRemoteConfigService.initialize();
  
  // Initialize AdMob
  await MobileAds.instance.initialize();
  
  // Initialize OneSignal Push Notifications
  await OneSignalService.initialize();
  
  // Initialize Subscription Service
  await SubscriptionService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Listen for language changes
    LanguageSettings.initialize();
    // Listen to locale changes and rebuild app
    LanguageSettings.localeNotifier.addListener(_onLocaleChanged);
    // Listen to theme changes and rebuild app
    AppTheme.themeNotifier.addListener(_onThemeChanged);
    // Listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    LanguageSettings.localeNotifier.removeListener(_onLocaleChanged);
    AppTheme.themeNotifier.removeListener(_onThemeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app comes to foreground, fetch fresh ad IDs from Firebase
    if (state == AppLifecycleState.resumed) {
      FirebaseRemoteConfigService.fetchFreshValues();
    }
  }
  
  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show language selection page on first launch, otherwise show home page
    final initialRoute = LanguageSettings.isFirstLaunch
        ? const LanguageSelectionPage()
        : const HomePage();
    
    // Get current locale from notifier
    final currentLocale = LanguageSettings.localeNotifier.value;
    
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Spinner',
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.transparent, // Transparent so gradient shows through
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.transparent, // Transparent so gradient shows through
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          // Localization configuration
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizationsHelper.getSupportedLocales(),
          locale: currentLocale,
          home: initialRoute,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

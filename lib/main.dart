import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:cd/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cd/application.dart';
import 'package:cd/pages/home_page.dart';
import 'package:cd/utils/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'generated/i18n.dart';
import 'dart:ui' as ui;

void main() async {
  await DotEnv().load('.env');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLanguage(BuildContext context, String newLanguage) {
    _MyAppState state = context.ancestorStateOfType(TypeMatcher<_MyAppState>());
    state.setState(() {
      state._language = newLanguage;
    });
  }

  static void setTheme(BuildContext context, bool isDarkTheme) {
    _MyAppState state = context.ancestorStateOfType(TypeMatcher<_MyAppState>());
    state.setState(() {
      state._isDarkTheme = isDarkTheme;

      if (isDarkTheme) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black, // navigation bar color
          statusBarColor: Colors.black, // status bar color
        ));
      } else {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.blue, // navigation bar color
          statusBarColor: Colors.blueAccent.shade700, // status bar color
        ));
      }
    });
  }
}

class _MyAppState extends State<MyApp> {
  String _language = "en";
  bool _isDarkTheme = false;
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  bool isBannerLoaded = false;
  bool isInterstitialLoaded = false;
  ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blueAccent.shade700,
    accentColor: Colors.blueAccent.shade700,
    cardColor: Colors.white,
    backgroundColor: Colors.blue.shade50,
    iconTheme: IconThemeData(color: Colors.black),
    accentIconTheme: IconThemeData(color: Colors.blueAccent.shade700),
    unselectedWidgetColor: Colors.black,
    textTheme: TextTheme(
      headline: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      title: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black),
      subtitle: TextStyle(fontSize: 14.0),
      caption: TextStyle(color: Colors.blueAccent.shade700),
    ),
  );
  ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    accentColor: Colors.black,
    backgroundColor: Colors.grey.shade900,
    iconTheme: IconThemeData(color: Colors.white),
    accentIconTheme: IconThemeData(color: Colors.white),
    unselectedWidgetColor: Colors.white,
    textTheme: TextTheme(
      headline: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      title: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
      subtitle: TextStyle(fontSize: 14.0),
      caption: TextStyle(color: Colors.white),
    ),
  );
  bool _isLoaded = false;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: Platform.isAndroid ? DotEnv().env['ANDROID_ADMOB_BANNER_UNIT_ID'].toString() : DotEnv().env['IOS_ADMOB_BANNER_UNIT_ID'].toString(),
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          setState(() {
            isBannerLoaded = true;
          });
        }
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: Platform.isAndroid ? DotEnv().env['ANDROID_ADMOB_SCREEN_UNIT_ID'].toString() : DotEnv().env['IOS_ADMOB_SCREEN_UNIT_ID'].toString(),
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          setState(() {
            isInterstitialLoaded = true;
          });
        }
      },
    );
  }

  @override
  void initState() {
    _getTheme();
    _screenAdController();
    _getLanguage();
    application.onLocaleChanged = onLocaleChange;
    FirebaseAdMob.instance.initialize(appId: Platform.isAndroid ? DotEnv().env['ANDROID_ADMOB_APP_ID'].toString() : DotEnv().env['IOS_ADMOB_APP_ID'].toString());
    _bannerAd = createBannerAd()..load();

    super.initState();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _isDarkTheme ? _darkTheme : _lightTheme,
        home: SplashScreen(),
        routes: {
          "/home": (context) => HomePage(),
        },
        localizationsDelegates: [
          //localizations
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        locale: new Locale(_language),
        //set language
        builder: (BuildContext context, Widget widget) {
          return Container(
            color: Theme.of(context).backgroundColor,
            padding: EdgeInsets.only(bottom: isBannerLoaded ? 50.0 : 0),
            child: widget,
          );
        },
      );
    }
  }

  _getTheme() async {
    _isDarkTheme = await SharedPreferencesHelper.isDarkTheme();
    if (_isDarkTheme) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black, // navigation bar color
        statusBarColor: Colors.black, // status bar color
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.blue, // navigation bar color
        statusBarColor: Colors.blueAccent.shade700, // status bar color
      ));
    }
    setState(() {
      _isLoaded = true;
    });
  }

  _screenAdController() async {
    _bannerAd ??= createBannerAd();
    _bannerAd
      ..load()
      ..show();
    int counter = await SharedPreferencesHelper.incrementCounter();
    if (counter % 25 == 0) {
      _interstitialAd?.dispose();
      _interstitialAd = createInterstitialAd()..load();
      isInterstitialLoaded = await _interstitialAd.isLoaded();
      if (isInterstitialLoaded) {
        _interstitialAd?.show();
      }
    }
    isBannerLoaded = await _bannerAd.isLoaded();
    setState(() {});
  }

  _getLanguage() async {
    List<String> languages = ['en', 'tr', 'de', 'fr'];
    //get language
    _language = await SharedPreferencesHelper.getLanguage();

    //if language empty set device language
    if (_language?.isEmpty ?? true) {
      _language = ui.window.locale.languageCode;

      if (!languages.contains(_language)) {
        _language = DotEnv().env['DEFAULT_LANGUAGE'];
      }
    }

    Intl.defaultLocale = "${_language}_${_language.toUpperCase()}";
    //set language
    await SharedPreferencesHelper.setLanguage(_language);
    setState(() {});
  }

  void onLocaleChange(String language) {
    setState(() {
      _language = language;
      Intl.defaultLocale = "${_language}_${_language.toUpperCase()}";
    });
  }
}

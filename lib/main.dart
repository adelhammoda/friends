import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:offer_app/pages/error_page.dart';
import 'package:offer_app/pages/home_page.dart';
import 'package:offer_app/pages/login_page.dart';
import 'package:offer_app/pages/watting_page.dart';
import 'package:offer_app/provider/auth_provider.dart';
import 'package:offer_app/provider/setting_provider.dart';
import 'package:offer_app/server/authentication.dart';
import 'package:offer_app/utils/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
      create: (context) => SettingProvider(context), child: const MyApp()));

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: L10n.all,
      title: 'Offer app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: Provider.of<SettingProvider>(context, listen: false)
            .setting
            .theme
            .primaryColor,
        primarySwatch: Provider.of<SettingProvider>(context, listen: false)
            .setting
            .theme
            .createMaterialColor(),
      ),
      home: StreamBuilder(
          stream: AuthenticationApi().gitUserState,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return ChangeNotifierProvider(
                  create: (context) => AuthProvider(),
                  child: const LoginPage());
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const WaitingPage();
            } else if (snapshot.data != null) {
              return const HomePage();
            } else {
              return ErrorPage(
                error: snapshot.error ?? '',
              );
            }
          }),
    );
  }
}

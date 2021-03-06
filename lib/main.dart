import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:friends/models/user.dart';
import 'package:friends/pages/error_page.dart';
import 'package:friends/pages/home_page.dart';
import 'package:friends/pages/login_page.dart';
import 'package:friends/pages/watting_page.dart';
import 'package:friends/provider/auth_provider.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/server/authentication.dart';
import 'package:friends/utils/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(true);
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
      locale: Provider.of<SettingProvider>(context).locale,
      supportedLocales: L10n.all,
      title: 'Friends',
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
      home: StreamBuilder<auth.User?>(
          stream: AuthenticationApi().gitUserState,
          builder: (context, snapshot) {
            if (snapshot.data == null|| !(snapshot.data?.emailVerified??false)) {
              return ChangeNotifierProvider(
                  create: (context) => AuthProvider(),
                  child:  LoginPage(unVerified: AuthenticationApi.isUserVerified,));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const WaitingPage();
            } else if (snapshot.data != null && (snapshot.data?.emailVerified??false)) {
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

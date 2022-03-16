import 'package:flutter/cupertino.dart';
import 'package:friends/models/setting_model.dart';
import 'package:friends/models/theme.dart';
import 'package:friends/models/user.dart';
import 'package:friends/server/authentication.dart';

class SettingProvider with ChangeNotifier {
  final BuildContext context;
  late Setting setting = Setting(context);
  User? user;
  Locale? locale;

  SettingProvider(this.context) {
    tryToLoadUser();
  }

  void changeUser(User user1) {
    user = user1;
    notifyListeners();
  }
  void changeTheme(AppTheme theme){

    setting.theme=theme;
    notifyListeners();
  }

  void changeLanguage(String tag){
    locale = Locale(tag);
    notifyListeners();
  }

  void tryToLoadUser() async {
    User? user = await AuthenticationApi.readUserFromStorage();
    if (user != null) {
      this.user = user;
    }
  }
}

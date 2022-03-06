import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:friends/models/setting_model.dart';
import 'package:friends/models/user.dart';
import 'package:friends/server/authentication.dart';

class SettingProvider with ChangeNotifier {
  final BuildContext context;
  late Setting setting = Setting(context);
  User? user;

  SettingProvider(this.context) {
    tryToLoadUser();
  }

  void changeUser(User user1) {
    user = user1;
    print(user?.id);
    notifyListeners();
  }

  void tryToLoadUser() async {
    User? user = await AuthenticationApi.readUserFromStorage();
    if (user != null) {
      this.user = user;
    }
  }
}

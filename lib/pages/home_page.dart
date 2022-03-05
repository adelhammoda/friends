import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:friends/models/user.dart';
import 'package:friends/server/authentication.dart';
import 'package:lottie/lottie.dart';
import 'package:friends/classes/navigator.dart';
import 'package:friends/pages/add_edit_offer.dart';
import 'package:friends/pages/offer_page.dart';
import 'package:friends/pages/qr_code.dart';
import 'package:friends/pages/setting.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/widgets/app_bar.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:responsive_s/responsive_s.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final Responsive _responsive = Responsive(context);
  late final SettingProvider _setting = Provider.of<SettingProvider>(context);
  final CustomScaffoldController _controller = CustomScaffoldController();
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  late final Animation<double> _pageAnimation;
  late final AnimationController _pageAnimationController;

  void _onSwitchIconTap(int index) {
    switch (index) {
      case 0:
        {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeIn);
          break;
        }
      case 1:
        {
          _pageController.animateToPage(1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeIn);
          break;
        }
      case 2:
        {
          _pageController.animateToPage(2,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeIn);
          break;
        }
    }
  }


  void _tryToFetchUser()async{
    if(_setting.user==null) {
      User? user = await AuthenticationApi().fetchUserFromHisAccount();
      print("User result is use ${user?.id}");
      if (user != null) {
        _setting.changeUser(user);
        await AuthenticationApi().writeUserToStorage(user);
      }
    }
  }
  @override
  void initState() {
    super.initState();
    _pageAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _pageAnimation = Tween(end: 1.0, begin: 0.0).animate(CurvedAnimation(
        parent: _pageAnimationController, curve: Curves.easeInBack));

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setting.tryToLoadUser();
    _tryToFetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      navigationBar: SnakeNavigationBar.color(
        behaviour: SnakeBarBehaviour.floating,
        padding: const EdgeInsets.all(10),
        snakeShape: SnakeShape.circle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        onTap: _onSwitchIconTap,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(
            'assets/icons/home.png',
            width: _responsive.responsiveWidth(forUnInitialDevices: 7),
          )),
          BottomNavigationBarItem(
              icon: Image.asset(
            'assets/icons/qr-code.png',
            width: _responsive.responsiveWidth(forUnInitialDevices: 7),
          )),
          BottomNavigationBarItem(
              icon: Lottie.asset(
            'assets/lottie/addOffer.json',
            animate: false,
          )),
          // BottomNavigationBarItem(icon: )
        ],
      ),
      controller: _controller,
      // prefixWidget: Lottie.asset('assets/lottie/38213-error.json'),
      appBar: buildAppBar(context,
          title: _setting.setting.appLocalization?.offers ?? "Offers",
          actions: [
            //TODO:change this icon to setting icon
            IconButton(
              onPressed: () {
                Go.to(context, const SettingPage(),
                    behavior: NavigatorBehavior.downToTop);
              },
              icon: const Icon(Icons.reset_tv),
            )
          ]),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          OfferPage(),
          QrCode(),
          AddEditOffer(),
        ],
      ),
    );
  }
}

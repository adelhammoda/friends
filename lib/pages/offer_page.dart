import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:friends/models/offer_models.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:friends/widgets/loader.dart';
import 'package:friends/widgets/offer_card.dart';
import 'package:provider/provider.dart';
import 'package:responsive_s/responsive_s.dart';

import '../models/user.dart';
import '../server/authentication.dart';
import '../server/database_api.dart';

class OfferPage extends StatefulWidget {
  const OfferPage({Key? key}) : super(key: key);

  @override
  _OfferPageState createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  final CustomScaffoldController _scaffoldController =
      CustomScaffoldController();
  late final SettingProvider _setting = Provider.of<SettingProvider>(context);
  late final Responsive _responsive = Responsive(context);


  void _tryToFetchUser() async {
    if (_setting.user == null) {
      print("User result is use ${_setting.user}");
      User? user = await AuthenticationApi.fetchUserFromHisAccount();
      if (user != null) {
        _setting.changeUser(user);
        await AuthenticationApi.writeUserToStorage(user);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tryToFetchUser();
  }
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: _scaffoldController,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: FutureBuilder<List<Offer>?>(
              future: DataBaseApi.getAllOffer(),
              builder: (context, snapshot) {
                print(snapshot.data);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                      width:
                          _responsive.responsiveWidth(forUnInitialDevices: 100),
                      height: _responsive.responsiveHeight(
                          forUnInitialDevices: 100),
                      child: Center(
                          child: Loader(
                        size: _responsive.responsiveWidth(
                            forUnInitialDevices: 50),
                      )));
                } else if (snapshot.hasData &&
                    snapshot.data != null &&
                    (snapshot.data?.isNotEmpty ?? false)) {
                  return StreamBuilder<DatabaseEvent>(
                      stream: DataBaseApi.getSubscriberCount(),
                      builder: (context, streamSnapShot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: _responsive.responsiveWidth(forUnInitialDevices: 100),
                                // height: _responsive.responsiveHeight(forUnInitialDevices: 90),
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) => Padding(
                                      padding:  EdgeInsets.only(
                                        top: _responsive.responsiveHeight(forUnInitialDevices: 3)
                                      ),
                                      child: OfferCard(
                                          offer: snapshot.data![index],
                                          subscriperCount: (streamSnapShot
                                                  .data?.snapshot.value is int)
                                              ? (streamSnapShot
                                                      .data?.snapshot.value ??
                                                  0) as int
                                              : 0),
                                    )),
                              ),
                            )
                          ],
                        );
                      });
                } else {
                  return SizedBox(
                      height: _responsive.responsiveHeight(
                          forUnInitialDevices: 100),
                      child: Center(
                          child: Text(_setting.setting.appLocalization
                                  ?.thereIsNoDataToDisplay ??
                              "No data to display",style: TextStyle(
                            fontSize: 15
                          ),)));
                }
              }),
        ),
      ),
      // child: ListView.builder(itemBuilder: itemBuilder),
    );
  }
}

import 'package:carousel_pro_nullsafety/carousel_pro_nullsafety.dart';
import 'package:flutter/material.dart';
import 'package:friends/models/user.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:friends/server/database_api.dart';
import 'package:friends/widgets/dynamic_info_builder.dart';
import 'package:friends/widgets/loader.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_s/responsive_s.dart';
import '../models/offer_models.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_scaffold.dart';

class ShowOfferDetials extends StatefulWidget {
  final Offer offer;

  const ShowOfferDetials({Key? key, required this.offer}) : super(key: key);

  @override
  State<ShowOfferDetials> createState() => _ShowOfferDetialsState();
}

class _ShowOfferDetialsState extends State<ShowOfferDetials> {
  final CustomScaffoldController _controller = CustomScaffoldController();
  late final Responsive _responsive = Responsive(context);
  late final SettingProvider _setting = Provider.of<SettingProvider>(context);

  Future<User?> _getOfferOwner() async {
    User? user = await DataBaseApi.getUser(widget.offer.offerOwnerId);
    print('user name is ${user?.name}');
    if (user == null) return null;
    return user;
  }

  @override
  void initState() {
    super.initState();
    _getOfferOwner();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: _responsive.responsiveWidth(forUnInitialDevices: 90),
                height: _responsive.responsiveHeight(forUnInitialDevices: 40),
                child: Carousel(
                  dotBgColor: Colors.transparent,
                  dotColor: _setting.setting.theme.primaryColor,
                  dotIncreasedColor: _setting.setting.theme.appBarColor,
                  overlayShadow: false,
                  overlayShadowSize: 0,
                  overlayShadowColors: Colors.transparent,
                  images: widget.offer.images
                      .map((url) => Image.network(
                            url,
                            fit: BoxFit.fill,
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: _responsive.responsiveWidth(
                    forUnInitialDevices: 6,
                  ),
                  vertical:
                      _responsive.responsiveHeight(forUnInitialDevices: 1)),
              child: Row(
                children: [
                  Text(
                    (_setting.setting.appLocalization?.offerValue ??
                            "Offer Value") +
                        ": ",
                    style: TextStyle(
                        color: _setting.setting.theme.bodyTextColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.offer.value.toString() + "%",
                    style: TextStyle(
                        color: _setting.setting.theme.textFieldColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: _responsive.responsiveWidth(
                    forUnInitialDevices: 6,
                  ),
                  vertical:
                      _responsive.responsiveHeight(forUnInitialDevices: 1)),
              child: Row(
                children: [
                  Text(
                    (_setting.setting.appLocalization?.totalCapacity ??
                            "Total Capacity") +
                        ": ",
                    style: TextStyle(
                        color: _setting.setting.theme.bodyTextColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.offer.totalCapacity.toString(),
                    style: TextStyle(
                        color: _setting.setting.theme.textFieldColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: _responsive.responsiveWidth(forUnInitialDevices: 90),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _setting.setting.appLocalization?.description ??
                      "Description" + ":",
                  style: _setting.setting.theme.appBarTextStyle,
                ),
                Text(widget.offer.description),
              ],
            ),
            color: _setting.setting.theme.lightWhite,
          ),

          Row(
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(vertical: 8.0,
                horizontal: _responsive.responsiveWidth(forUnInitialDevices: 5)),
                child: Text(_setting.setting.appLocalization?.date??"date"+":",
                style: TextStyle(
                  color: _setting.setting.theme.bodyTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(DateFormat.yMMMd().format(widget.offer.date).toString()),
              )
            ],
          ),
          Column(
            children: buildFromMap(widget.offer.info),
          ),
          FutureBuilder<User?>(
              future: DataBaseApi.getUser(widget.offer.offerOwnerId),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Loader(
                    size: _responsive.responsiveWidth(forUnInitialDevices: 30)
                  );
                }
                else if(snapshot .hasData && snapshot.data!=null) {
                  return Padding(
                    padding:  EdgeInsets.symmetric(vertical: 8.0,horizontal: _responsive.responsiveWidth(forUnInitialDevices: 5)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Offer owner name: '),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(snapshot.data?.name??"No data"),
                            ),
                          ],
                        )],
                    ),
                  );
                }
                else{
                  return Container();
                }
              })
        ],
      )),
      controller: _controller,
      appBar: buildAppBar(context, title: widget.offer.name),
    );
  }
}

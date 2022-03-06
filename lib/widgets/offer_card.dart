import 'dart:math';

import 'package:flutter/material.dart';
import 'package:friends/classes/navigator.dart';
import 'package:friends/models/offer_models.dart';
import 'package:provider/provider.dart';
import 'package:responsive_s/responsive_s.dart';

import '../models/offer_models.dart';
import '../pages/show_offer_detials.dart';
import '../provider/setting_provider.dart';

class OfferCard extends StatefulWidget {
  final Offer offer;
  final int subscriperCount;
  const OfferCard(
      {Key? key, required this.offer, required this.subscriperCount})
      : super(key: key);

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  late final Responsive _responsive = Responsive(context);
  late final SettingProvider _setting = Provider.of<SettingProvider>(context);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Go.to(context, ShowOfferDetials(offer: widget.offer));
      },
      child: Container(
        width: _responsive.responsiveWidth(forUnInitialDevices: 90),
        height: _responsive.responsiveHeight(forUnInitialDevices: 30),
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        decoration: const BoxDecoration(),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          fit: StackFit.expand,
          children: [
            Container(
              width: _responsive.responsiveWidth(forUnInitialDevices: 90),
              height: _responsive.responsiveHeight(forUnInitialDevices: 30),
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black.withOpacity(0.4),
                ),
                padding: const EdgeInsets.all(6),
                child: Text(
                  widget.offer.name,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                        widget.offer.images.first,
                      )),
                  borderRadius: BorderRadius.circular(15)),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Transform.rotate(
                origin: Offset(
                    0, _responsive.responsiveWidth(forUnInitialDevices: 25)),
                angle: -pi / 4,
                alignment: Alignment.center,
                child: Container(
                  alignment: Alignment.center,
                  width: _responsive.responsiveWidth(forUnInitialDevices: 50),
                  height: _responsive.responsiveHeight(forUnInitialDevices: 2),
                  color: Colors.red,
                  child: Text(
                    widget.offer.value.toString() + "%",
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child:widget.offer.totalCapacity==0||widget.offer.totalCapacity==null?Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('Un limited',
                      style: TextStyle(
                          fontSize: 13,
                          color: _setting.setting.theme.iconsColor))): Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(widget.subscriperCount.toString(),
                          style: TextStyle(
                              fontSize: 13,
                              color: _setting.setting.theme.iconsColor))),
                  SizedBox(
                    width: _responsive.responsiveWidth(forUnInitialDevices: 10),
                    child: Divider(
                      thickness: 2,
                      height: 3,
                      color: _setting.setting.theme.iconsColor,
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(widget.offer.totalCapacity.toString(),
                          style: TextStyle(
                              fontSize: 13,
                              color: _setting.setting.theme.iconsColor)))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

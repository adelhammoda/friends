


import 'dart:math';

import 'package:flutter/material.dart';
import 'package:offer_app/models/offer_models.dart';
import 'package:responsive_s/responsive_s.dart';

class OfferCard extends StatefulWidget {
  final Offer offer;
   const  OfferCard({Key? key,required this.offer}) : super(key: key);

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  late final Responsive _responsive=Responsive(context);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _responsive.responsiveWidth(forUnInitialDevices: 90),
      height: _responsive.responsiveHeight(forUnInitialDevices: 30),
      clipBehavior: Clip.hardEdge,
      decoration:const BoxDecoration(),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            width: _responsive.responsiveWidth(forUnInitialDevices: 90),
            height: _responsive.responsiveHeight(forUnInitialDevices: 30),
            alignment: Alignment.bottomCenter,
            child:Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withOpacity(0.4),
              ),
              padding: const EdgeInsets.all(5),
              child: Text(
                widget.offer.name,
                style:const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              image:  DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(
                  widget.offer.imageUrl
                )
              ),
              borderRadius: BorderRadius.circular(15)
            ),
          ),
          Transform.rotate(
            origin: Offset(0,_responsive.responsiveWidth(forUnInitialDevices: 25)),
            angle:-pi/4,
          alignment: Alignment.center,
          child: Container(
            alignment: Alignment.center,
            width: _responsive.responsiveWidth(forUnInitialDevices: 50),
            height: _responsive.responsiveHeight(forUnInitialDevices: 2),
            color: Colors.red,
            child: Text(widget.offer.value.toString()+"%",style:const  TextStyle(
              fontSize: 13,
              color: Colors.black
            ),),
          ),),
        ],
      ),
    );
  }
}







import 'package:flutter/material.dart';
import 'package:offer_app/models/offer_models.dart';
import 'package:offer_app/widgets/custom_scaffold.dart';
import 'package:offer_app/widgets/offer_card.dart';

class OfferPage extends StatefulWidget {
  const OfferPage({Key? key}) : super(key: key);

  @override
  _OfferPageState createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  final CustomScaffoldController _scaffoldController=CustomScaffoldController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(

      controller: _scaffoldController,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity,),
              OfferCard(
                offer: Offer(
                  totalCapacity: 12,
                  date: DateTime.now(),
                  description: 'assets/lottie/addOffer.json',
                  id: 'qw',
                  imageUrl: 'fasfas',
                  info: { },
                  name: 'Bodoni Ornaments',
                  offerOwnerId: '1234',
                  value: 144.5
                ),
              ),

            ],
          ),
        ),
      ),
      // child: ListView.builder(itemBuilder: itemBuilder),
    );
  }
}

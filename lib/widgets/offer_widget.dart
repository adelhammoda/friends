import 'package:flutter/material.dart';
import 'package:responsive_s/responsive_s.dart';

class OfferWidget extends StatefulWidget {
  final String imageURL;
  final String offerName;

  const OfferWidget({Key? key, required this.imageURL, required this.offerName})
      : super(key: key);

  @override
  _OfferWidgetState createState() => _OfferWidgetState();
}

class _OfferWidgetState extends State<OfferWidget> {
  late Responsive _responsive;

  @override
  Widget build(BuildContext context) {
    _responsive = Responsive(context);
    return SizedBox(
      width: _responsive.responsiveWidth(forUnInitialDevices: 70),
      height: _responsive.responsiveHeight(forUnInitialDevices: 50),
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 5,
        shape: const CircleBorder(),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            FadeInImage(
              placeholderFit: BoxFit.fill,
              placeholder: const AssetImage(
                  'assets/city.jpg'
              ),
              fit: BoxFit.fill,
              image: NetworkImage(
                widget.imageURL,

              ),
            ),
            Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15)
                  ),
                  padding: const EdgeInsets.all(7),
                  child:  Text(
                    widget.offerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _responsive.responsiveValue(forUnInitialDevices: 6),
                      // backgroundColor: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:offer_app/widgets/custom_scaffold.dart';

class QrCode extends StatefulWidget {
  const QrCode({Key? key}) : super(key: key);

  @override
  _QrCodeState createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  final CustomScaffoldController _scaffoldController =
      CustomScaffoldController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        child: Text("scaffold page"),
        controller: _scaffoldController,);
  }
}

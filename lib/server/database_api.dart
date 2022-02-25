import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:offer_app/models/offer_models.dart';
import 'package:offer_app/models/user.dart';
import 'package:offer_app/utils/info.dart';

class DataBaseApi {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<List<User>?> getOffersOwners() async {
    return await _database
        .ref('users')
        .orderByChild('userType')
        .equalTo(UserType.owner.toString())
        .once()
        .then((value) {
      print('value is ${value.snapshot.value}');
      List<User> res = [];
      if (value.snapshot.value != null) {
        (value.snapshot.value as Map).forEach((key, value) {
          res.add(User(
            name: value['name'],
            id: key,
            userType: value['userType'],
            imageUrl: value['imageUrl'],
          ));
        });
        return res;
      }
    }).catchError((e) => null);
  }

  static Future createNewOffer({
    required String offerName,
    required double offerValue,
    required String offerOwnerId,
    required double totalCapacity,
    required String description,
    required List<Map<dynamic, dynamic>> info,
  }) async {
    return await _database.ref('offers').push().set({
      "offerName": offerName,
      "offerValue": offerValue,
      "offerOwnerId": offerOwnerId,
      "totalCapacity": totalCapacity == 0.0 || totalCapacity < 0
          ? null
          : totalCapacity,
      "description": description,
      "info": info
    });
  }

  static Future<List<Offer>?> getAllOffer() async {
    List<Offer> res = [];
    return await _database.ref('offers').get().then((value) {
      value.exists ? (value.value as Map).forEach((key, value) {
        res.add(Offer(
          totalCapacity: value['totalCapacity'],
            id: key,
            imageUrl: value['imageUrl'],
            name: value['offerName'],
            offerOwnerId: value['offerOwnerId'],
            description: value['description'],
            date: value['date'],
            info: value['info'],
            value: value['offerValue']));
      }) : null;
      return res;
    }).catchError((e) => throw e);
  }
}

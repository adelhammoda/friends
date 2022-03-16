import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:friends/models/offer_models.dart';
import 'package:friends/models/user.dart';
import 'package:friends/utils/info.dart';
import 'package:image_picker/image_picker.dart';

class DataBaseApi {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const FlutterSecureStorage storage = FlutterSecureStorage();
  static late final FirebaseStorage _dataBaseStorage=FirebaseStorage.instance;

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
            phoneNumber: value['phone_number'],
            email: value['email'],
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
    required List<String> images,
  }) async {


    return await _database.ref('offers').push().set({
      "offerName": offerName,
      "date":DateTime.now().toIso8601String(),
      "images":images,
      "offerValue": offerValue,
      "offerOwnerId": offerOwnerId,
      "totalCapacity":
          totalCapacity == 0.0 || totalCapacity < 0 ? null : totalCapacity,
      "description": description,
      "info": info
    });
  }


  static Future<List<String>?> uploadImages(List<File> images,String offerName)async{
    try {
      List<String> res=[];
      for(File file in images){
        res.add(await _dataBaseStorage.ref('offers').child(offerName).child(DateTime.now().toIso8601String()).putData(await file.readAsBytes()).then((p0)async {
          // print(await p0.ref.getDownloadURL());
          return await p0.ref.getDownloadURL();
        }));
      }
      return res;
    } on Exception catch (e) {
      // print(e);
      throw e;
    }

  }

  static Future<List<Offer>?> getAllOffer() async {
    List<Offer> res = [];
    return await _database.ref('offers').get().then((value) {
      // print('value.value is ${value.value}');
      // print(value.value != null);
      if (value.value != null) {
        // print("i am befor if and res is ${(value.value as Map).values.first['images']}");
        (value.value as Map).forEach((key, value) {
          Map data=value;
          data.addAll({'id':key});
          res.add(Offer.fromJSON(data));
        });
        // print("i am in if and res is $res");
      }
      // print(res);
      return  res;
    }).catchError((e) {
      // print(e);
      throw e;
    });
  }

  static Stream<DatabaseEvent> getSubscriberCount() {
    return _database.ref('subscriber').onValue;
  }

  static Future<User?> getUser(String ownerID) async {
    return await _database.ref('users').child(ownerID).once().then((value) {
      // print(value.snapshot.value);
      return value.snapshot.value != null
          ? User(
              email: (value.snapshot.value as Map)['email'],
              id: ownerID,
              name: (value.snapshot.value as Map)['name'],
              userType: (value.snapshot.value as Map)['userType'],
              address: (value.snapshot.value as Map)['address'],
              imageUrl: (value.snapshot.value as Map)['imageUrl'],
              phoneNumber: (value.snapshot.value as Map)['phoneNumber'])
          : null;
    });
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:offer_app/models/user.dart';
import 'package:offer_app/provider/setting_provider.dart';
import 'package:offer_app/server/database_api.dart';
import 'package:offer_app/widgets/custom_dialog.dart';
import 'package:offer_app/widgets/custom_scaffold.dart';
import 'package:offer_app/widgets/loader.dart';
import 'package:offer_app/widgets/search_field.dart';
import 'package:offer_app/widgets/text_field.dart';
import 'package:offer_app/widgets/user_card.dart';
import 'package:responsive_s/responsive_s.dart';

class AddEditOffer extends StatefulWidget {
  const AddEditOffer({Key? key}) : super(key: key);

  @override
  _AddEditOfferState createState() => _AddEditOfferState();
}

class _AddEditOfferState extends State<AddEditOffer>
    with SingleTickerProviderStateMixin {
  late final Responsive _responsive = Responsive(context);
  late final SettingProvider _setting = SettingProvider(context);

  //
  final ValueNotifier<XFile?> _imageNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<List<Widget>> _info = ValueNotifier([]);
  //
  String _offerName = '',_description='';
  double _offerValue = -1.0,
      _totalCapacity = 0.0;
  User? _offerOwner;
  List<Map> _infoList = [];

  //
  late final AnimationController _cameraController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
  late final Animation<double> _cameraAnimation =
      Tween(begin: 0.0, end: 1.0).animate(_cameraController);

  //
  final CustomScaffoldController _scaffoldController =
      CustomScaffoldController();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _offerOwnerController=TextEditingController();
  final GlobalKey<FormState> _formKey=GlobalKey();

  void _pickImage() {
    showCustomDialog(context,
        height: _responsive.responsiveHeight(forUnInitialDevices: 90),
        width: _responsive.responsiveHeight(forUnInitialDevices: 10),
        child: Container(
          color: _setting.setting.theme.primaryColor,
          constraints: BoxConstraints(
              maxWidth: _responsive.responsiveWidth(forUnInitialDevices: 80),
              maxHeight: _responsive.responsiveHeight(forUnInitialDevices: 50)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () async {
                  Navigator.pop(context);
                  _imageNotifier.value =
                      await _picker.pickImage(source: ImageSource.camera);
                },
                trailing: const Icon(Icons.arrow_forward),
                title:
                    Text(_setting.setting.appLocalization?.camera ?? 'Camera'),
              ),
              ListTile(
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  Navigator.pop(context);
                  _imageNotifier.value =
                      await _picker.pickImage(source: ImageSource.gallery);
                },
                title: Text(
                    _setting.setting.appLocalization?.gallery ?? 'Gallery'),
              ),
            ],
          ),
        ));
  }

  void _openOfferOwnersDialog() async {
    List<User>? res;
    _offerOwner=await showDialog(
      context: context,
      builder:(context)=> Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        child: SizedBox(
              width: _responsive.responsiveWidth(forUnInitialDevices: 90),
              height: _responsive.responsiveHeight(forUnInitialDevices: 50),
              child: FutureBuilder<List<User>?>(
                  future: DataBaseApi.getOffersOwners(),
                  builder: (context, snapshot) {
                    res=snapshot.data;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                          width:
                              _responsive.responsiveWidth(forUnInitialDevices: 80),
                          height:
                              _responsive.responsiveHeight(forUnInitialDevices: 50),
                          child: const Loader());
                    } else if (snapshot.hasData&&snapshot.data!=null) {
                      return StatefulBuilder(
                        builder:(c,rebuild)=> SizedBox(
                          width: _responsive.responsiveWidth(forUnInitialDevices: 90),
                          height:
                              _responsive.responsiveHeight(forUnInitialDevices: 50),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SearchField(
                                  onChanged: (value) {
                                    if(value==''){
                                      rebuild(() {
                                        res=snapshot.data;
                                      });
                                    } else {
                                      rebuild(() {
                                        res = snapshot.data?.where((element) =>
                                            element.name.toLowerCase().contains(
                                                value.toLowerCase())).toList();
                                      });
                                    }
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment: WrapCrossAlignment.start,
                                    runSpacing: 10 ,
                                    spacing: 10,
                                    children: res!.map((user) => Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: UserCard(
                                        onTap: (){
                                          Navigator.of(context).pop(user);
                                        },
                                        imageUrl: user.imageUrl,
                                        name: user.name,
                                      width: _responsive.responsiveWidth(forUnInitialDevices: 10),),
                                    )).toList(),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                          child: Text(
                        _setting.setting.appLocalization?.thereIsNoDataToDisplay ??
                            "There is no data to show",
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ));
                    }
                  }),
            ),
      ),);
    if(_offerOwner!=null) {
      _offerOwnerController.text=_offerOwner!.name;
    }

  }

  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(milliseconds: 200),
        () => _cameraController
            .forward()
            .whenComplete(() => _cameraController.stop()));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: _scaffoldController,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: _responsive.responsiveWidth(forUnInitialDevices: 30),
                  height: _responsive.responsiveWidth(forUnInitialDevices: 30),
                  child: InkWell(
                    onTap: _pickImage,
                    child: ValueListenableBuilder<XFile?>(
                        valueListenable: _imageNotifier,
                        builder: (context, snapshot, child) {
                          if (snapshot == null) {
                            return Stack(
                              fit: StackFit.loose,
                              children: [
                                SizedBox(
                                  width: _responsive.responsiveWidth(
                                      forUnInitialDevices: 30),
                                  child: Lottie.asset('assets/lottie/camera.json',
                                      controller: _cameraAnimation,
                                      fit: BoxFit.fill),
                                ),
                                Positioned(
                                    bottom: _responsive.responsiveWidth(
                                        forUnInitialDevices: 8),
                                    right: _responsive.responsiveWidth(
                                        forUnInitialDevices: 1),
                                    child: Icon(
                                      Icons.add,
                                      color:
                                          _setting.setting.theme.textFieldColor,
                                    ))
                              ],
                            );
                          } else {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                File(snapshot.path),
                                fit: BoxFit.fill,
                              ),
                            );
                          }
                        }),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hintText:
                      _setting.setting.appLocalization?.offerName ?? "Offer Name",
                  onChanged: (name) {
                    if (name != null) {
                      _offerName = name;
                    }
                  },
                  validator: (value) {
                    if (value == null||_offerName=='') {
                      return _setting
                              .setting.appLocalization?.thisFieldIsRequired ??
                          "This field is required";
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('%',style: TextStyle(
                          fontSize: 14,
                          color: _setting.setting.theme.bodyTextColor
                        ),),
                      ),
                    ],
                  ),
                  hintText: _setting.setting.appLocalization?.offerValue ??
                      "Offer value",
                  onChanged: (value) {
                    if (value != null) {
                      _offerValue = double.tryParse(value) ?? -2;
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return _setting
                              .setting.appLocalization?.thisFieldIsRequired ??
                          "This field is required";
                    } else if (double.tryParse(value) == null ||
                        _offerValue < 0||_offerValue>100) {
                      return _setting
                              .setting.appLocalization?.youMustEnterOnlyNumber ??
                          "You must enter only number between 0.0 and 100.0 in this field";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  enabled: false,
                  onTap: _openOfferOwnersDialog,
                  hintText: _setting.setting.appLocalization?.offerOwner ??
                      "Offer owner",
                  controller: _offerOwnerController,
                  validator: (value) {
                    if (value == null||_offerOwner==null) {
                      return _setting
                              .setting.appLocalization?.thisFieldIsRequired ??
                          "This field is required";
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('('+(_setting.setting.appLocalization?.optional??"Optional")+')',
                        style: _setting.setting.theme.bodyTextStyle,),
                      ),
                    ],
                  ),
                  hintText: _setting.setting.appLocalization?.totalCapacity ??
                      "Total Capacity",
                  onChanged: (value){
                    if(value!=null) {
                      _totalCapacity=double.tryParse(value)??-1;
                    }
                  },
                  validator: (value) {
                    if (value == null||value=='') {
                      return null;
                    } else if (double.tryParse(value) == null||_totalCapacity<0) {
                      return _setting
                              .setting.appLocalization?.youMustEnterOnlyPositiveNumber ??
                          "You must enter only number in this field";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  maxLine: 4,
                  minLine: 1,
                  hintText: _setting.setting.appLocalization?.description ??
                      "Description",
                  onChanged: (value){
                    if(value!=null) {
                      _description = value;
                    }
                  },
                  validator: (value) {
                    if (value == null||_description=='') {
                      return _setting
                              .setting.appLocalization?.thisFieldIsRequired ??
                          "This field is required";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                ValueListenableBuilder<List<Widget>>(
                    valueListenable: _info,
                    builder: (c, value, child) {
                      return Column(
                        children:[
                          ListTile(
                            title: Text(_setting
                                .setting.appLocalization?.addAnotherInfo ??
                                "Add another info"),
                            trailing: IconButton(
                              onPressed: () {
                                GlobalKey<FormState> _dialogValidate =
                                GlobalKey();
                                String? title;
                                String? info;
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return Dialog(
                                      insetPadding: const EdgeInsets.all(4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Form(
                                          key: _dialogValidate,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(_setting
                                                      .setting
                                                      .appLocalization
                                                      ?.enterAllInfoYouNeed ??
                                                      "Enter all info that you need")),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                        width: _responsive
                                                            .responsiveWidth(
                                                            forUnInitialDevices:
                                                            40),
                                                        child: CustomTextField(
                                                          onChanged: (value) {
                                                            title = value;
                                                          },
                                                          hintText: _setting
                                                              .setting
                                                              .appLocalization
                                                              ?.title ??
                                                              "Title",
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value == '') {
                                                              return _setting
                                                                  .setting
                                                                  .appLocalization
                                                                  ?.thisFieldIsRequired ??
                                                                  "This field is required";
                                                            }
                                                            return null;
                                                          },
                                                        )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                        width: _responsive
                                                            .responsiveWidth(
                                                            forUnInitialDevices:
                                                            40),
                                                        child: CustomTextField(
                                                          onChanged: (value) {
                                                            info = value;
                                                          },
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value == '') {
                                                              return _setting
                                                                  .setting
                                                                  .appLocalization
                                                                  ?.thisFieldIsRequired ??
                                                                  "This field is required";
                                                            }
                                                            return null;
                                                          },
                                                          hintText: _setting
                                                              .setting
                                                              .appLocalization
                                                              ?.info ??
                                                              "Info",
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text(_setting
                                                        .setting
                                                        .appLocalization
                                                        ?.cancel ??
                                                        "Cancel"),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 8.0),
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        if ((_dialogValidate
                                                            .currentState
                                                            ?.validate() ??
                                                            false) &&
                                                            title != null &&
                                                            info != null) {
                                                          _infoList.add({
                                                            "title": title,
                                                            "info": info,
                                                          });
                                                          Key key = UniqueKey();
                                                          List<Widget> temp = _info
                                                              .value
                                                              .sublist(_info.value
                                                              .isNotEmpty
                                                              ? 1
                                                              : 0);
                                                          _info.value = [];
                                                          temp.add(Column(
                                                            key: key,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                                children: [
                                                                  SizedBox(
                                                                      width: _responsive.responsiveWidth(
                                                                          forUnInitialDevices:
                                                                          60),
                                                                      child: Text(
                                                                        title!,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                            15,
                                                                            color: _setting
                                                                                .setting
                                                                                .theme
                                                                                .textFieldColor),
                                                                      )),
                                                                  IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        _info.value.removeWhere((element) =>
                                                                        element
                                                                            .key ==
                                                                            key);
                                                                        List<Widget>
                                                                        temp =
                                                                        _info
                                                                            .value
                                                                            .sublist(1);
                                                                        _info.value =
                                                                        [];
                                                                        _info.value =
                                                                            temp;
                                                                      },
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .delete))
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  width: _responsive
                                                                      .responsiveWidth(
                                                                      forUnInitialDevices:
                                                                      90),
                                                                  child: Text(
                                                                    info!,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        12,
                                                                        color: _setting
                                                                            .setting
                                                                            .theme
                                                                            .bodyTextColor),
                                                                  ))
                                                            ],
                                                          ));
                                                          _info.value = temp;
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                      child: Text(_setting
                                                          .setting
                                                          .appLocalization
                                                          ?.submit ??
                                                          "Submit"),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ...value
                        ],
                      );
                    }),
                ValueListenableBuilder<bool>(
                    valueListenable: _loading,
                    builder: (context, value, child) {
                      return value?const Loader():ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              primary: _setting.setting.theme.iconsColor),
                          onPressed: () async {
                            bool? complete;
                            if ((_formKey.currentState?.validate()??false)&&_imageNotifier.value != null &&
                                _offerValue != -1 &&
                                _description!=''  &&
                                _offerOwner!=null&&
                                _offerName != '' &&
                                _totalCapacity != -1) {
                               complete = await showCustomDialog<bool>(
                                  context,
                                  height: _responsive.responsiveHeight(
                                      forUnInitialDevices: 50),
                                  width: _responsive.responsiveWidth(
                                      forUnInitialDevices: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(width: _responsive.responsiveWidth(forUnInitialDevices: 50),),
                                            Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                SizedBox(
                                                  width:_responsive.responsiveWidth(forUnInitialDevices: 90),
                                                  height: _responsive.responsiveHeight(forUnInitialDevices: 30),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(15),
                                                    child: Image.file(
                                                      File(_imageNotifier.value!.path),
                                                      width: double.infinity,
                                                      height: _responsive.responsiveHeight(
                                                          forUnInitialDevices: 30),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(_offerValue.toString()+'%',
                                                    style: _setting.setting.theme.bodyTextStyle,),
                                                  color: Colors.black.withOpacity(0.4),
                                                  padding:const EdgeInsets.all(8),
                                                )
                                              ],
                                            ),
                                            Text(_offerName,
                                              style: const TextStyle(
                                                  fontSize: 24
                                              ),),
                                            Row(
                                              children: [
                                                Image.asset('assets/placeHolder/user_placeHolder.png',width: _responsive.responsiveWidth(forUnInitialDevices:4),
                                                  height:  _responsive.responsiveWidth(forUnInitialDevices: 4),),
                                                 const    Padding(
                                                  padding:  EdgeInsets.symmetric(horizontal: 8.0),
                                                  child:  Text(':'),
                                                ),
                                                Text(_offerOwner!.name),
                                              ],
                                            ),
                                            Visibility(
                                                visible: _totalCapacity>0,
                                                child: Text((_setting.setting.appLocalization?.totalCapacity??"Total capacity")+": "+_totalCapacity.toString())),

                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(_description),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ElevatedButton(onPressed: (){
                                                Navigator.of(context).pop(false);
                                              }, child: Text(_setting.setting.appLocalization?.cancel??'Cancel')),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ElevatedButton(onPressed: (){
                                                Navigator.of(context).pop(true);
                                              }, child: Text(_setting.setting.appLocalization?.submit??'Submit')),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ));
                            } else {
                              _scaffoldController.showError(_setting.setting
                                      .appLocalization?.youMustFillAllField ??
                                  "You must fill all field");
                            }
                           if((complete??false)){
                             _loading.value=true;
                             await DataBaseApi.createNewOffer(offerName: _offerName, offerValue: _offerValue, offerOwnerId: _offerOwner!.id, totalCapacity: _totalCapacity, description: _description, info: _infoList);
                             _loading.value=false;
                           }
                          },
                          child: Text(_setting.setting.appLocalization?.submit ??
                              "Submit"));
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

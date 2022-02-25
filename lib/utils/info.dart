


import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
List<Map<String,String>> userTypes=[];


void buildInfo(BuildContext context){
  userTypes=[
    {"name":AppLocalizations.of(context)?.student ?? 'Student',"value":UserType.student.toString()},
    {"name":AppLocalizations.of(context)?.offerOwner ?? 'Offer Owner',"value":UserType.owner.toString()},
    {"name":AppLocalizations.of(context)?.manager ?? 'Manager',"value":UserType.manager.toString()},
    {"name":AppLocalizations.of(context)?.subCenter ?? 'Manager',"value":UserType.subscriptionCenter.toString()},
  ];

}


enum UserType{

  student,
  owner,
  manager,
  subscriptionCenter
}
import 'package:flutter/material.dart';


Future showCustomDialog<T extends Object>(context,
    {required Widget child,required double width
      ,required double height}) async {
  T? result = await showGeneralDialog<T?>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: 'j',
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, animation, animation1, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
          alignment: Alignment.center,
        );
      },
      pageBuilder: (context, animation, animation1) =>
          Padding(
            padding:  EdgeInsets.only(
              left:width/2,
              right: width/2,
              top: height/2,
              bottom: height/2
            ),
            child: StatefulBuilder(
              builder:(c,reBuild)=> Material(
                type: MaterialType.canvas,
                clipBehavior: Clip.hardEdge,
                animationDuration: const Duration(milliseconds: 500),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: child,
              ),
            ),
          ));
  return result;
}
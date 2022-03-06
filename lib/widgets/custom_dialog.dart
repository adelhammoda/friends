import 'package:flutter/material.dart';


Future showCustomDialog<T extends Object>(context,
    {required Widget child, barrierDismissible= true}) async {
  T? result = await showGeneralDialog<T?>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: barrierDismissible,
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
          StatefulBuilder(
            builder:(c,reBuild)=> Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  type: MaterialType.canvas,
                  clipBehavior: Clip.hardEdge,
                  animationDuration: const Duration(milliseconds: 500),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: child,
                ),
              ],
            ),
          ));
  return result;
}
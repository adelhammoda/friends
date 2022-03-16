import 'package:flutter/material.dart';


enum NavigatorBehavior{

  downToTop,
  leftToRight,
  rightToLeft,
  topToDown,


}

class _CustomNavigator extends PageRouteBuilder {
  final Widget child;
  final NavigatorBehavior behavior;

   _CustomNavigator({
     required this.child,RouteSettings? settings,
     this.behavior=NavigatorBehavior.leftToRight})
      : super(
        transitionDuration: const Duration(milliseconds: 400),
       // transitionsBuilder: ,
       settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) =>child);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    Offset begin,end;
    if(behavior==NavigatorBehavior.downToTop){
      begin=const Offset(0.0,1.0);
      end=Offset.zero;
    }
    else if(behavior==NavigatorBehavior.topToDown){
      end=Offset.zero;
      begin=const Offset(0.0,-1.0);
    }
    else if(behavior==NavigatorBehavior.rightToLeft){
      begin=const Offset(-1.0,0.0);
      end= Offset.zero;
    }
    else {
      begin=const Offset(1.0,0.0);
      end= Offset.zero;
    }
    return SlideTransition(position:Tween(
      begin:begin,
      end:end
    ).animate(animation),child: child,);
  }
}


class Go {
  static to(BuildContext context,Widget child,{NavigatorBehavior behavior=NavigatorBehavior.leftToRight}){
    Navigator.of(context).push(_CustomNavigator(child: child,behavior: behavior));
  }

  static toAndReplace(BuildContext context,Widget child,{NavigatorBehavior behavior=NavigatorBehavior.leftToRight}){
  Navigator.of(context).pushReplacement(_CustomNavigator(child: child,behavior: behavior));
  }


  static pop(BuildContext context){
    Navigator.of(context).pop();
  }


}
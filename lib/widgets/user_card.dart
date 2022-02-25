


import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double width;
  final void Function()? onTap;
  const UserCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    this.width=10,
    this.onTap,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            width: width,
            height: width,
            child: FadeInImage(
              image:NetworkImage(
                imageUrl??''
              ),
              placeholder:const AssetImage(
                'assets/placeHolder/user_placeHolder.png'
              ) ,
              fit: BoxFit.fill,
              placeholderErrorBuilder:(c,_,__)=> Image.asset(
                  'assets/placeHolder/user_placeHolder.png'
              ),
              imageErrorBuilder:(c,o,stackTrack)=> Image.asset(
                  'assets/placeHolder/user_placeHolder.png'
              ) ,
            ),
          ),
          Text(name,style:const TextStyle(fontSize: 15),),
        ],
      ),
    );
  }
}

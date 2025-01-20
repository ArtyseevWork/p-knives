import 'package:pknives/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'knife/knife_layout.dart';

Widget pageTitle({
  void Function()? backFun,
  Widget? leftWidget,
  Widget? rightWidget,
}){
  return Container(
    width: double.infinity,

    child: Stack(
      children: [
        if (backFun != null) backButton(backFun),
        if (leftWidget != null) Positioned(left: 0,child: leftWidget),
        const Center(
          child: Text(
            "Angel of Knife",
            style: TextStyle(
              fontSize:36,
              fontWeight: FontWeight.bold,
              fontFamily: "DancingScript",
              color: clrBlue,
              decoration: TextDecoration.underline,
              decorationColor: clrBlue, // цвет подчеркивания
              decorationStyle: TextDecorationStyle.solid, // стиль подчеркивания
              decorationThickness: 1.0, // толщина подчеркивания
            ),
          ),
        ),
        if (rightWidget != null) Positioned(right: 0,child: rightWidget),
      ],
    ),
  );
}

Widget  background(Widget child){
  return Container(
    padding: const EdgeInsets.only(
      left: 20,
      right: 20
    ),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [clrWhite, clrBlue], // Цвета градиента
      ),
    ),
    child:SafeArea(child: child),
  );
}

Widget backButton(void Function() backFunction){
  return TextButton(
      onPressed: backFunction,
      child: const Icon(
        Icons.arrow_back_ios,
        color: clrBlue,
        size: 40 ,
      )
  );
}

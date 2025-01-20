
import 'package:pknives/values/colors.dart';
import 'package:flutter/material.dart';

class KnivesLayout {
  static const double fieldHeight              = 48;
  static const double fieldDistance            = 20;
  static const double topLineSize              = 3;
  static const double addButtonMargin          = 24;
  static const double addButtonSize            = 64;
  static const double itemPadding              = 10;
  static const double itemBorderWidth          = 1;
  static const double fieldFontSize            = 20;
  static const double titleFontSize            = 45;
  static const double addTestDataHeight        = 60;
  static const double addTestDataRadius        = 24;
  static const double knifeImageSize           = 90;
  static const double shadowBlur               = 4;
  static const double shadowOffsetY            = 4;
  static const double shadowOpacity            = 0.25;
  static const int    gridColumns              = 2;
  static const double gridCrossAxisSpacing     = 1.0;
  static const double gridMainAxisSpacing      = 10.0;
  static const double gridChildAspectRatio     = 0.97;
  static const int    knifeNameMaxLines        = 2;
  static const double icnSize                  = 48;
  static const double subTitleFontSize          = 36;
  static const double titleDecorationThickness = 1;

  static TextStyle textStyleMain = const TextStyle(
    color: clrBlue,
    fontFamily: "Gamestation",
    fontSize: fieldFontSize,
    fontWeight: FontWeight.w400,
    height: 0.9,
  );

  static TextStyle textStyleTitle = const TextStyle(
    color: clrWhite,
    fontFamily: "Gamestation",
    fontSize: titleFontSize,
    fontWeight: FontWeight.w400,
  );

}
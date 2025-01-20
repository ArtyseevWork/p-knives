import 'package:pknives/values/colors.dart';
import 'package:flutter/material.dart';

class ProfileLayout {

  static const double mainAreaHorizontalMargin = 35;
  static const double mainAreaVerticalMargin = 120;
  static const double mainAreaPadding = 35;
  static const double mainAreaRadius = 24;
  static const double mainAreaShadowOpacity = 0.5;
  static const double mainAreaShadowBlur = 10;
  static const double mainAreaShadowOffSetY = 10;
  static const double createAccountAreaMargin = 15;
  static const double createAccountAreaFontSize = 24;
  static const double titleIconTopMargin = 62;
  static const double titleIconSize = 120;
  static const double sizeBox1 = 22;
  static const double googleSignInButtonSize = 34;
  static const double iconSize = 48;
  static const double accountAreaTitleFontSize = 32;
  static const double accountAreaFontSize = 24;


  static const double buttonHeight = 60;
  static const double buttonHorizontalMargin = 35;
  static const double buttonPadding = 22;
  static const double buttonRadius = 24;
  static const double buttonBorderWidth = 2;
  static const double buttonIconTextSize = 24;
  static const double deleteAccountButtonBottomMargin = 16;
  static const double deleteAccountButtonFontSize = 16;
  static const double backButtonIconSize = 40;

  static TextStyle textStyle(double size){
    return TextStyle(
        fontSize: size,
        fontFamily: "Gamestation",
        color: clrBlue
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:ui';

Widget loader({
  double size = 50.0,
  Color loaderColor = Colors.white,
  double strokeWidth = 4.0,
  Color backgroundColor = Colors.black54, // Полупрозрачный фон
  double blurAmount = 5.0, // Сила размытия
}) {
  return Stack(
    children: [
      // Затемнённый и заблюренный фон
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            color: backgroundColor,
          ),
        ),
      ),
      // Лоадер по центру
      Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: loaderColor,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    ],
  );
}
import 'dart:ui';
import 'package:pknives/values/colors.dart';
import 'package:flutter/material.dart';
import 'layout.dart';

class DialogWindow{

  static void showWindow(
      BuildContext context,
      {
        String? title,
        required String text,
        void Function()? yesButtonAction,
        String? yesButtonText,
        void Function()? noButtonAction,
        String? noButtonText,
      }) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(WindowLayout.backGroundOpacity),
      barrierDismissible: true,
      barrierLabel: text,
      transitionDuration: const Duration(
          milliseconds: WindowLayout.popUpDuration
      ),
      pageBuilder: (context, animation1, animation2) {
        return BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: WindowLayout.popUpSigma,
              sigmaY: WindowLayout.popUpSigma
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WindowLayout.popUpRadius),
            ),
            child: Container(
              padding: const EdgeInsets.all(WindowLayout.popUpPadding),
              margin: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width ,
              decoration: BoxDecoration(
                color: clrWhite,
                borderRadius: BorderRadius.circular(WindowLayout.popUpRadius),
              ),
              child: SingleChildScrollView(

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        text,
                        style: const TextStyle(
                          fontSize: WindowLayout.popUpFontSize,
                          color: clrBlack,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: WindowLayout.popUpDistance,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _noButton(
                          context,
                          noButtonAction,
                          noButtonText
                        ),
                        const SizedBox(width: WindowLayout.popUpButtonsDistance),
                        if (yesButtonAction != null) _yesButton(
                          context,
                          yesButtonAction,
                          yesButtonText
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _noButton(
      BuildContext context,
      void Function()? action,
      String? title) {
    if (title == null || title == ""){
      title = "No";
    }
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Закрываем диалог
           if (action != null){
             action();
           } // Выполняем действие
        },
        child: Container(
          height:  WindowLayout.popUpButtonsHeight,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(WindowLayout.popUpButtonMargin),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(WindowLayout.popUpButtonRadius),
            border: Border.all(
              color: clrGreen,
              width: WindowLayout.popUpButtonBorderWidth,
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
                color: clrGreen,
                fontSize: WindowLayout.popUpFontSize,
                fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }

  static Widget _yesButton(
      BuildContext context,
      void Function() action,
      String? title) {
    if (title == null || title == ""){
      title = "Yes";
    }
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Закрываем диалог
          action(); // Выполняем действие
        },
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(WindowLayout.popUpButtonMargin),
          height: WindowLayout.popUpButtonsHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: clrRed,
            borderRadius: BorderRadius.circular(WindowLayout.popUpButtonRadius),
          ),
          child: Text(
            title,
            style: const TextStyle(
                color: clrWhite,
                fontSize: WindowLayout.popUpFontSize,
                fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }
}

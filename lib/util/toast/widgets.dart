import 'package:pknives/values/colors.dart';
import 'package:flutter/material.dart';
import '../../values/strings/localizer.dart';
import 'layout.dart';

class ToastUI {
  final Map<String, double> _layout = Layout.get();

  SnackBar successInfo(
      String text,
      BuildContext context,
    ) {
    return _message(
      text: text,
      title: 'Success',
      background: clrBlack
    );
  }

  SnackBar info(
      String text,
      BuildContext context,
    ) {
    return _message(
        text: text,
        title: '',
        background: clrBlack
    );
  }

  SnackBar deleteMessage(
      void Function() callback,
      BuildContext context,
      ) {
    return deleteSnackBar(
      callback,
      context,
    );
  }


  SnackBar error(String text) {
    return _message(
      text: text,
      title: 'Something went wrong!',
      background: clrRed
    );
  }

  SnackBar _message({
    required String text,
    required String title,
    required Color  background,
  }) {
    return snackBar(title, text, background);
  }

  Widget _messageText(String text) {
    return Text(Localizer.get(text),
      style: TextStyle(
        height:   _layout['line_height'],
        fontSize: _layout['font_size'],
        fontWeight: FontWeight.w400,
        color: clrWhite,
      ),
    );
  }

  Widget _messageTitle(String text) {
    return Text(Localizer.get(text),
      style: TextStyle(
        fontSize: _layout['title_font_size'],
        height:   _layout['line_height'],
        fontWeight: FontWeight.w700,
        color: clrWhite,
      ),
    );
  }


  SnackBar deleteSnackBar (
      void Function() callback,
      BuildContext context,
      ){
    return SnackBar(
      showCloseIcon: false,
      backgroundColor: Colors.transparent,
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      //margin: EdgeInsets.all(_layout['margin'] ?? 0),
      margin: EdgeInsets.all(0),
      content: Row(
        children: [
          Expanded(
            flex: 85,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: clrBlack,
                borderRadius: BorderRadius.circular(_layout['frame_radius'] ?? 0),
              ),
              child: Row(
                children: [
                  Expanded(child: _messageText("Line deleted")),
                  TextButton(
                    onPressed: (){
                      callback();
                    },
                    child: Text(
                      "Undo",
                      style: TextStyle(
                        color: clrGreen,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    )
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 15,
              child: IconButton(icon: Icon(
                Icons.close,
                color: clrBlack,
              ),
                onPressed: (){ScaffoldMessenger.of(context).hideCurrentSnackBar();},
            )
          )
        ],
      ),
    );
  }

  SnackBar snackBar (
      String title,
      String text,
      Color background,
      ){
    return SnackBar(
      showCloseIcon: false,
      closeIconColor: background,
      backgroundColor: Colors.transparent,
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      margin: EdgeInsets.all(60),
      content: Center(child: _messageText(text)),
    );
  }
}
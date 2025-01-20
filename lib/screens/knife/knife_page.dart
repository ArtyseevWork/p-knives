
import 'dart:ui';
import 'package:pknives/core/models/knife.dart';
import 'package:pknives/core/models/statItem.dart';
import 'package:pknives/core/mvvm/observer.dart';
import 'package:pknives/screens/general.dart';
import 'package:pknives/screens/knife/knife_layout.dart';
import 'package:pknives/screens/knives/knives_page.dart';
import 'package:pknives/screens/sharpen/sharpen_page.dart';
import 'package:pknives/util/app_settings.dart';
import 'package:pknives/util/dialog_window/dialog_window.dart';
import 'package:pknives/util/unix_time_helper.dart';
import 'package:pknives/values/colors.dart';
import 'package:pknives/values/strings/localizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../pay_wall/pay_wall_page.dart';
import 'knife_view_model.dart';

class KnifePage extends StatefulWidget {
  const KnifePage( {required this.knife, super.key});

  final Knife knife;

  @override
  State<KnifePage> createState() => _KnifePageState();
}

enum TextFieldType{
  name,
  description,
}

class _KnifePageState extends State<KnifePage>  implements EventObserver {
  final KnifeViewModel _model = KnifeViewModel();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _model.onLoad(widget.knife);
    _model.subscribe(this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _model.unsubscribe(this);
  }
  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void notify() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult : (bool didPop, result){
        backFunction();
      },
      child: Scaffold(
        body: background(
           Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                SingleChildScrollView(
                  child:Column(
                    children: [
                      header,
                      if (Options.isPremiumAccount) imageArea,
                      fieldsArea,
                      if (!Options.isPremiumAccount) premiumButton,
                      if (Options.isPremiumAccount) historyAreaTitle,
                      if (Options.isPremiumAccount) historyArea,
                    ],
                  ),
                ),
                bottomButtons,
              ],
           ),
        ),
      ),
    );
  }

  Widget nameField(){
    return GestureDetector(
      onTap: (){_onEdit(TextFieldType.name);},
      child: _dataField(
        Localizer.get('activity_knife_name'),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: KnifeLayout.dataFieldMargin),
            child: Text(
              _model.knife.name,
              textAlign: TextAlign.end,
              style: KnifeLayout.textStyle1,
              overflow: TextOverflow.ellipsis,
              maxLines: KnifeLayout.nameFieldMaxLines,
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget angleField(){
    return _dataField(
        Localizer.get('activity_knife_angel'),
      Row(
        children: [
          TextButton(
            onPressed: (){
              setState(() {
                if ( _model.knife.angle <= KnifeLayout.rightAngle &&
                     _model.knife.angle > 1){
                  _model.knife.angle--;
                }
              });
            },
            child:const Icon(Icons.arrow_back_ios_sharp),
          ),
          Text(
            _model.knife.angle.toString(),
            textAlign: TextAlign.end,
            style: KnifeLayout.textStyle1,
          ),
          TextButton(
            onPressed: (){
              setState(() {
                if ( _model.knife.angle < KnifeLayout.rightAngle &&
                     _model.knife.angle >= 1){
                  _model.knife.angle++;
                }
              });
            },
            child: const Icon(Icons.arrow_forward_ios_sharp),
          ),
        ],
      ),
    );
  }

  Widget typeField(){
    return _dataField(
      Localizer.get('activity_knife_sharpening_type'),
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/icn_type_1.svg',
            height: KnifeLayout.knifeTypeIconSize,
            width:  KnifeLayout.knifeTypeIconSize,
          ),
          Switch(
            value: _model.knife.doubleSideSharp,
            onChanged: (value) {
              setState(() {
                _model.knife.doubleSideSharp = value;
              });
            },
            activeColor: clrGreen,
            activeTrackColor: clrBlack,
            inactiveThumbColor: clrRed,
            inactiveTrackColor: clrBlack,
          ),
          SvgPicture.asset(
            'assets/images/icn_type_2.svg',
            height: KnifeLayout.knifeTypeIconSize,
            width:  KnifeLayout.knifeTypeIconSize,
          ),
        ],
      ),
    );
  }

  Widget dateField() {
    final statistic = _model.statistic;
    final hasStatistic = statistic.isNotEmpty;

    return _dataField(
      Localizer.get('activity_knife_date'),
      Text(
        hasStatistic
            ? convertUnixTimeToDateTime(statistic[0].date ?? 0)
            : '-',
        textAlign: TextAlign.end,
        style: KnifeLayout.textStyle1,
      ),
    );
  }

  Widget descriptionField() {
    return GestureDetector(
      onTap: () {
        _onEdit(TextFieldType.description);
      },
      child: _dataField(
        Localizer.get('activity_knife_description'),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(
                left: KnifeLayout.descriptionLeftMargin
            ),
            child: Text(
              _model.knife.description,
              textAlign: TextAlign.start,
              style: KnifeLayout.textStyle1,
              overflow: TextOverflow.ellipsis,
              maxLines: KnifeLayout.descriptionMaxLines,
              //overflow: TextOverflow.visible, // Позволяет тексту переноситься
              softWrap: true, // Включает перенос текста
            ),
          ),
        ),
      ),
    );
  }



  Widget _dataField(String title, Widget child){
    return Container(
      margin: const EdgeInsets.symmetric(vertical: KnifeLayout.dataFieldMargin),
      padding: const EdgeInsets.symmetric(
          horizontal: KnifeLayout.dataFieldPadding
      ),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: clrWhite,
        border: Border.symmetric(horizontal: BorderSide(color: clrBlue,
          width: KnifeLayout.dataFieldBorderWidth,)
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: KnifeLayout.textStyle2,
          ),
          child,
        ],
      ),
    );
  }


  Widget get bottomButtons{
    return Container(
      margin: const EdgeInsets.symmetric(vertical: KnifeLayout.bottomButtonMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:[
          _bottomButton(
            Localizer.get("activity_knife_delete"),
            clrRed,
                (){
              DialogWindow.showWindow(
                  context,
                  text: Localizer.get("activity_knife_delete_message"),
                  yesButtonAction: () {
                    _model.deleteKnife();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const KnivesPage()),
                    );
                  },
                  yesButtonText: Localizer.get('activity_knife_yes'),
                  noButtonText: Localizer.get('activity_knife_no'),
              );
            }
          ),
          Container(),
          _bottomButton(
            Localizer.get("activity_knife_sharpen"),
            clrGreen,
            (){
              _model.saveKnife((){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SharpenPage(knife: _model.knife)
                    )
                );
              });
            }
          ),
        ]
      ),
    );
  }


  Widget _bottomButton(String text, Color color, void Function() action){
    return GestureDetector(
      onTap: action,
      child: Container(
        height: KnifeLayout.bottomButtonHeight,
        width:  KnifeLayout.bottomButtonWidth,
        padding:const EdgeInsets.all(KnifeLayout.bottomButtonPadding),
        decoration:BoxDecoration(
          color:color,
          borderRadius:BorderRadius.circular(KnifeLayout.bottomButtonRadius),
        ),
        child:Center(child: Text(text))
      ),
    );
  }


  void _onEdit(
      TextFieldType textFieldType,
  ) {
    String initText = "";
    if (textFieldType == TextFieldType.name){
      initText = _model.knife.name;
    } else if (textFieldType == TextFieldType.description){
      initText = _model.knife.description;
    }

    TextEditingController controller = TextEditingController(text: initText);

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(KnifeLayout.backGroundOpacity),
      transitionDuration: const Duration(
          milliseconds: KnifeLayout.popUpDuration
      ),
      pageBuilder: (context, animation1, animation2) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: KnifeLayout.popUpSigma,
            sigmaY: KnifeLayout.popUpSigma
        ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KnifeLayout.popUpRadius),
            ),
            child: Container(
              padding: const EdgeInsets.all(KnifeLayout.popUpPadding),
              //margin: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: clrWhite,
                borderRadius: BorderRadius.circular(KnifeLayout.popUpRadius),
              ),
              child: SingleChildScrollView(

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        Localizer.get('activity_knife_edit'),
                        style: const TextStyle(
                          fontSize: KnifeLayout.popUpFontSize,
                          color: clrBlack,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: KnifeLayout.popUpDistance,),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: KnifeLayout.popUpEditLineHorizontalPadding,
                          vertical: KnifeLayout.popUpEditLineVerticalPadding
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            KnifeLayout.popUpButtonRadius
                        ),
                        border: Border.all(
                          color: clrBlack,
                          width: KnifeLayout.popUpButtonBorderWidth,
                        ),
                      ),
                      child: TextField(
                        cursorColor: clrBlack,
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: Localizer.get("activity_knife_enter_text"),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(height: KnifeLayout.sizedBox1,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cancelButton(),
                        const SizedBox(width: KnifeLayout.sizedBox2,),
                        saveButton(controller, textFieldType),
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

  Widget cancelButton() {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          height:  KnifeLayout.popUpButtonsHeight,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(KnifeLayout.popUpButtonMargin),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(KnifeLayout.popUpButtonRadius),
            border: Border.all(
              color: clrRed,
              width: KnifeLayout.popUpButtonBorderWidth,
            ),
          ),
          child: Text(
            Localizer.get('activity_knife_cansel'),
            style: const TextStyle(
                color: clrBlack,
                fontSize:  KnifeLayout.popUpFontSize,
                fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }

  Widget saveButton(TextEditingController controller,
      TextFieldType textFieldType
      ) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          if (controller.text.trim().isEmpty) return;
          String newText = controller.text;
          if (textFieldType == TextFieldType.name){
            _model.knife.name = newText;
          } else if (textFieldType == TextFieldType.description){
           _model.knife.description = newText;
          }
          Navigator.of(context).pop();
          setState(() {});
        },
        child: Container(
          height:  KnifeLayout.popUpButtonsHeight,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(KnifeLayout.popUpButtonMargin),
          width: double.infinity,
          decoration: BoxDecoration(
            color: clrGreen,
            borderRadius: BorderRadius.circular(KnifeLayout.popUpButtonRadius),
          ),
          child: Text(
            Localizer.get('activity_knife_save'),
            style: const TextStyle(
                color: clrWhite,
                fontSize: KnifeLayout.popUpFontSize,
                fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }

  Widget get imageFromGalleryButton{
    return IconButton(
      onPressed: (){_model.getImage(ImageSource.gallery);},
      icon: const Icon(
        Icons.image_search,
        size: KnifeLayout.imageButtonSize,
        color: clrBlue,
      ),
    );
  }


  Widget get imageFromCameraButton{
    return IconButton(
      onPressed: (){_model.getImage(ImageSource.camera);},
      icon: const Icon(
        Icons.camera_alt,
        size: KnifeLayout.imageButtonSize,
        color: clrBlue,
      ),
    );
  }


  Widget get deleteImageButton{
    return IconButton(
      onPressed: (){
        if (_model.imagePreview != null){
          DialogWindow.showWindow(
            context,
            text: Localizer.get("activity_knife_delete_image_message"),
            yesButtonAction: () {
              _model.removeImage();
            },
            yesButtonText: Localizer.get('activity_knife_yes'),
            noButtonText: Localizer.get('activity_knife_no'),
          );
        }
      },
      icon: const Icon(
        Icons.delete_forever,
        size: KnifeLayout.imageButtonSize,
        color: clrBlue,
      ),
    );
  }

  Widget get header{
    return Column(
      children: [
        pageTitle(backFun: (){
          _model.saveKnife((){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const KnivesPage()
              ),
            );
          });
        }),
        const SizedBox(height: KnifeLayout.sizedBox3,),
        Container(
          color: clrBlue,
          height: KnifeLayout.topLineSize,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget get imageArea {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: KnifeLayout.imageAreaVerticalMargin,
        horizontal: KnifeLayout.imageAreaHorizontalMargin,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: KnifeLayout.dataFieldPadding,
      ),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: clrWhite,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: clrBlue,
            width: KnifeLayout.dataFieldBorderWidth,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: KnifeLayout.imagePreviewSize,
            height: KnifeLayout.imagePreviewSize,
            child: _model.imagePreview != null
                ? Image.file(
              _model.imagePreview!,
              fit: BoxFit.cover,
            )
                : Center(
                child: Text(
                  Localizer.get("activity_knife_no_image")
                )
            ),
          ),
          Column(
            children: [
              deleteImageButton,
              imageFromCameraButton,
              imageFromGalleryButton,
            ],
          ),
        ],
      ),
    );
  }

  Widget get fieldsArea{
    return Column(
      children: [
        nameField(),
        angleField(),
        typeField(),
        if (!Options.isPremiumAccount) dateField(),
        descriptionField(),
      ],
    );
  }

  Widget get historyAreaTitle {
    var textColour = clrWhite;
    var backgroundColour = clrBlue;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(KnifeLayout.historyAreaPadding),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: clrWhite,
            border: Border.symmetric(
              horizontal: BorderSide(
                color: clrBlue,
                width: KnifeLayout.dataFieldBorderWidth,
              )
            ),
          ),
          child: Text(
            Localizer.get("History of sharpening"),
            textAlign: TextAlign.center,
            style: KnifeLayout.textStyle1,
            overflow: TextOverflow.ellipsis
           ),
        ),
        Container(
          padding: const EdgeInsets.all(KnifeLayout.historyAreaPadding),
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColour,
            border: const Border.symmetric(
              horizontal: BorderSide(
                color: clrBlue,
                width: KnifeLayout.dataFieldBorderWidth,
              )
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(Localizer.get("activity_knife_date"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: KnifeLayout.fieldFontSize,
                    color: textColour,
                  ),
                  overflow: TextOverflow.ellipsis
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  Localizer.get("activity_knife_angel"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: KnifeLayout.fieldFontSize,
                    color: textColour,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget get historyArea {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _model.statistic.length,
      itemBuilder: (BuildContext context, int index) {
        return listItem(_model.statistic[index], index);
      },
    );
  }

  Widget listItem(StatItem statItem, int index){
    var textColour = clrWhite;
    var backgroundColour = clrBlue;
    if (index % 2 == 0) {
      textColour = clrBlue;
      backgroundColour = clrWhite;
    }

    return Container(
      padding: const EdgeInsets.all(KnifeLayout.historyAreaPadding),
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColour,
        border: const Border.symmetric(horizontal: BorderSide(color: clrBlue,
          width: KnifeLayout.dataFieldBorderWidth,)
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 200,
            child: Text(
                textAlign: TextAlign.center,
                convertUnixTimeToDateTime(statItem.date),
                style: TextStyle(
                  fontSize: KnifeLayout.fieldFontSize,
                  color: textColour,
                ),
                overflow: TextOverflow.ellipsis
            ),
          ),
          Expanded(
              flex: 1,
              child: Container(color: clrWhite,)
          ),
          Expanded(
            flex: 100,
            child: Text(
              textAlign: TextAlign.center,
              statItem.angle.toString(),
              style: TextStyle(
                fontSize: KnifeLayout.fieldFontSize,
                color: textColour,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get premiumButton{
    return GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PayWallPage())
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: KnifeLayout.premiumButtonMargin),
        padding: const EdgeInsets.all(KnifeLayout.premiumButtonPadding),
        decoration: const BoxDecoration(
          color: clrWhite,
          border: Border.symmetric(horizontal: BorderSide(color: clrBlue,
            )
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/premium_icon.png",
                width: KnifeLayout.premiumIconWidth,
                height: KnifeLayout.premiumIconHeight),
            Text(
              Localizer.get('activity_knife_premium_button'),
              style: const TextStyle(
                color: clrBlue,
                fontFamily: "DancingScript",
                fontSize: KnifeLayout.premiumButtonFontSize,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: clrBlue,
                decorationThickness:
                  KnifeLayout.premiumButtonDecorationThickness,
                decorationStyle: TextDecorationStyle.solid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void backFunction(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const KnivesPage()
      ),
    );
  }

}
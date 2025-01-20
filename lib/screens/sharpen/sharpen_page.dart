import 'dart:async';
import 'dart:ui';
import 'package:pknives/core/models/knife.dart';
import 'package:pknives/screens/knife/knife_page.dart';
import 'package:pknives/screens/sharpen/sharpen_layout.dart';
import 'package:pknives/screens/sharpen/sharpen_view_model.dart';
import 'package:pknives/util/app_settings.dart';
import 'package:pknives/util/toast/widgets.dart';
import 'package:pknives/values/strings/localizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pknives/core/mvvm/observer.dart';
import 'package:pknives/values/colors.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;
import 'package:pknives/screens/general.dart';

import '../pay_wall/pay_wall_page.dart';

class SharpenPage extends StatefulWidget {
  final Knife knife;
  const SharpenPage({super.key, required this.knife});

  @override
  State<SharpenPage> createState() => SharpenPageState();
}

class SharpenPageState extends State<SharpenPage> implements
    EventObserver,
    WidgetsBindingObserver
{
  final SharpenViewModel _model = SharpenViewModel();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final ToastUI toastUI = ToastUI();
  bool _isAppActive = true;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _model.onLoad(widget.knife);
    _model.subscribe(this);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _accelerometerSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        if (_isAppActive ) {
          _processEvent(event);
        }
    });
  }

  void _processEvent(AccelerometerEvent event) {
      _model.processAxis(event);
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accelerometerSubscription?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return  PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        backFunction();
      },
      child: Scaffold(
        body: background(
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              title(),
              knifeInfo(),
              mainArea(),
              bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void notify() {
    if (_model.toastMessage.isNotEmpty){
      showMessageToast(
          _model.toastMessage
      );
      _model.toastMessage = "";
    }
    setState(() {});
  }

  Widget knifeInfo() {
    TextStyle textStyle = const TextStyle(
        fontSize: SharpenLayout.textSize,
        fontFamily: "Gamestation",
        color: clrBlack);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal:SharpenLayout.horizontalPadding),
      width: SharpenLayout.knifeInfoWidthLine,
      decoration: const BoxDecoration(
        color: clrWhite,
        border: Border.symmetric(
            horizontal: BorderSide(
              color: clrBlue,
              width: SharpenLayout.strokeWidth,
            )),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_model.knife.name, style: textStyle,),
          if (_model.knife.doubleSideSharp)
            Text(
                "${_model.knife.angle}/2 = ${_model.knife.angle/2}",
                style: textStyle
            )
          else
            Text(
                _model.knife.angle.toString(),
                style: textStyle
            ),
        ],
      ),
    );
  }

  Widget mainArea() {
    return Expanded(
        child: Stack(
          children: [
            levelImage(),
            knifeLevelImage(),
          ],
        ));
  }

  Widget bottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Options.isPremiumAccount ? levelButtonPremium() : levelButton(),
        textLevel(),
        doneButton(),
      ],
    );
  }

  Widget levelImage() {
    return Center(
      child: Transform.rotate(
        angle: (360 -(_model.levelDegree)) * (math.pi / 180),
        child: SvgPicture.asset(
          'assets/images/level_image.svg',
          width: double.infinity,
        ),
      ),
    );
  }

  Widget knifeLevelImage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Transform.rotate(
          angle: (360 - (_model.sensorDegree )) * (math.pi / 180),
          child: SvgPicture.asset(
            'assets/images/knife_level.svg',
            height: SharpenLayout.knifeLevelImageHeight,
            width: double.infinity,
            color: _model.rightAngle? clrRed : clrBlue,
          ),
        ),
      ),
    );
  }

  Widget levelButton() {
    return GestureDetector(
      onTap: (){
        _model.setLevel();
      },
      child: Container(
          width: SharpenLayout.buttonWidth,
          height: SharpenLayout.buttonHeight,
          margin: const EdgeInsets.all(SharpenLayout.largeMargin),
          decoration: BoxDecoration(
            color: clrGreen,
            borderRadius: BorderRadius.circular(SharpenLayout.borderRadius),
          ),
          child: Center(
              child: Text(
                Localizer.get("activity_angle_level"),
                style:  const TextStyle(
                  fontSize: SharpenLayout.textSize,
                  fontFamily: "Gamestation",
                  color: clrWhite),
              ),
          )
      ),
    );
  }

  Widget textLevel() {
    return Container(
      alignment: Alignment.center,
      width: SharpenLayout.circleSize,
      height: SharpenLayout.circleSize,
      decoration: BoxDecoration(
        color: _model.rightAngle? clrRed : clrWhite,
        shape: BoxShape.circle, // Форма круга
      ),
      child: Text(
        textAlign: TextAlign.center,
        _model.displayDegree.toStringAsFixed(1),
        style: const TextStyle(
          color: clrBlue,
          fontSize:SharpenLayout.textSize,
          fontWeight: FontWeight.bold,
          fontFamily:'Gamestation',
        ),
      ),
    );
  }

  Widget doneButton() {
    TextStyle textStyle = const TextStyle(
        fontSize: SharpenLayout.textSize,
        fontFamily: "Gamestation",
        color: clrWhite);
    return GestureDetector(
      onTap:(){
        _model.saveKnife((){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => KnifePage(knife: _model.knife)
            ),
          );
        });

      } ,
      child: Container(
          width: SharpenLayout.doneButtonWidth,
          height: SharpenLayout.doneButtonHeight,
          margin: const EdgeInsets.all(SharpenLayout.smallMargin),
          decoration: BoxDecoration(
            color: clrGreen,
            borderRadius: BorderRadius.circular(SharpenLayout.borderRadius),
          ),
          child: Center(
              child: Text(
                Localizer.get("activity_angle_done"),
                style: textStyle,
              )
          )
      ),
    );
  }


  Widget title() {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: backButton(backFunction),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              Localizer.get("app_name"),
              style: const TextStyle(
                fontSize: SharpenLayout.titleFontSize,
                fontWeight: FontWeight.bold,
                fontFamily: "DancingScript",
                color: clrBlue,
                decoration: TextDecoration.underline,
                decorationColor: clrBlue,
                decorationStyle: TextDecorationStyle.solid,
                decorationThickness: SharpenLayout.strokeWidth,
              ),
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (Options.isPremiumAccount) holdButton(),
              if (Options.isPremiumAccount) changeAxisButton(),
              if ( !Options.isPremiumAccount) premiumButton
            ],
          ),
        ),
      ],
    );
  }

  Widget holdButton(){
    Color color = clrBlue.withAlpha(125);
    if(_model.isHoldLevel){
      color = clrBlue;
    }

    return TextButton(
      onPressed: (){
        setState(() {
          _model.setHoldLevel();
        });
        },
      child: Column(
        children: [
          Text(
            Localizer.get("activity_angle_hold_button"),
            style: TextStyle(
              fontFamily: "Gamestation",
              fontSize: SharpenLayout.mediumTextSize,
              color: color,
            ) ,
          ),
          Container(
            height: SharpenLayout.strokeWidth,
            width: SharpenLayout.holdButtonWidth,
            color: color,),
          Text(
            Localizer.get("activity_angle_level"),
            style: TextStyle(
                fontFamily: "Gamestation",
                color: color,
                fontSize: SharpenLayout.smallTextSize
            ),
          ),
        ],
      )

    );
  }

  Widget changeAxisButton(){
    return TextButton(
        onPressed: (){
          _model.changeAxis();
        },
        child: const Icon(
          Icons.view_in_ar,
          color: clrBlue,
          size: SharpenLayout.changeAxisIconSize,
        )
    );
  }

  Widget levelButtonPremium() {
    return Column(
      children: [
        Row(
          children: [
              GestureDetector(
                onTap: (){
                  _model.resetLevel();
                },
                child: Container(
                    width: SharpenLayout.smallButtonWidth,
                    height: SharpenLayout.smallButtonHeight,
                    margin: const EdgeInsets.only(
                        left: SharpenLayout.smallMargin,
                        right: SharpenLayout.smallMargin,
                        bottom: SharpenLayout.minimalMargin
                    ),
                    decoration: BoxDecoration(
                      color: clrWhite,
                      borderRadius: BorderRadius.circular(SharpenLayout.smallBorderRadius),
                    ),
                    child: const Icon(Icons.cached, color: clrBlue,),
                ),
              ),
            GestureDetector(
              onTap: (){
                _model.setLevel();
              },
              child: Container(
                width: SharpenLayout.standardTouchSize,
                height: SharpenLayout.standardTouchSize,
                margin: const EdgeInsets.only(
                    left: SharpenLayout.smallMargin,
                    right: SharpenLayout.smallMargin,
                    bottom: SharpenLayout.minimalMargin),
                decoration: BoxDecoration(
                  color: clrWhite,
                  borderRadius: BorderRadius.circular(
                      SharpenLayout.smallBorderRadius
                  ),
                ),
                child: const Icon(Icons.save, color: clrBlue,),
              ),
            ),
          ],
        ),
        Container(
            color: clrWhite,
            height: SharpenLayout.strokeWidth,
            width:SharpenLayout.levelButtonPremiumWidth
        ),
        Text(
          Localizer.get("activity_angle_level"),
          style: const TextStyle(color: clrWhite),
        ),
        const SizedBox(height: SharpenLayout.smallPadding,)
      ],
    );
  }


  Widget get premiumButton {
    return GestureDetector(
      onTap: (){
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PayWallPage()),
        );
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(SharpenLayout.mediumPadding),
        margin: const EdgeInsets.only(top: SharpenLayout.largeMargin),
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
            Image.asset(
                "assets/images/premium_icon.png",
                width: SharpenLayout.standardTouchSize,
                height: SharpenLayout.premiumIconHeight
            ),
            Text(
              Localizer.get('activity_knife_premium_button'),
              style: const TextStyle(
                color: clrBlue,
                fontFamily: "DancingScript",
                fontSize: SharpenLayout.premiumTextSize,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: clrBlue,
                decorationThickness: SharpenLayout.strokeWidth,
                decorationStyle: TextDecorationStyle.solid,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void showMessageToast(String message){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      toastUI.info(message,context),
    );
  }

  void backFunction() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => KnifePage(knife: _model.knife)
      ),
    );
  }

  @override
  void didChangeAccessibilityFeatures() {
    // TODO: implement didChangeAccessibilityFeatures
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppActive = true;
    } else {
      _isAppActive = false;
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // TODO: implement didChangeLocales
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
  }

  @override
  void didChangePlatformBrightness() {
    // TODO: implement didChangePlatformBrightness
  }

  @override
  void didChangeTextScaleFactor() {
    // TODO: implement didChangeTextScaleFactor
  }

  @override
  void didChangeViewFocus(ViewFocusEvent event) {
    // TODO: implement didChangeViewFocus
  }

  @override
  void didHaveMemoryPressure() {
    // TODO: implement didHaveMemoryPressure
  }

  @override
  Future<bool> didPopRoute() {
    // TODO: implement didPopRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRoute(String route) {
    // TODO: implement didPushRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    // TODO: implement didPushRouteInformation
    throw UnimplementedError();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() {
    // TODO: implement didRequestAppExit
    throw UnimplementedError();
  }

  @override
  void handleCancelBackGesture() {
    // TODO: implement handleCancelBackGesture
  }

  @override
  void handleCommitBackGesture() {
    // TODO: implement handleCommitBackGesture
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    // TODO: implement handleStartBackGesture
    throw UnimplementedError();
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    // TODO: implement handleUpdateBackGestureProgress
  }

}

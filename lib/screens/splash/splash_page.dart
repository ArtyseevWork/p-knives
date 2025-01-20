import 'dart:async';

import 'package:pknives/core/mvvm/observer.dart';
import 'package:pknives/screens/knives/knives_page.dart';
import 'package:pknives/screens/splash/splash_layout.dart';
import 'package:pknives/screens/splash/splash_view_model.dart';
import 'package:pknives/util/app_settings.dart';
import 'package:pknives/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>  implements EventObserver {

  final _model  = SplashViewModel();
  late Timer _timer;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _model.subscribe(this);
    _model.onLoad();
    startTimer();
    super.initState();
  }

  void startTimer(){
    _timer = Timer(Delays.splash, () {
      _model.finishTimer = true;
      notify();
    });
  }

  @override
  void notify() {
    if(_model.finishTimer && _model.finishDataLoad){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KnivesPage()),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _model.unsubscribe(this);
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    _model.unsubscribe(this);
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          color: clrWhite,
          padding: const EdgeInsets.all(SplashLayout.logoPadding),
          child: Center(
            child: Image.asset(
              'assets/images/logo.png',
            ),
          ),
        ),
      ),
    );
  }

}

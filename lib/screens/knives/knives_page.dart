import 'dart:async';
import 'dart:io';
import 'package:pknives/screens/general.dart';
import 'package:pknives/screens/knives/knives_layout.dart';
import 'package:pknives/screens/pay_wall/pay_wall_page.dart';
import 'package:pknives/screens/profile/profile_page.dart';
import 'package:pknives/util/app_settings.dart';
import 'package:pknives/values/strings/localizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pknives/core/models/knife.dart';
import 'package:pknives/core/mvvm/observer.dart';
import 'package:pknives/values/colors.dart';
import 'package:pknives/screens//knife/knife_page.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_svg/svg.dart';
import 'knives_view_model.dart';


class KnivesPage extends StatefulWidget {
  const KnivesPage({super.key});

  @override
  State<KnivesPage> createState() => _KnivesPageState();
}

class _KnivesPageState extends State<KnivesPage>  implements EventObserver {
  final KnivesViewModel _model = KnivesViewModel();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _model.subscribe(this);
    _model.onLoad();
    super.initState();
  }

  @override
  void notify() {
    setState(() {});
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: exit,
      child: Scaffold(
        body: Stack(
          children: [
            background(
              Column(
                children:[
                  title(),
                  mainArea(),
                ],
              ),
            ),
            newKnifeButton(),
          ],
        ),
      ),
    );
  }

  Widget title(){
    return Column(
      children:[
        pageTitle(),
        const SizedBox(height: KnivesLayout.fieldDistance,),
        Container(
          color: clrBlue,
          height: KnivesLayout.topLineSize,
          width: double.infinity,
        ),
        const SizedBox(height: KnivesLayout.fieldDistance),
      ]
    );
  }

  Widget mainArea(){
    if (!_model.showLoader && _model.knives.isEmpty){
      return addTestDataButton();
    } else if (!_model.showLoader) {
      return Expanded(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: KnivesLayout.gridColumns,
            crossAxisSpacing: KnivesLayout.gridCrossAxisSpacing,
            mainAxisSpacing:  KnivesLayout.gridMainAxisSpacing ,
            childAspectRatio: KnivesLayout.gridChildAspectRatio,
          ),
          itemCount: _model.knives.length,
          itemBuilder: (BuildContext context, int index) {
            return listItem(_model.knives[index]);
          }
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget newKnifeButton(){
    return Positioned(
      right: KnivesLayout.addButtonMargin,
      bottom:  KnivesLayout.addButtonMargin,
      child: TextButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KnifePage(
                  knife : Knife.getDefaultKnife()
              )
            )
          );
        },
        child: SvgPicture.asset(
          'assets/images/btn_new_knife.svg',
          height: KnivesLayout.addButtonSize,
          width:  KnivesLayout.addButtonSize,
        ),
      ),
    );
  }

  Widget listItem(Knife knife){
    return Card(
      child: InkWell(
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KnifePage(knife : knife))
          );
        },
        child: Container(
          padding: const EdgeInsets.all(KnivesLayout.itemPadding),
          decoration: const BoxDecoration(
            color: clrWhite,
            border: Border.symmetric(horizontal: BorderSide(color: clrBlue,
              width: KnivesLayout.itemBorderWidth,)
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              centerOfItem(knife),
              Expanded(
                child: Center(
                  child: Text(
                      textAlign: TextAlign.center,
                      knife.name,
                      style: KnivesLayout.textStyleMain,
                      maxLines: KnivesLayout.knifeNameMaxLines,
                      overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget centerOfItem(Knife knife){
    if (Options.isPremiumAccount && knife.image.isNotEmpty){
      return Container(
      alignment: Alignment.center,
      width: KnivesLayout.knifeImageSize,
      height: KnivesLayout.knifeImageSize,
      decoration: BoxDecoration(
        color: clrBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(KnivesLayout.shadowOpacity),
            spreadRadius: 0,
            blurRadius: KnivesLayout.shadowBlur,
            offset: const Offset(0, KnivesLayout.shadowOffsetY),
          ),
        ],
      ),
      child: Image.file(
        File(knife.image),
        fit: BoxFit.cover,
        width: KnivesLayout.knifeImageSize,
        height: KnivesLayout.knifeImageSize,
      ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: KnivesLayout.knifeImageSize,
        height: KnivesLayout.knifeImageSize,
        decoration: BoxDecoration(
          color: clrBlue,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(KnivesLayout.shadowOpacity),
              spreadRadius: 0,
              blurRadius: KnivesLayout.shadowBlur,
              offset: const Offset(0, KnivesLayout.shadowOffsetY),
            ),
          ],
        ),
        child: Text(
          knife.angle.toString(),
          style: KnivesLayout.textStyleTitle,
        ),
      );
    }

  }

  Widget addTestDataButton(){
    return GestureDetector(
      onTap: _model.addTestData,
      child: Container(
        height:KnivesLayout.addTestDataHeight,
        width: double.infinity,
        decoration:BoxDecoration(
          color:clrGreen,
          borderRadius:BorderRadius.circular(KnivesLayout.addTestDataRadius),
        ),
        child: Center(
          child: Text(Localizer.get("add_test_data_button"))
        )
      ),
    );
  }

  Widget profileButton(){
    return iconButton(
      icon: Icons.person,
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage())
        );
      }
    );
  }

  Widget shoppingButton(){
    return iconButton(
      icon: Icons.shopping_cart_rounded,
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PayWallPage())
        );
      }
    );
  }

  Future<bool> exit() async{
    final shouldPop = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Localizer.get("exit_dialog_title")),
          content: Text(Localizer.get("exit_dialog_text")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(Localizer.get("cancel")),
            ),
            TextButton(
                onPressed: () {
                  FlutterExitApp.exitApp();
                },
                child: Text(Localizer.get("exit")),
            ),
          ],
        );
      },
    );
    return shouldPop ?? false;
  }


  Widget pageTitle(){
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          shareButton(),
          Options.isPremiumAccount? profileButton() : shoppingButton(),
          Center(
            child: Text(
              Localizer.get("app_name"),
              style: const TextStyle(
                fontSize:KnivesLayout.subTitleFontSize,
                fontWeight: FontWeight.bold,
                fontFamily: "DancingScript",
                color: clrBlue,
                decoration: TextDecoration.underline,
                decorationColor: clrBlue,
                decorationStyle: TextDecorationStyle.solid,
                decorationThickness: KnivesLayout.titleDecorationThickness,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget shareButton(){
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      child: IconButton(
        onPressed: _model.shareApp,
        icon: const Icon(
          Icons.share,
          size: KnivesLayout.icnSize,
          color: clrBlue,
        )
        ),
    );
  }

  Widget rightButton(){
    return Positioned(
      top: 0,
      right: 0,
      child: TextButton(
          onPressed: _model.shareApp,
          child: const Icon(Icons.share)
      ),
    );
  }

  Widget iconButton({required IconData icon, required VoidCallback onPressed}) {
    return Positioned(
      top: 0,
      right: 0,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: KnivesLayout.icnSize,
          color: clrBlue,
        ),
      ),
    );
  }

}

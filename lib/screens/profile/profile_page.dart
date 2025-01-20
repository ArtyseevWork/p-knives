import 'package:pknives/core/mvvm/observer.dart';
import 'package:pknives/screens/knives/knives_page.dart';
import 'package:pknives/screens/loader.dart';
import 'package:pknives/screens/profile/profile_layout.dart';
import 'package:pknives/util/dialog_window/dialog_window.dart';
import 'package:pknives/values/colors.dart';
import 'package:pknives/values/strings/localizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'profile_view_model.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage( { super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>  implements EventObserver {
  final ProfileViewModel _model = ProfileViewModel();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _model.onLoad();
    _model.subscribe(this);
    super.initState();
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
  void notify() {
    if (_model.goToKnives){
      backFunction();
    }
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
        body: Stack(
          children:[
            mainArea(),
            titleIcon(),
            if (_model.user != null) deleteAccountButton,
            backButton,
            if (_model.showLoader) loader(),
          ],
        ),
      ),
    );
  }

  Widget mainArea(){
    return
        Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(
              horizontal: ProfileLayout.mainAreaHorizontalMargin,
              vertical: ProfileLayout.mainAreaVerticalMargin
          ),
          padding: const EdgeInsets.symmetric(
              vertical: ProfileLayout.mainAreaPadding
          ),
          decoration: BoxDecoration(
            color: clrGreenLight,
            borderRadius: BorderRadius.circular(
                ProfileLayout.mainAreaRadius
            ),
            boxShadow: [
              BoxShadow(
                color: clrBlue.withOpacity(
                  ProfileLayout.mainAreaShadowOpacity),
                  spreadRadius: 0,
                  blurRadius: ProfileLayout.mainAreaShadowBlur,
                  offset: const Offset(0, ProfileLayout.mainAreaShadowOffSetY),
              ),
            ],
          ),
          child:
          _model.user != null ? accountArea : createAccountArea
        );
  }

  Widget get createAccountArea{
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        Container(
          margin: const EdgeInsets.all(ProfileLayout.createAccountAreaMargin),
          child: Text(
            Localizer.get("activity_profile_login_text"),
            style: ProfileLayout.textStyle(
                ProfileLayout.createAccountAreaFontSize
            ),
          ),
        ),
        googleSignInButton
      ]
    );
  }

  Widget get accountArea{
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: ProfileLayout.sizeBox1,),
        Text(
          Localizer.get("activity_profile_your_account"),
          style: ProfileLayout.textStyle(
              ProfileLayout.accountAreaTitleFontSize
          ),
        ),
        if (_model.user.photoURL != null) CircleAvatar (
          backgroundImage: NetworkImage(_model.user.photoURL),
          radius: 48,
        ),
        if (_model.user.displayName != null) Text(
          _model.user!.displayName,
          style: ProfileLayout.textStyle(ProfileLayout.accountAreaFontSize),
        ),
        syncButton,
        exitButton,
      ],

    );
  }

  Widget get googleSignInButton{
    return
      _button(
        SvgPicture.asset(
            'assets/images/icn_google.svg',
            height: ProfileLayout.googleSignInButtonSize,
            width:  ProfileLayout.googleSignInButtonSize),
          Localizer.get("activity_profile_login_button_google"),
        _model.signInWithGoogle
      );
  }


  Widget get syncButton{
    return _button(
        const Icon(
          Icons.cloud_sync,
          size: ProfileLayout.iconSize,
          color: clrBlue,
        ),
        Localizer.get("activity_profile_button_button_sync"),
        _model.sync
    );
  }

  Widget get exitButton{
    return _button(
        const Icon(
          Icons.exit_to_app,
          size: ProfileLayout.iconSize,
          color: clrBlue,
        ),
        Localizer.get("activity_profile_button_button_log_out"),
        _model.signOut
    );
  }

  Widget _button (Widget icon, String text, Function() callback){
    return GestureDetector(
      onTap: callback,
      child: Container(
          height: ProfileLayout.buttonHeight,
          width: double.infinity,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(
              horizontal: ProfileLayout.buttonHorizontalMargin
          ),
          padding: const EdgeInsets.only(left: ProfileLayout.buttonPadding),
          decoration: BoxDecoration(
            color:  clrWhite,
            borderRadius: BorderRadius.circular( ProfileLayout.buttonRadius ),
            border: Border.all(
              color: clrBlue,
              width: ProfileLayout.buttonBorderWidth,
            ),
          ),
          child: Row(
            children: [
              icon,
              Expanded(child:
                Center(child:
                  Text(
                    text,
                    style: ProfileLayout.textStyle(
                        ProfileLayout.buttonIconTextSize
                    )
                  )
                )
              )
            ],
          ),
      )
    );
  }



  Widget titleIcon(){
    return Positioned(
      left: 0,
      right: 0,
      top: ProfileLayout.titleIconTopMargin,
        child:Image.asset(
            "assets/images/icn_title.png",
            width: ProfileLayout.titleIconSize,
            height: ProfileLayout.titleIconSize
        )
    );
  }

  Widget get deleteAccountButton{
    return Positioned(
      left: 0,
      right: 0,
      bottom: ProfileLayout.deleteAccountButtonBottomMargin,
      child: GestureDetector(

        child: TextButton(
            onPressed: (){
              DialogWindow.showWindow(
                context,
                text: Localizer.get("activity_profile_delete_profile"),
                yesButtonAction: () {
                  _model.deleteGoogleUser();
                },
                yesButtonText: Localizer.get('activity_knife_yes'),
                noButtonText: Localizer.get('activity_knife_no'),
              );
            },
            child: Text(
              Localizer.get("activity_profile_button_delete_account"),
              style: ProfileLayout.textStyle(
                  ProfileLayout.deleteAccountButtonFontSize
              ),
            )
        ),
      ),
    );
  }

  Widget get backButton{
    return Positioned(
      left: 0,
      top: 0,
      child: SafeArea(
        child: TextButton(
          onPressed: backFunction,
          child: const Icon(
            Icons.arrow_back_ios,
            color: clrBlue,
            size: ProfileLayout.backButtonIconSize ,
          )
        ),
      )
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
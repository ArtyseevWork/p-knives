
import 'package:pknives/core/mvvm/observer.dart';
import 'package:pknives/screens/knives/knives_page.dart';
import 'package:pknives/screens/pay_wall/pay_wall_layout.dart';
import 'package:pknives/util/adapty_helper.dart';
import 'package:pknives/util/app_settings.dart';
import 'package:pknives/util/toast/widgets.dart';
import 'package:pknives/values/colors.dart';
import 'package:pknives/values/strings/localizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pay_wall_view_model.dart';


class PayWallPage extends StatefulWidget {
  const PayWallPage( { super.key});
  @override
  State<PayWallPage> createState() => _PayWallPageState();
}

class _PayWallPageState extends State<PayWallPage>  implements EventObserver {
  final PayWallViewModel _model = PayWallViewModel();
  final ToastUI toastUI = ToastUI();

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
    if(Options.isPremiumAccount){
      showMessageToast(Localizer.get("paywall_success"),);
      goToMainPage();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!AdaptyHelper().productsWasLoaded){
      Navigator.pop(context);
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: PayWallLayout.paddingHorizontal,
            vertical: PayWallLayout.paddingVertical,
          ),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/pay_wall_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  buttonClose,
                  title,
                  description,
                  choiceArea,
                  buttonContinue,
                  bottomBar,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get buttonClose{
    return Container(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: (){
          Navigator.of(context).pop();
        },
        icon: Icon(
          Icons.cancel,
          color: clrWhite.withOpacity(PayWallLayout.borderOpacity),
          size: PayWallLayout.buttonCloseIconSize,
        )
      ),
    );
  }

  Widget get title{
    var x = Text(
      Localizer.get("paywall_title"),
      textAlign: TextAlign.center,
      style:
      const TextStyle(
        fontSize: PayWallLayout.titleFontSize,
        fontFamily: "Gamestation",
        color: clrBlue,
        decoration: TextDecoration.underline,
        decorationColor: clrBlue,
      ),
    );
    return rectangleWithShadow(x);
  }

  Widget get description{
    Widget child = Column(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        descriptionItem(Localizer.get("paywall_advantage_1"),),
        descriptionItem(Localizer.get("paywall_advantage_2"),),
        descriptionItem(Localizer.get("paywall_advantage_3"),),
        descriptionItem(Localizer.get("paywall_advantage_4"),)
      ],
    );
    return rectangleWithShadow(child);
  }

  Widget descriptionItem (String text){
    return Container(
      margin: const EdgeInsets.only(
          left: PayWallLayout.descriptionItemMarginLeft,
          top: PayWallLayout.descriptionItemMarginHorizontal,
          bottom: PayWallLayout.descriptionItemMarginHorizontal
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle,
            color: clrBlue,
            size: PayWallLayout.iconSize,
          ),
          const SizedBox(width: PayWallLayout.sizeBox1,),
          Text(text,
            softWrap: true,
            style: const TextStyle(
              fontSize: PayWallLayout.descriptionFontSize,
              fontFamily: "Gamestation",
              color: clrBlue,
              decorationColor: clrBlue,
            ),
          )
        ],
      ),
    );
  }

  Widget get choiceArea{
    if (_model.paywallProducts == null){
      return Container();
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _model.paywallProducts.length,
      itemBuilder: (context, index) {
        return  choiceItem(index);
      },
    );
  }

  Widget choiceItem(int index){
    var product = _model.paywallProducts[index];
    var borderColor = clrBlue;
    var borderWidth = PayWallLayout.borderWidth;
    if (index==_model.currentIndexOfProduct){
      borderColor = clrGreen2;
      borderWidth = PayWallLayout.borderWidthActive;
    }

    Widget child = Container(
      margin: const EdgeInsets.all(PayWallLayout.choiceItemMargin),
      padding: const EdgeInsets.symmetric(
          horizontal: PayWallLayout.choiceItemPadding
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            product.subscriptionDetails.localizedSubscriptionPeriod,
            style: const TextStyle(
              fontSize: PayWallLayout.choiceItemFontSize,
              fontFamily: "Gamestation",
              color: clrBlue,
              decorationColor: clrBlue,
            ),
          ),
          Column(
              children: [
                Text(
                    product.price.localizedString,
                    style: const TextStyle(
                      fontSize: PayWallLayout.choiceItemPriceFontSize,
                      fontFamily: "DancingScript",
                      color: clrBlue,
                      decorationColor: clrBlue,
                    )
                ),
                Text(
                  AdaptyHelper.getMonthPrice(product),
                  style: TextStyle(
                    fontSize: PayWallLayout.choiceItemPeriodFontSize,
                    fontFamily: "Gamestation",
                    color: clrBlue.withOpacity(
                        PayWallLayout.choiceItemTextOpacity
                    ),
                    decorationColor: clrBlue,
                  ),
                )
              ]
          )
        ],
      ),
    );

    return  GestureDetector(
      onTap: (){_model.choseProduct(index);},
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(
            horizontal: PayWallLayout.itemMarginHorizontal,
            vertical: PayWallLayout.itemMarginVertical
        ),
        decoration: BoxDecoration(
          color: clrWhite.withOpacity(PayWallLayout.shadowOpacity),
          borderRadius: BorderRadius.circular( PayWallLayout.borderRadius ),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: child
      ),
    );
  }

  Widget get buttonContinue{
    var textStyle  = const TextStyle(
      fontSize: PayWallLayout.buttonFontSize,
      fontFamily: "DancingScript",
      color: clrWhite,
      decorationColor: clrBlue,
    );

    return
      GestureDetector(
        onTap: _model.purchaseProduct,
        child: Container( height: PayWallLayout.buttonContinueHeight,
          width: double.infinity,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: clrGreen2,
            borderRadius: BorderRadius.circular( PayWallLayout.borderRadius ),

          ),
          child: Text(
            Localizer.get('paywall_button_continue'),
            style: textStyle,
          )
        ),
      );
  }

  Widget get bottomBar{
    const String url = "yourLink";
    return Center(
      child: GestureDetector(
        onTap: () async {
          _launchInBrowser(Uri.parse(url));
        },
        child: Text(
          Localizer.get('paywall_user_agreement'),
          style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline
          ),
        ),
      ),
    );
  }


  Future<void> _launchInBrowser(Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      showMessageToast('Failed to open link: $e');
    }
  }


  Widget rectangleWithShadow(Widget child, ){
    return
      Container(
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(PayWallLayout.margin),
        decoration: BoxDecoration(
          color: clrWhite.withOpacity(PayWallLayout.shadowOpacity),
          borderRadius: BorderRadius.circular( PayWallLayout.borderRadius ),
        ),
        child: child
      );
  }

  Widget rectangleWithBorder(Widget child){
    return
      Container(
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(
          horizontal: PayWallLayout.margin,
          vertical: PayWallLayout.itemMarginVertical
        ),
        decoration: BoxDecoration(
          color: clrWhite.withOpacity(PayWallLayout.shadowOpacity),
          borderRadius: BorderRadius.circular( PayWallLayout.borderRadius ),
          border: Border.all(
            color: clrBlue,
            width: PayWallLayout.borderWidth,
          ),
        ),
        child: child
      );
  }

  void goToMainPage(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const KnivesPage()
      ),
    );
  }

  void showMessageToast(String message){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      toastUI.info(message,context),
    );
  }
}
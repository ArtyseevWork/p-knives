class PreferencesKeys {
  static const String request = 'request';
  static const String tutorialPage = 'tutorial_page';
  static const String tutorialImage = 'tutorial_image';
  static const String enterCodeStringKey = "enterCodeStringKey";
  static const String levelValueStringKey = "levelValueStringKey";
  static const String levelIsHoldStringKey = "levelIsHoldStringKey";
}

class Sizes {
  static const double phoneMediumHeight = 860;
  static const double phoneMaxWidth = 480;
}

class Delays {
  static const Duration share  = Duration(milliseconds: 1000);
  static const Duration unlock = Duration(milliseconds: 300);
  static const Duration splash = Duration(milliseconds: 1500);
}

class Options {
  static bool isPremiumAccount = true;
  static bool syncEnable = true;
  static int emailMinLength = 6;
  static int emailMaxLength = 254;
  static int passwordMinLength = 8;
  static int passwordMaxLength = 50;
}

class GeneralValidator {
  static bool checkEmail(String email) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    return email.isNotEmpty && RegExp(pattern).hasMatch(email);
  }
}

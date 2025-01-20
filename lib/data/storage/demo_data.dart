import 'package:pknives/core/models/knife.dart';
import 'package:pknives/core/models/status.dart';
import 'package:pknives/data/repo/knife_repo.dart';
import 'package:pknives/values/strings/localizer.dart';

class DemoData{
  Future <void> addDemoData() async { //todo refactor
    var i = 1;
    await KnifeRepo().updateKnife(
      Knife(
        0,
        Localizer.get("demo_data_pocket_knife"),
        Localizer.get("demo_data_knife_description"),
        35,
        Status.STATUS_NEW_DEMO,
        true,
        0,
      ),
    );
    print("Knife $i was added");
    i++;
    await Future.delayed(const Duration(milliseconds: 1));

    await KnifeRepo().updateKnife(
      Knife(
        0,
        Localizer.get('demo_data_chef_knife'),
        Localizer.get("demo_data_knife_description"),
        30,
        Status.STATUS_NEW_DEMO,
        true,
        0,
      )
    );
    print("Knife $i was added");
    i++;
    await Future.delayed(const Duration(milliseconds: 1));

    // insertKnife(Knife(
    //   0,
    //   "Meat Knife",
    //   "This is a description of a meat knife",
    //   25,
    //   sharpeningTime,
    //   Status.STATUS_NEW,
    //   true,
    // ));

    await KnifeRepo().updateKnife(
      Knife(
        0,
        Localizer.get("demo_data_fish_knife"),
        Localizer.get("demo_data_knife_description"),
        20,
        Status.STATUS_NEW_DEMO,
        true,
        0,
      ),
    );
    print("Knife $i was added");
    i++;
    await Future.delayed(const Duration(milliseconds: 1));


    await KnifeRepo().updateKnife(
      Knife(
        0,
        Localizer.get("demo_data_fruit_knife"),
        Localizer.get("demo_data_knife_description"),
        15,
        Status.STATUS_NEW_DEMO,
        true,
        0,
      ),
    );
    print("Knife $i was added");
    i++;
    await Future.delayed(const Duration(milliseconds: 1));


    await KnifeRepo().updateKnife(
      Knife(
        0,
        Localizer.get("demo_data_utility_knife"),
        Localizer.get("demo_data_knife_description"),
        40,
        Status.STATUS_NEW_DEMO,
        true,
        0,
      ),
    );
    print("Knife $i was added");
    i++;
    await Future.delayed(const Duration(milliseconds: 1));


    await KnifeRepo().updateKnife(
      Knife(
        0,
        Localizer.get("demo_data_scissors"),
        Localizer.get("demo_data_knife_description"),
        70,
        Status.STATUS_NEW_DEMO,
        false,
        0,
      ),
    );
    print("Knife $i was added");
    i++;
  }
}

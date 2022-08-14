import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switch_profile_modes/services/cronjob_services.dart';
import 'package:switch_profile_modes/services/profile_mode_services.dart';
import 'package:switch_profile_modes/set_time_screen.dart';
import 'package:workmanager/workmanager.dart';

// Workmanger
const fetchBackground = "fetchBackground";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        // Code to run in background
        CronjobServices cronjobServices = CronjobServices();
        cronjobServices.activateAutoSwitching();

        //full function code of cronjobServices.autoSwitchBetweenTime();
        final ProfileModeServices profileModeServices = ProfileModeServices();
        final prefs = await SharedPreferences.getInstance();
        int? silentHour = prefs.getInt('silentHour');
        int? silentMins = prefs.getInt('silentMins');

        int? ringingHour = prefs.getInt('ringingHour');
        int? ringingMins = prefs.getInt('ringingMins');

        if (silentMins != null &&
            silentHour != null &&
            ringingHour != null &&
            ringingMins != null) {
          DateTime now = DateTime.now();
          DateTime silentTime =
              DateTime(now.year, now.month, now.day, silentHour, silentMins);
          DateTime ringingTime =
              DateTime(now.year, now.month, now.day, ringingHour, ringingMins);

          if (silentTime.isBefore(ringingTime)) {
            if (now.isAfter(silentTime) && now.isBefore(ringingTime)) {
              profileModeServices.setVibrateMode();
            } else if (now.isAfter(ringingTime) || now.isBefore(silentTime)) {
              profileModeServices.setNormalMode();
            }
          } else if (silentTime.isAfter(ringingTime)) {
            if (now.isAfter(silentTime) || now.isBefore(ringingTime)) {
              profileModeServices.setVibrateMode();
            } else if (now.isAfter(ringingTime) && now.isBefore(silentTime)) {
              profileModeServices.setNormalMode();
            }
          }
        }

        //full function code of autoSwitchBetweenTime

        break;
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await Workmanager().registerPeriodicTask(
    "1",
    fetchBackground,
    // frequency: const Duration(minutes: 1),
    // constraints: Constraints(
    //   networkType: NetworkType.connected,
    // ),
  );
  runApp(const MyApp());
}
// Workmanger

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auto mode switching',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SetTimeScreen(),
    );
  }
}

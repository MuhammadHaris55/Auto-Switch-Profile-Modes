import 'package:cron/cron.dart';
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
  Workmanager().executeTask((task, inputData) {
    CronjobServices cronjobServices = CronjobServices();
    cronjobServices.activateAutoSwitching();
    print("Work manager");

    // switch (task) {
    //   case fetchBackground:
    //     // Code to run in background
    //     print('start workmanager');
    //     Cron();
    //     final ProfileModeServices profileModeServices = ProfileModeServices();
    //     final CronjobServices cronjobServices = CronjobServices();

    //     final prefs = await SharedPreferences.getInstance();
    //     final int? silentHour = prefs.getInt('silentHour');
    //     final int? silentMins = prefs.getInt('silentMins');
    //     final int? ringingHour = prefs.getInt('ringingHour');
    //     final int? ringingMins = prefs.getInt('ringingMins');

    //     var dt = DateTime.now();
    //     if (silentHour != null &&
    //         silentMins != null &&
    //         ringingHour != null &&
    //         ringingMins != null) {
    //       if (dt.hour == silentHour && dt.minute == silentMins ||
    //           dt.minute > silentMins && dt.minute < ringingMins) {
    //         print(dt.minute);
    //         profileModeServices.setSilentMode();
    //         cronjobServices.activateAutoSwitching();
    //       }
    //       if (dt.hour == ringingHour && dt.minute == ringingMins) {
    //         profileModeServices.setNormalMode();
    //       }
    //     }
    //     // final CronjobServices cronjobServices = CronjobServices();
    //     // cronjobServices.activateAutoSwitching();
    //     print('end workmanager');
    //     //Cronjob --------------
    //     break;
    // }
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
    frequency: const Duration(minutes: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(const MyApp());
}
// Workmanger
// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   RingerModeStatus _soundMode = RingerModeStatus.unknown;
//   String? _permissionStatus;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentSoundMode();
//     _getPermissionStatus();
//   }
//
//   Future<void> _getCurrentSoundMode() async {
//     RingerModeStatus ringerStatus = RingerModeStatus.unknown;
//
//     Future.delayed(const Duration(seconds: 1), () async {
//       try {
//         ringerStatus = await SoundMode.ringerModeStatus;
//       } catch (err) {
//         ringerStatus = RingerModeStatus.unknown;
//       }
//
//       setState(() {
//         _soundMode = ringerStatus;
//       });
//     });
//   }
//
//   Future<void> _getPermissionStatus() async {
//     bool? permissionStatus = false;
//     try {
//       permissionStatus = await PermissionHandler.permissionsGranted;
//       print(permissionStatus);
//     } catch (err) {
//       print(err);
//     }
//
//     setState(() {
//       _permissionStatus =
//       permissionStatus! ? "Permissions Enabled" : "Permissions not granted";
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Switch profile modes'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text('Don\'t forget to add a permission line in AndroidManifest.xml'),
//             // <uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY"/>
//             SizedBox(height: 20.0),
//               Text('Running on: $_soundMode'),
//               Text('Permission status: $_permissionStatus'),
//               SizedBox(
//                 height: 20,
//               ),
//               ElevatedButton(
//                 onPressed: () => _getCurrentSoundMode(),
//                 child: Text('Get current sound mode'),
//               ),
//               ElevatedButton(
//                 onPressed: () => _setNormalMode(),
//                 child: Text('Set Normal mode'),
//               ),
//               ElevatedButton(
//                 onPressed: () => _setSilentMode(),
//                 child: Text('Set Silent mode'),
//               ),
//               ElevatedButton(
//                 onPressed: () => _setVibrateMode(),
//                 child: Text('Set Vibrate mode'),
//               ),
//               ElevatedButton(
//                 onPressed: () => _openDoNotDisturbSettings(),
//                 child: Text('Open Do Not Access Settings'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _setSilentMode() async {
//     RingerModeStatus status;
//
//     try {
//       status = await SoundMode.setSoundMode(RingerModeStatus.silent);
//
//       setState(() {
//         _soundMode = status;
//       });
//     } on PlatformException {
//       print('Do Not Disturb access permissions required!');
//     }
//   }
//
//   Future<void> _setNormalMode() async {
//     RingerModeStatus status;
//
//     try {
//       status = await SoundMode.setSoundMode(RingerModeStatus.normal);
//       setState(() {
//         _soundMode = status;
//       });
//     } on PlatformException {
//       print('Do Not Disturb access permissions required!');
//     }
//   }
//
//   Future<void> _setVibrateMode() async {
//     RingerModeStatus status;
//
//     try {
//       status = await SoundMode.setSoundMode(RingerModeStatus.vibrate);
//
//       setState(() {
//         _soundMode = status;
//       });
//     } on PlatformException {
//       print('Do Not Disturb access permissions required!');
//     }
//   }
//
//   Future<void> _openDoNotDisturbSettings() async {
//     await PermissionHandler.openDoNotDisturbSetting();
//   }
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
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const SetTimeScreen(),
      // home: const ProfileSwitch(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

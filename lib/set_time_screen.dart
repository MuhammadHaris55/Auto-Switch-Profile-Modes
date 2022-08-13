import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:switch_profile_modes/main.dart';
import 'package:switch_profile_modes/services/cronjob_services.dart';
import 'package:switch_profile_modes/services/profile_mode_services.dart';

class SetTimeScreen extends StatefulWidget {
  const SetTimeScreen({Key? key}) : super(key: key);

  @override
  State<SetTimeScreen> createState() => _SetTimeScreenState();
}

class _SetTimeScreenState extends State<SetTimeScreen> {
  final ProfileModeServices profileModeServices = ProfileModeServices();
  final CronjobServices cronjobServices = CronjobServices();

  TimeOfDay? time = const TimeOfDay(hour: 12, minute: 12);
  TimeOfDay? silentTime;
  TimeOfDay? ringingTime;

  // for sound modes
  String? _permissionStatus;
  RingerModeStatus _soundMode = RingerModeStatus.unknown;

  Future<void> _getPermissionStatus() async {
    String? permission;
    permission = await profileModeServices.getPermissionStatus();
    setState(() {
      _permissionStatus = permission;
    });
    debugPrint(_permissionStatus);
  }

  // for sound modes

  @override
  void initState() {
    super.initState();
    _getPermissionStatus();
    sharedPref();
  }

  void sharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final int? silentHour = prefs.getInt('silentHour');
    final int? silentMins = prefs.getInt('silentMins');
    final int? ringingHour = prefs.getInt('ringingHour');
    final int? ringingMins = prefs.getInt('ringingMins');
    if (silentHour != null &&
        silentMins != null &&
        ringingHour != null &&
        ringingMins != null) {
      silentTime = TimeOfDay(hour: silentHour, minute: silentMins);
      ringingTime = TimeOfDay(hour: ringingHour, minute: ringingMins);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 29, 201, 192),
                Color.fromARGB(255, 125, 221, 216),
              ],
              stops: [0.5, 1.0],
            ),
          ),
        ),
        title: const Text(
          'Auto Silent mode',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // actions: _permissionStatus == "Permissions Enabled"
        //     ? [
        //         IconButton(
        //           icon: const Icon(Icons.warning),
        //           onPressed: () =>
        //               profileModeServices.openDoNotDisturbSettings(),
        //         ),
        //       ]
        //     : [],
      ),
      body: _permissionStatus == null ||
              _permissionStatus == "Permissions not granted"
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Access require to change profile mode,'
                    '\n press "Grant Permission" to give access',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      primary: const Color.fromARGB(255, 29, 201, 192),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 29, 201, 192),
                        width: 2,
                      ),
                      shadowColor: const Color.fromARGB(255, 29, 201, 192),
                      backgroundColor: Colors.white,
                      elevation: 5,
                    ),
                    onPressed: () {
                      if (_permissionStatus == "Permissions Enabled") {
                        setState(() {});
                      } else {
                        profileModeServices.openDoNotDisturbSettings();
                      }
                    },
                    child: const Text('Permission granted'),
                  ),
                ],
              ),
            )
          : Container(
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/background_light.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Set time to activate silent mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  GestureDetector(
                    onTap: () async {
                      TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: time!,
                      );
                      if (newTime != null) {
                        setState(() {
                          silentTime = newTime;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt(
                            'silentHour', silentTime!.hour.toInt());
                        await prefs.setInt(
                            'silentMins', silentTime!.minute.toInt());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blueGrey,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Text(
                        silentTime == null
                            ? '${time!.hour.toString()} : ${time!.minute.toString()}'
                            : '${silentTime!.hour.toString()} : ${silentTime!.minute.toString()}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  const Text(
                    'Set time to activate ringing mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  GestureDetector(
                    onTap: () async {
                      TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: time!,
                      );
                      if (newTime != null) {
                        setState(() {
                          ringingTime = newTime;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt(
                            'ringingHour', ringingTime!.hour.toInt());
                        await prefs.setInt(
                            'ringingMins', ringingTime!.minute.toInt());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueGrey,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        ringingTime == null
                            ? '${time!.hour.toString()} : ${time!.minute.toString()}'
                            : '${ringingTime!.hour.toString()} : ${ringingTime!.minute.toString()}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: _permissionStatus == null ||
              _permissionStatus == "Permissions not granted"
          ? FloatingActionButton.extended(
              label: const Text(
                'Grant Permission',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 29, 201, 192),
              onPressed: () async {
                await _getPermissionStatus();
                if (_permissionStatus == "Permissions Enabled") {
                  setState(() {});
                } else {
                  profileModeServices.openDoNotDisturbSettings();
                  Future.delayed(const Duration(seconds: 10), () {
                    _getPermissionStatus();
                  });
                }
              },
            )
          : FloatingActionButton.extended(
              label: const Text(
                'Activate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 29, 201, 192),
              onPressed: () {
                if (ringingTime != null && silentTime != null) {
                  cronjobServices.activateAutoSwitching(
                      // silentTime: silentTime!,
                      // ringingTime: ringingTime!,
                      );
                  const snackBar = SnackBar(
                    content: Text('Auto silent and ringing acitvated'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  const snackBar = SnackBar(
                    content: Text('Select silent and ringing time first'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
    );
  }
}

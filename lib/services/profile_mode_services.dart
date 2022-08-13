import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

class ProfileModeServices {
  RingerModeStatus _soundMode = RingerModeStatus.unknown;
  // String? _permissionStatus;

  Future<RingerModeStatus> getCurrentSoundMode() async {
    RingerModeStatus ringerStatus = RingerModeStatus.unknown;

    Future.delayed(const Duration(seconds: 1), () async {
      try {
        ringerStatus = await SoundMode.ringerModeStatus;
      } catch (err) {
        ringerStatus = RingerModeStatus.unknown;
      }
      // setState(() { _soundMode = ringerStatus; });
    });
    return ringerStatus;
  }

  Future<String> getPermissionStatus() async {
    bool? permissionStatus = false;
    try {
      permissionStatus = await PermissionHandler.permissionsGranted;
      // print(permissionStatus);
    } catch (err) {
      // print(err);
    }

    // setState(() {
    // _permissionStatus =
    //     permissionStatus! ? "Permissions Enabled" : "Permissions not granted";
    // });
    return permissionStatus!
        ? "Permissions Enabled"
        : "Permissions not granted";
  }

  Future<RingerModeStatus> setSilentMode() async {
    RingerModeStatus status;

    try {
      status = await SoundMode.setSoundMode(RingerModeStatus.silent);

      // setState(() {
      _soundMode = status;
      // });
    } on PlatformException {
      debugPrint('Do Not Disturb access permissions required!');
    }
    return _soundMode;
  }

  Future<RingerModeStatus> setNormalMode() async {
    RingerModeStatus status;

    try {
      status = await SoundMode.setSoundMode(RingerModeStatus.normal);
      // setState(() {
      _soundMode = status;
      // });
    } on PlatformException {
      print('Do Not Disturb access permissions required!');
    }
    return _soundMode;
  }

  Future<RingerModeStatus> setVibrateMode() async {
    RingerModeStatus status;

    try {
      status = await SoundMode.setSoundMode(RingerModeStatus.vibrate);
      // setState(() {
      _soundMode = status;
      // });
    } on PlatformException {
      print('Do Not Disturb access permissions required!');
    }
    return _soundMode;
  }

  Future<void> openDoNotDisturbSettings() async {
    await PermissionHandler.openDoNotDisturbSetting();
  }
}

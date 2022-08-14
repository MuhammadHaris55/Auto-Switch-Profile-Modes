import 'package:cron/cron.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switch_profile_modes/services/profile_mode_services.dart';

class CronjobServices {
  Future<void> autoSwitchBetweenTime() async {
    final ProfileModeServices profileModeServices = ProfileModeServices();
    final prefs = await SharedPreferences.getInstance();
    final int? silentHour = prefs.getInt('silentHour');
    final int? silentMins = prefs.getInt('silentMins');

    final int? ringingHour = prefs.getInt('ringingHour');
    final int? ringingMins = prefs.getInt('ringingMins');

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
        }
        if (now.isAfter(ringingTime) || now.isBefore(silentTime)) {
          profileModeServices.setNormalMode();
        }
      }

      if (silentTime.isAfter(ringingTime)) {
        if (now.isAfter(silentTime) || now.isBefore(ringingTime)) {
          profileModeServices.setVibrateMode();
        }
        if (now.isAfter(ringingTime) && now.isBefore(silentTime)) {
          profileModeServices.setNormalMode();
        }
      }
    }
  }

  Future<void> autoSwitchingWorkmanger(
      // {required TimeOfDay silentTime, required TimeOfDay ringingTime}
      ) async {
    final ProfileModeServices profileModeServices = ProfileModeServices();
    final cron = Cron();

    final prefs = await SharedPreferences.getInstance();
    final int? silentHour = prefs.getInt('silentHour');
    final int? silentMins = prefs.getInt('silentMins');

    final int? ringingHour = prefs.getInt('ringingHour');
    final int? ringingMins = prefs.getInt('ringingMins');
    String? status = prefs.getString('status');
    var dt = DateTime.now();
    int ringingMinsRange = 0, silentMinsRange = 0;
    if (silentMins != null) {
      silentMinsRange = silentMins + 5;
    }
    if (ringingMins != null) {
      ringingMinsRange = ringingMins + 5;
    }

    if (status != null) {
      if (status == 'normal') {
        // if(silentHour! == ringingHour || ){}
        if (silentHour == ringingHour &&
            dt.minute >= silentMins! &&
            dt.minute < ringingMins!) {
          profileModeServices.setVibrateMode();
          await prefs.setString('status', 'vibrate');
          status = 'vibrate';
        }
      } else if (status == 'vibrate') {
        if (dt.minute >= ringingMins! && dt.minute < silentMins!) {
          profileModeServices.setNormalMode();
          await prefs.setString('status', 'normal');
          status = 'normal';
        }
      }
    }

    // To activate silent mode
    cron.schedule(
        Schedule.parse('$silentMins-$silentMinsRange $silentHour * * *'),
        () async {
      profileModeServices.setVibrateMode();
      await prefs.setString('status', 'vibrate');
      status = 'vibrate';
    });

    //To activate ringing mode
    cron.schedule(
        Schedule.parse('$ringingMins-$ringingMinsRange $ringingHour * * *'),
        () async {
      profileModeServices.setNormalMode();
      await prefs.setString('status', 'normal');
      status = 'normal';
    });
  }

  Future<void> activateAutoSwitching() async {
    final ProfileModeServices profileModeServices = ProfileModeServices();
    final cron = Cron();

    final prefs = await SharedPreferences.getInstance();
    final int? silentHour = prefs.getInt('silentHour');
    final int? silentMins = prefs.getInt('silentMins');

    final int? ringingHour = prefs.getInt('ringingHour');
    final int? ringingMins = prefs.getInt('ringingMins');

    // To activate silent mode
    cron.schedule(Schedule.parse('$silentMins $silentHour * * *'), () async {
      profileModeServices.setVibrateMode();
    });

    //To activate ringing mode
    cron.schedule(Schedule.parse('$ringingMins $ringingHour * * *'), () async {
      profileModeServices.setNormalMode();
    });
  }
}

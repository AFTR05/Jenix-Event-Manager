
import 'package:jenix_event_manager/src/data/sources/key_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharePreferenceKeySource extends KeySource {
  @override
  Future<Object?> getKeyValue({required String nameKey}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(nameKey);
  }

  @override
  Future<bool> setKeyValue({required String nameKey, required value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      prefs.setBool(nameKey, value);
    } else if (value is int) {
      prefs.setInt(nameKey, value);
    } else if (value is double) {
      prefs.setDouble(nameKey, value);
    } else if (value is String) {
      prefs.setString(nameKey, value);
    } else if (value == null) {
      prefs.remove(nameKey);
    } else {
      prefs.setString(nameKey, value.toString());
    }

    return Future.value(true);
  }

  @override
  Future<bool> deleteKeyValue({required String nameKey}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(nameKey);
  }
}

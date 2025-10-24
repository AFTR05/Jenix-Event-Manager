import 'dart:convert';

class JSONUtils {
  ///Function get dynamic object from json string
  static dynamic getObjectFromStringJSON({required String jsonString}) {
    return json.decode(jsonString);
  }

  ///Function get json string from dynamic object
  static String getJSONFromObject({required dynamic jsonObject}) {
    return json.encode(jsonObject);
  }
}

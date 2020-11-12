/// data : ""
/// message : ""
/// success : ""

class LanguageStatu {
  String data;
  String message;
  bool success;

  static LanguageStatu fromMap(Map map) {
    if (map == null) return null;
    LanguageStatu languageStatuBean = LanguageStatu();
    languageStatuBean.data = map['data'];
    languageStatuBean.message = map['message'];
    languageStatuBean.success = map['success'];
    return languageStatuBean;
  }

  Map toJson() => {
        "data": data,
        "message": message,
        "success": success,
      };
}

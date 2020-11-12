import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geely_flutter/common_util/common_utils.dart';
import 'localizetion_language_string_base.dart';
import 'localizetion_language_string_en.dart';
import 'localizetion_language_string_zh.dart';

///自定义多语言实现
class LocalizationsLanguage {
  final Locale locale;

  LocalizationsLanguage(this.locale);

  ///根据不同 locale.languageCode 加载不同语言对应
  ///GSYStringEn和GSYStringZh都继承了GSYStringBase
  static Map<String, LanguageStringBase> _localizedValues = {
    'en': LanguageStringEn(),
    'zh': LanguageStringZh(),
  };

  LanguageStringBase get currentLocalized {
    Locale localeCur = Locale('zh', 'CH');

    if (CommonUtils.curLocale == 'en_US') {
      localeCur = Locale('en', 'US');
    }
    if (_localizedValues.containsKey(localeCur.languageCode)) {
      return _localizedValues[localeCur.languageCode];
    }
    return _localizedValues["en"];
  }

  ///通过 Localizations 加载当前的 LocalizationsLanguage
  ///获取对应的 LanguageStringBase
  static LocalizationsLanguage of(BuildContext context) {
    return Localizations.of(context, LocalizationsLanguage);
  }

  ///通过 Localizations 加载当前的 LocalizationsLanguage
  ///获取对应的 LanguageStringBase （i8n：国际化）
  /// 例：     LocalizationsLanguage.i18n(context).home_language_en,

  static LanguageStringBase i18n(BuildContext context) {
    return (Localizations.of(context, LocalizationsLanguage)
            as LocalizationsLanguage)
        .currentLocalized;
  }
}

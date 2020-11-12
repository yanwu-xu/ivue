import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'localizetion_language.dart';

/*
 * 多语言代理
 */
class LocalizationsLanguageDelegate
    extends LocalizationsDelegate<LocalizationsLanguage> {
  LocalizationsLanguageDelegate();

  @override
  bool isSupported(Locale locale) {
    ///支持中文和英语
    return true;
  }

  ///根据locale，创建一个对象用于提供当前locale下的文本显示
  @override
  Future<LocalizationsLanguage> load(Locale locale) {
    return new SynchronousFuture<LocalizationsLanguage>(
        new LocalizationsLanguage(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<LocalizationsLanguage> old) {
    return false;
  }

  ///全局静态的代理
  static LocalizationsLanguageDelegate delegate =
      new LocalizationsLanguageDelegate();
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geely_flutter/localizations/localizetion_language.dart';

class MoreWidget extends StatelessWidget {
  final String title;
  final VoidCallback selectVar;

  MoreWidget(this.title, this.selectVar);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 45.0,
        child: Stack(
          // alignment: Alignment.center,
          children: <Widget>[
            Positioned(
                top: 12.0,
                left: 10,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )),
            Positioned(
              child: InkWell(
                child: Text(
                  LocalizationsLanguage.i18n(context).more,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xff9A9E9E),
                      fontWeight: FontWeight.normal),
                ),
                onTap: selectVar,
              ),
              right: 10,
              top: 15.0,
            ),
          ],
        ));
  }
}

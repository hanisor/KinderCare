import 'package:flutter/widgets.dart';

class MediaQueryOverride {
  static bool boldTextOverride(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }
}

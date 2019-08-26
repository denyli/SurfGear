import 'package:flutter/widgets.dart';
import 'package:push/push.dart';

class PushObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    PushNavigatorHolder().navigator = this.navigator;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    PushNavigatorHolder().navigator = this.navigator;
  }
}

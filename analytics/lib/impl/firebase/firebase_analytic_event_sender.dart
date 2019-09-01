import 'package:analytics/core/analytic_action.dart';
import 'package:analytics/core/analytic_action_performer.dart';
import 'package:analytics/impl/firebase/const.dart';
import 'package:analytics/impl/firebase/firebase_analytic_event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Отправляет событие с именем и параметрами в Firebase аналитику
class FirebaseAnalyticEventSender
    implements AnalyticActionPerformer<FirebaseAnalyticEvent> {
  final FirebaseAnalytics _firebaseAnalytics;

  FirebaseAnalyticEventSender(this._firebaseAnalytics);

  @override
  bool canHandle(AnalyticAction action) => action is FirebaseAnalyticEvent;

  @override
  void perform(FirebaseAnalyticEvent action) {
    final params = _cutParamsLength(action.params);
    _firebaseAnalytics.logEvent(
      name: _cutName(action.key),
      parameters: params,
    );
  }

  /// Обрезка параметров для выполнения ограничений FirebaseAnalytics
  Map<String, dynamic> _cutParamsLength(Map<String, dynamic> params) {
    if (params == null) return null;

    final resultParams = <String, dynamic>{};
    for (var key in params.keys) {
      final value = params[key];
      resultParams[_cutName(key)] = value is String ? _cutValue(value) : value;
    }

    return resultParams;
  }

  String _cutName(String name) => name.length <= MAX_EVENT_KEY_LENGTH
      ? name
      : name.substring(0, MAX_EVENT_KEY_LENGTH);

  String _cutValue(String value) => value.length <= MAX_EVENT_VALUE_LENGTH
      ? value
      : value.substring(0, MAX_EVENT_VALUE_LENGTH);
}
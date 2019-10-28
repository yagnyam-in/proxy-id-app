import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:proxy_id/localizations.dart';

typedef DynamicTranslation = String Function(ProxyLocalizations localizations);

class Enticement {
  final String id;
  final Set<String> proxyUniverses;
  final DynamicTranslation getTitle;
  final DynamicTranslation getDescription;
  final int priority;

  Enticement({
    @required this.id,
    @required this.proxyUniverses,
    DynamicTranslation titleBuilder,
    DynamicTranslation descriptionBuilder,
    @required this.priority,
  })  : getTitle = titleBuilder,
        getDescription = descriptionBuilder;

  @override
  String toString() {
    return "Enticement(id: $id)";
  }

  static const String NO_EVENTS = "no-events";
  static const String NO_PROXY_SUBJECTS = "no-proxy-subjects";

}

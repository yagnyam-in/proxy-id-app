import 'package:proxy_core/core.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/model/enticement.dart';

// Priority 0 means highest
class EnticementFactory {
  List<Enticement> getEnticements(String proxyUniverse) {
    print("Get Enticements for proxyUniverse: $proxyUniverse");
    List<Enticement> enticements = [
    ];
    enticements.sort((e1, e2) => Comparable.compare(e1.priority, e2.priority));
    print("Enticements for proxyUniverse: $proxyUniverse => $enticements");
    return enticements.where((e) => e.proxyUniverses.contains(proxyUniverse)).toList();
  }

  static Enticement get noProxySubjects {
    return Enticement(
      proxyUniverses: Set.identity(),
      id: Enticement.NO_PROXY_SUBJECTS,
      titleBuilder: (ProxyLocalizations localizations) => localizations.noProxySubjectsTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.noProxySubjectsDescription,
      priority: 9999,
    );
  }

  static Enticement get noEvents {
    return Enticement(
      proxyUniverses: Set.identity(),
      id: Enticement.NO_EVENTS,
      titleBuilder: (ProxyLocalizations localizations) => localizations.noEventsTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.noEventsDescription,
      priority: 9999,
    );
  }

}

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

  static Enticement get noAuthorizations {
    return Enticement(
      proxyUniverses: Set.identity(),
      id: Enticement.NO_AUTHORIZATIONS,
      titleBuilder: (ProxyLocalizations localizations) => localizations.noAppAuthorizationsTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.noAppAuthorizationsDescription,
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

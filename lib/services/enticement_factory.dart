import 'package:proxy_core/core.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/model/enticement.dart';

// Priority 0 means highest
class EnticementFactory {
  List<Enticement> getEnticements(String proxyUniverse) {
    print("Get Enticements for proxyUniverse: $proxyUniverse");
    List<Enticement> enticements = [
      verifyPhone,
      verifyEmail,
      addTestReceivingAccounts,
    ];
    enticements.sort((e1, e2) => Comparable.compare(e1.priority, e2.priority));
    print("Enticements for proxyUniverse: $proxyUniverse => $enticements");
    return enticements.where((e) => e.proxyUniverses.contains(proxyUniverse)).toList();
  }

  static Enticement get addTestReceivingAccounts {
    return Enticement(
      proxyUniverses: {ProxyUniverse.TEST},
      id: Enticement.ADD_TEST_RECEIVING_ACCOUNTS,
      titleBuilder: (ProxyLocalizations localizations) => localizations.addTestReceivingAccountsTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.addTestReceivingAccountsDescription,
      priority: 100,
    );
  }

  static Enticement get verifyPhone {
    return Enticement(
      proxyUniverses: {ProxyUniverse.PRODUCTION, ProxyUniverse.TEST},
      id: Enticement.VERIFY_PHONE,
      titleBuilder: (ProxyLocalizations localizations) => localizations.verifyPhoneTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.verifyPhoneDescription,
      priority: 50,
    );
  }

  static Enticement get verifyEmail {
    return Enticement(
      proxyUniverses: {ProxyUniverse.PRODUCTION, ProxyUniverse.TEST},
      id: Enticement.VERIFY_EMAIL,
      titleBuilder: (ProxyLocalizations localizations) => localizations.verifyEmailTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.verifyPhoneDescription,
      priority: 51,
    );
  }

  static Enticement get noProxyAccounts {
    return Enticement(
      proxyUniverses: Set.identity(),
      id: Enticement.NO_PROXY_ACCOUNTS,
      titleBuilder: (ProxyLocalizations localizations) => localizations.noProxyAccountsTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.noProxyAccountsDescription,
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

  static Enticement get noReceivingAccounts {
    return Enticement(
      proxyUniverses: Set.identity(),
      id: Enticement.NO_RECEIVING_ACCOUNTS,
      titleBuilder: (ProxyLocalizations localizations) => localizations.noReceivingAccountsTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.noReceivingAccountsDescription,
      priority: 9999,
    );
  }

  static Enticement get noPhoneNumberAuthorizations {
    return Enticement(
      proxyUniverses: Set.identity(),
      id: Enticement.NO_PHONE_NUMBER_AUTHORIZATIONS,
      titleBuilder: (ProxyLocalizations localizations) => localizations.noPhoneNumberAuthorizationsTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.noPhoneNumberAuthorizationsDescription,
      priority: 9999,
    );
  }

  static Enticement get noEmailAuthorizations {
    return Enticement(
      proxyUniverses: Set.identity(),
      id: Enticement.NO_EMAIL_AUTHORIZATIONS,
      titleBuilder: (ProxyLocalizations localizations) => localizations.noEmailAuthorizationsTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.noEmailAuthorizationsDescription,
      priority: 9999,
    );
  }

  static Enticement get noContacts {
    return Enticement(
      proxyUniverses: Set.identity(),
      id: Enticement.NO_CONTACTS,
      titleBuilder: (ProxyLocalizations localizations) => localizations.noContactsTitle,
      descriptionBuilder: (ProxyLocalizations localizations) => localizations.noContactsDescription,
      priority: 9999,
    );
  }
}

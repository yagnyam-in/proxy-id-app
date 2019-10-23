import 'package:flutter/material.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/identity/widgets/enticement_card.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/model/enticement.dart';
import 'package:proxy_id/services/enticement_service.dart';

mixin EnticementHelper {
  AppConfiguration get appConfiguration;

  void showToast(String message);

  Widget enticementCard(BuildContext context, Enticement enticement, {bool cancellable = true}) {
    return EnticementCard(
      enticement: enticement,
      setup: () => launchEnticement(context, enticement),
      dismiss: () => _dismissEnticement(context, enticement),
      dismissable: cancellable,
    );
  }

  Future<void> _dismissEnticement(BuildContext context, Enticement enticement) async {
    print("Dimissing $enticement");
    await EnticementService(appConfiguration).dismissEnticement(
      enticementId: enticement.id,
      proxyUniverse: appConfiguration.proxyUniverse,
    );
  }

  void launchEnticement(BuildContext context, Enticement enticement) {
    print("Launching $enticement");
    switch (enticement.id) {
      case Enticement.NO_AUTHORIZATIONS:
      case Enticement.NO_EVENTS:
      showToast(ProxyLocalizations.of(context).notYetImplemented);
        break;
    }
  }
}

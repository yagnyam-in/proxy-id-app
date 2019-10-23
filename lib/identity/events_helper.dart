import 'package:flutter/material.dart';
import 'package:proxy_id/config/app_configuration.dart';

import 'deposit_page.dart';
import 'model/deposit_event.dart';
import 'model/event_entity.dart';

mixin EventsHelper {
  AppConfiguration get appConfiguration;

  void launchEvent(BuildContext context, EventEntity event) {
    Widget eventPage = _eventPage(event);
    if (eventPage == null) {
      return;
    }
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => eventPage,
      ),
    );
  }

  Widget _eventPage(EventEntity event) {
    switch (event.eventType) {
      case EventType.Deposit:
        return DepositPage(
          appConfiguration,
          proxyUniverse: event.proxyUniverse,
          depositId: (event as DepositEvent).depositId,
        );
      default:
        return null;
    }
  }
}

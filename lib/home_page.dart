import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/identity_home.dart';
import 'package:proxy_id/services/service_factory.dart';
import 'package:uuid/uuid.dart';

import 'identity/db/deposit_store.dart';
import 'identity/deposit_page.dart';
import 'identity/model/deposit_entity.dart';

class HomePage extends StatefulWidget {
  final AppConfiguration appConfiguration;

  HomePage(this.appConfiguration, {Key key}) : super(key: key) {
    print("build home page with $appConfiguration");
  }

  @override
  _HomePageState createState() => _HomePageState(appConfiguration);
}

class _HomePageState extends State<HomePage> {
  final ProxyVersion proxyVersion = ProxyVersion.latestVersion();
  final AppConfiguration appConfiguration;
  final Uuid uuidFactory = Uuid();

  _HomePageState(this.appConfiguration) {
    print("build home page state with $appConfiguration");
  }

  @override
  void initState() {
    super.initState();
    ServiceFactory.bootService().subscribeForAlerts();
    ServiceFactory.bootService().processPendingAlerts(appConfiguration);
    this.initDynamicLinks();
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      _handleDynamicLinks(deepLink);
    }
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        _handleDynamicLinks(deepLink);
      }
    }, onError: (OnLinkErrorException e) async {
      print('initDynamicLinks: ${e.message}');
    });
  }

  Future<void> _handleDynamicLinks(Uri link) async {
    if (link == null) return;
    print('link.path = ${link.path}');
    if (link.path == '/actions/deposit-status') {
      _depositStatus(link, link.queryParameters);
    } else {
      print('ignoring $link');
    }
  }

  Future<void> _depositStatus(Uri link, Map<String, String> query) async {
    print("Launching dialog to show deposit status $query");
    String proxyUniverse = query['proxyUniverse'];
    String depositId = query['depositId'];
    DepositEntity deposit =
        await DepositStore(appConfiguration).fetchDeposit(proxyUniverse: proxyUniverse, depositId: depositId);
    if (deposit == null) {
      print("Couldn't find deposit for $query");
      return null;
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => DepositPage(
          appConfiguration,
          proxyUniverse: proxyUniverse,
          depositId: depositId,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Returning Banking Home Page with $appConfiguration");
    return IdentityHome(
      appConfiguration,
      key: ValueKey(appConfiguration),
    );
  }
}

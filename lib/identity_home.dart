import 'package:flutter/cupertino.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/settings_page.dart';

import 'home_page_navigation.dart';
import 'identity/events_page.dart';
import 'identity/app_authorizations_page.dart';

class IdentityHome extends StatefulWidget {
  final AppConfiguration appConfiguration;

  const IdentityHome(this.appConfiguration, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _IdentityHomeState(appConfiguration);
  }
}

class _IdentityHomeState extends State<IdentityHome> {
  final AppConfiguration appConfiguration;

  HomePage _homePage = HomePage.AppAuthorizationsPage;

  _IdentityHomeState(this.appConfiguration);

  @override
  Widget build(BuildContext context) {
    switch (_homePage) {
      case HomePage.AppAuthorizationsPage:
        return AppAuthorizationsPage(
          appConfiguration,
          changeHomePage: changeHomePage,
        );
      case HomePage.EventsPage:
        return EventsPage(
          appConfiguration,
          changeHomePage: changeHomePage,
        );
      case HomePage.SettingsPage:
        return SettingsPage(
          appConfiguration,
          changeHomePage: changeHomePage,
        );
      default:
        return AppAuthorizationsPage(
          appConfiguration,
          changeHomePage: changeHomePage,
        );
    }
  }

  void changeHomePage(HomePage homePage) {
    setState(() {
      _homePage = homePage;
    });
  }
}

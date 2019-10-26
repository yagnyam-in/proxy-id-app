import 'package:flutter/cupertino.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/settings_page.dart';

import 'home_page_navigation.dart';
import 'identity/events_page.dart';
import 'identity/proxy_subjects_page.dart';

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

  HomePage _homePage = HomePage.ProxySubjectsPage;

  _IdentityHomeState(this.appConfiguration);

  @override
  Widget build(BuildContext context) {
    switch (_homePage) {
      case HomePage.ProxySubjectsPage:
        return ProxySubjectsPage(
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
        return ProxySubjectsPage(
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

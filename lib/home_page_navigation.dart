import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proxy_id/localizations.dart';

enum HomePage {
  AppAuthorizationsPage,
  EventsPage,
  SettingsPage,
}

typedef void ChangeHomePage(HomePage homePage);

class _BottomNavigationBar extends StatefulWidget {
  final ChangeHomePage changeHomePage;
  final HomePage homePage;
  final bool busy;

  const _BottomNavigationBar(this.changeHomePage, this.homePage, this.busy, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BottomNavigationBarState(changeHomePage, homePage, busy);
  }
}

class _BottomNavigationBarState extends State<_BottomNavigationBar> {
  final ChangeHomePage changeHomePage;
  final HomePage homePage;
  final bool busy;

  int _selectedIndex;

  _BottomNavigationBarState(this.changeHomePage, this.homePage, this.busy) {
    switch (homePage) {
      case HomePage.AppAuthorizationsPage:
        _selectedIndex = 0;
        break;
      case HomePage.EventsPage:
        _selectedIndex = 1;
        break;
      case HomePage.SettingsPage:
        _selectedIndex = 2;
        break;
      default:
        _selectedIndex = 0;
        break;
    }
  }

  void _onItemTapped(int index) {
    print("_onItemTapped($index)");
    setState(() {
      _selectedIndex = index;
    });
    switch (_selectedIndex) {
      case 0:
        changeHomePage(HomePage.AppAuthorizationsPage);
        break;
      case 1:
        changeHomePage(HomePage.EventsPage);
        break;
      case 2:
        changeHomePage(HomePage.SettingsPage);
        break;
      default:
        print("HomePage for $_selectedIndex is not handled");
        changeHomePage(HomePage.AppAuthorizationsPage);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.fingerprint),
          title: Text(localizations.authorizationsPageNavigationLabel),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          title: Text(localizations.eventsPageNavigationLabel),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box),
          title: Text(localizations.profilePageNavigationLabel),
        ),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: (index) {
        if (!busy) {
          _onItemTapped(index);
        }
      },
    );
  }
}

mixin HomePageNavigation {
  Widget navigationBar(BuildContext context, HomePage homePage,
      {@required ChangeHomePage changeHomePage, @required bool busy}) {
    return _BottomNavigationBar(changeHomePage, homePage, busy);
  }
}

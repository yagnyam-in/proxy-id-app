import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/about_page.dart';
import 'package:proxy_id/db/account_store.dart';
import 'package:proxy_id/home_page_navigation.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/services/account_service.dart';
import 'package:proxy_id/services/app_configuration_bloc.dart';
import 'package:proxy_id/widgets/async_helper.dart';
import 'package:proxy_id/widgets/loading.dart';
import 'package:quiver/strings.dart';

import 'config/app_configuration.dart';
import 'model/account_entity.dart';
import 'utils/conversion_utils.dart';
import 'utils/data_validations.dart';
import 'widgets/widget_helper.dart';

class SettingsPage extends StatefulWidget {
  static const String PROXY_ID_PARAM = "proxyId";
  static const String PROXY_SHA256_PARAM = "proxySha256";

  final AppConfiguration appConfiguration;
  final ChangeHomePage changeHomePage;

  const SettingsPage(
    this.appConfiguration, {
    @required this.changeHomePage,
    Key key,
  }) : super(key: key);

  @override
  SettingsPageState createState() {
    return SettingsPageState(appConfiguration, changeHomePage);
  }
}

class SettingsPageState extends LoadingSupportState<SettingsPage> with HomePageNavigation {
  final AppConfiguration appConfiguration;
  final ChangeHomePage changeHomePage;
  final AccountStore _accountStore;
  Stream<AccountEntity> _accountStream;
  bool loading = false;

  SettingsPageState(this.appConfiguration, this.changeHomePage) : _accountStore = AccountStore();

  @override
  void initState() {
    super.initState();
    _accountStream = _accountStore.subscribeForAccount(appConfiguration.accountId);
  }

  @override
  Widget build(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profilePageTitle + appConfiguration.proxyUniverseSuffix),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.power_settings_new),
            tooltip: localizations.logout,
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: BusyChildWidget(
        loading: loading,
        child: streamBuilder(
          name: "Profile Loading",
          stream: _accountStream,
          builder: (context, account) => _SettingsWidget(appConfiguration, account),
        ),
      ),
      bottomNavigationBar: navigationBar(
        context,
        HomePage.SettingsPage,
        changeHomePage: changeHomePage,
        busy: loading,
      ),
    );
  }

  void _logout(BuildContext context) {
    print("Logout");
    AppConfigurationBloc.instance.signOut();
  }
}

class _SettingsWidget extends StatefulWidget {
  final AppConfiguration appConfiguration;
  final AccountEntity accountEntity;

  const _SettingsWidget(this.appConfiguration, this.accountEntity, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsWidgetState(appConfiguration, accountEntity);
  }
}

class _SettingsWidgetState extends State<_SettingsWidget> {
  final AppConfiguration appConfiguration;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AccountEntity accountEntity;

  _SettingsWidgetState(this.appConfiguration, this.accountEntity);

  String get displayName {
    return accountEntity.name ?? nullIfEmpty(appConfiguration.firebaseUser.displayName);
  }

  String get phoneNumber {
    return accountEntity.phone ?? nullIfEmpty(appConfiguration.firebaseUser.phoneNumber);
  }

  String get email {
    return accountEntity.email ?? nullIfEmpty(appConfiguration.firebaseUser.email);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      _avatarWidget(context),
      const Divider(),
      _profileWidget(context),
      const Divider(),
      _emailWidget(context),
      const Divider(),
      _phoneNumberWidget(context),
      const Divider(),
      _PassPhraseWidget(appConfiguration: appConfiguration),
      const Divider(),
      _proxyUniverseWidget(context),
      const Divider(),
      _aboutWidget(context),
      const Divider(),
    ]);
  }

  Widget _avatarWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(),
            flex: 1,
          ),
          Container(
            width: 64.0,
            height: 64.0,
            child: CircleAvatar(
              backgroundImage: NetworkImage(appConfiguration.firebaseUser.photoUrl),
            ),
          ),
          Expanded(
            child: Container(),
            flex: 1,
          ),
        ],
      ),
    );
  }

  Widget _profileWidget(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return ListTile(
      title: GestureDetector(
        onTap: () => _changeName(context),
        child: Text(
          localizations.customerName,
        ),
      ),
      subtitle: GestureDetector(
        onTap: () => _changeName(context),
        child: Text(
          displayName?.toUpperCase() ?? '🖊️️ ' + localizations.changeNameTitle,
        ),
      ),
    );
  }

  Widget _proxyUniverseWidget(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return ListTile(
      title: Text(
        localizations.proxyUniverse,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          appConfiguration.proxyUniverse.toUpperCase(),
        ),
      ),
      trailing: GestureDetector(
        onTap: () => _changeProxyUniverse(context),
        child: Icon(
          Icons.swap_horiz,
        ),
      ),
    );
  }

  Widget _phoneNumberWidget(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return GestureDetector(
      onTap: () => _changePhoneNumber(context),
      child: ListTile(
        title: Text(
          localizations.customerPhone,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            phoneNumber ?? localizations.authorizePhoneNumber,
          ),
        ),
        trailing: Icon(
          Platform.isIOS ? Icons.phone_iphone : Icons.phone_android,
        ),
      ),
    );
  }

  Widget _emailWidget(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return ListTile(
      title: Text(
        localizations.customerEmail,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          email ?? localizations.authorizeEmail,
        ),
      ),
      trailing: Icon(
        Icons.email,
      ),
    );
  }

  Widget _aboutWidget(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => AboutPage(appConfiguration),
        ),
      ),
      child: ListTile(
        title: Text(
          localizations.about,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            localizations.aboutDescription,
          ),
        ),
        trailing: Icon(
          Icons.help,
        ),
      ),
    );
  }

  void _changeName(BuildContext context) async {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    String newName = await acceptNameDialog(
      context,
      pageTitle: localizations.changeNameTitle,
      fieldName: localizations.customerName,
      fieldInitialValue: displayName,
    );
    if (isNotEmpty(newName)) {
      AccountEntity updatedAccount = await AccountService.updatePreferences(
        appConfiguration,
        accountEntity,
        name: newName,
      );
      appConfiguration.account = updatedAccount;
      setState(() {
        accountEntity = updatedAccount;
      });
    }
  }

  void _showToast(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _changePhoneNumber(BuildContext context) async {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    String newPhoneNumber = await acceptPhoneNumberDialog(
      context,
      pageTitle: localizations.changePhoneNumberTitle,
      fieldName: localizations.customerPhone,
      fieldInitialValue: phoneNumber,
    );
    if (isNotEmpty(newPhoneNumber)) {
      if (!isPhoneNumber(newPhoneNumber)) {
        _showToast(localizations.invalidPhoneNumber);
      }
      AccountEntity updatedAccount = await AccountService.updatePreferences(
        appConfiguration,
        accountEntity,
        phone: newPhoneNumber,
      );
      appConfiguration.account = updatedAccount;
      setState(() {
        accountEntity = updatedAccount;
      });
    }
  }

  void _changeProxyUniverse(BuildContext context) {
    String proxyUniverse = appConfiguration.proxyUniverse;
    if (proxyUniverse == ProxyUniverse.PRODUCTION) {
      proxyUniverse = ProxyUniverse.TEST;
    } else {
      proxyUniverse = ProxyUniverse.PRODUCTION;
    }
    AppConfigurationBloc.instance.appConfiguration = appConfiguration.copy(
      proxyUniverse: proxyUniverse,
    );
  }
}

class _PassPhraseWidget extends StatefulWidget {
  final AppConfiguration appConfiguration;

  const _PassPhraseWidget({Key key, this.appConfiguration}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PassPhraseWidgetState(appConfiguration);
  }
}

class _PassPhraseWidgetState extends State<_PassPhraseWidget> {
  final AppConfiguration appConfiguration;
  bool _showPassPhrase = false;

  _PassPhraseWidgetState(this.appConfiguration);

  @override
  Widget build(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    return ListTile(
      title: Text(
        localizations.passPhrase,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          _showPassPhrase ? appConfiguration.passPhrase : '*' * appConfiguration.passPhrase.length,
        ),
      ),
      trailing: GestureDetector(
        onTap: () => setState(() => _showPassPhrase = !_showPassPhrase),
        child: Icon(
          _showPassPhrase ? Icons.visibility_off : Icons.visibility,
        ),
      ),
    );
  }
}

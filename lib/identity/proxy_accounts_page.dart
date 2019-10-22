import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/authorizations_helper.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/contacts_page.dart';
import 'package:proxy_id/home_page_navigation.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/model/action_menu_item.dart';
import 'package:proxy_id/model/enticement.dart';
import 'package:proxy_id/services/enticement_factory.dart';
import 'package:proxy_id/services/enticement_service.dart';
import 'package:proxy_id/services/service_factory.dart';
import 'package:proxy_id/services/upgrade_helper.dart';
import 'package:proxy_id/widgets/async_helper.dart';
import 'package:proxy_id/widgets/enticement_helper.dart';
import 'package:proxy_id/widgets/loading.dart';
import 'package:uuid/uuid.dart';

import 'db/proxy_account_store.dart';
import 'deposit_helper.dart';
import 'model/proxy_account_entity.dart';
import 'payment_authorization_helper.dart';
import 'proxy_account_helper.dart';
import 'widgets/account_card.dart';
import 'withdrawal_helper.dart';

final Uuid uuidFactory = Uuid();

class ProxyAccountsPage extends StatefulWidget {
  final AppConfiguration appConfiguration;
  final ChangeHomePage changeHomePage;

  ProxyAccountsPage(
    this.appConfiguration, {
    Key key,
    @required this.changeHomePage,
  }) : super(key: key) {
    print("Constructing ProxyAccountsPage");
    assert(appConfiguration != null);
  }

  @override
  _ProxyAccountsPageState createState() {
    return _ProxyAccountsPageState(appConfiguration, changeHomePage);
  }
}

class _ProxyAccountsPageState extends LoadingSupportState<ProxyAccountsPage>
    with
        ProxyUtils,
        EnticementHelper,
        HomePageNavigation,
        DepositHelper,
        PaymentAuthorizationHelper,
        WithdrawalHelper,
        AccountHelper,
        AuthorizationsHelper,
        UpgradeHelper {
  static const String DEPOSIT = "deposit";
  static const String CONTACTS = "contacts";
  final AppConfiguration appConfiguration;
  final ChangeHomePage changeHomePage;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<List<ProxyAccountEntity>> _proxyAccountsStream;
  Stream<List<Enticement>> _enticementsStream;
  bool loading = false;
  Timer _newVersionCheckTimer;

  _ProxyAccountsPageState(this.appConfiguration, this.changeHomePage);

  @override
  void initState() {
    super.initState();
    _proxyAccountsStream = ProxyAccountStore(appConfiguration).subscribeForAccounts();
    _enticementsStream = EnticementService(appConfiguration).subscribeForFirstEnticement();
    ServiceFactory.bootService().warmUpBackends();
    _newVersionCheckTimer = Timer(const Duration(milliseconds: 5000), () => checkForUpdates(context));
  }

  @override
  void dispose() {
    super.dispose();
    if (_newVersionCheckTimer != null) {
      _newVersionCheckTimer.cancel();
    }
  }

  void showToast(String message) {
    showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  List<ActionMenuItem> actions(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return [
      ActionMenuItem(title: localizations.depositActionItemTitle, icon: Icons.file_download, action: DEPOSIT),
      ActionMenuItem(title: localizations.contactsItemTitle, icon: Icons.contacts, action: CONTACTS),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(localizations.proxyAccountsPageTitle + appConfiguration.proxyUniverseSuffix),
        actions: <Widget>[
          PopupMenuButton<ActionMenuItem>(
            onSelected: (action) => _onAction(context, action),
            itemBuilder: (BuildContext context) {
              return actions(context).map((ActionMenuItem choice) {
                return PopupMenuItem<ActionMenuItem>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: BusyChildWidget(
        loading: loading,
        child: ListView.builder(
          itemCount: 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return streamBuilder(
                name: "Account Loading",
                stream: _proxyAccountsStream,
                builder: (context, accounts) => _accounts(context, accounts),
              );
            } else {
              return streamBuilder(
                name: "Enticement Loading",
                stream: _enticementsStream,
                loadingWidget: SizedBox.shrink(),
                builder: (context, enticements) => _enticements(context, enticements),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createPaymentAuthorizationAndLaunch(context),
        icon: Icon(Icons.payment),
        label: Text(localizations.payFabLabel),
      ),
      bottomNavigationBar: navigationBar(
        context,
        HomePage.ProxyAccountsPage,
        busy: loading,
        changeHomePage: changeHomePage,
      ),
    );
  }

  Future<void> _createPaymentAuthorizationAndLaunch(BuildContext context) async {
    final paymentAuthorization = await createPaymentAuthorization(context);
    await launchPaymentAuthorization(context, paymentAuthorization);
  }

  Widget _accounts(
    BuildContext context,
    List<ProxyAccountEntity> accounts,
  ) {
    // print("accounts : $accounts");
    if (accounts.isEmpty) {
      return ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          const SizedBox(height: 4.0),
          enticementCard(context, EnticementFactory.noProxyAccounts, cancellable: false),
        ],
      );
    }
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: accounts.expand((account) {
        return [
          const SizedBox(height: 4.0),
          _accountCard(context, account),
        ];
      }).toList(),
    );
  }

  Widget _enticements(
    BuildContext context,
    List<Enticement> enticements,
  ) {
    // print("enticements : $enticements");
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: enticements.expand((enticement) {
        return [
          const SizedBox(height: 4.0),
          enticementCard(context, enticement),
        ];
      }).toList(),
    );
  }

  Widget _accountCard(
    BuildContext context,
    ProxyAccountEntity account,
  ) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: AccountCard(account: account),
      actions: <Widget>[
        new IconSlideAction(
          caption: localizations.deposit,
          color: Colors.blue,
          icon: Icons.file_download,
          onTap: () => depositToAccount(context, account),
        ),
        new IconSlideAction(
          caption: 'Withdraw',
          color: Colors.indigo,
          icon: Icons.file_upload,
          onTap: () => withdrawFromAccount(context, account),
        ),
      ],
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: localizations.refreshButtonHint,
          color: Colors.orange,
          icon: Icons.refresh,
          onTap: () => refreshAccount(context, account),
        ),
        new IconSlideAction(
          caption: localizations.archive,
          color: Colors.red,
          icon: Icons.archive,
          onTap: () => archiveAccount(context, account),
        ),
      ],
    );
  }

  void _launchContacts(BuildContext context) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => ContactsPage.manage(appConfiguration: widget.appConfiguration),
      ),
    );
  }

  void _onAction(BuildContext context, ActionMenuItem action) {
    if (action.action == DEPOSIT) {
      createAccountAndDeposit(context);
    } else if (action.action == CONTACTS) {
      _launchContacts(context);
    } else {
      print("Unknown action $action");
    }
  }

  @override
  void showSnackBar(SnackBar snackbar) {
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/db/account_store.dart';
import 'package:proxy_id/db/user_store.dart';
import 'package:proxy_id/model/account_entity.dart';
import 'package:proxy_id/model/user_entity.dart';
import 'package:proxy_id/services/account_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfigurationBloc {
  static final AppConfigurationBloc instance = AppConfigurationBloc();
  final BehaviorSubject<AppConfiguration> _appConfigStreamController = BehaviorSubject<AppConfiguration>();
  AppConfiguration _appConfiguration;

  Stream<AppConfiguration> get appConfigurationStream {
    return _appConfigStreamController;
  }

  AppConfiguration get appConfiguration => _appConfiguration;

  set appConfiguration(AppConfiguration appConfiguration) {
    _appConfiguration = appConfiguration;
    _appConfigStreamController.sink.add(appConfiguration);
    if (appConfiguration != null) {
      appConfiguration.persist();
    }
  }

  void dispose() {
    _appConfigStreamController?.close();
  }

  void refresh({
    String passPhrase,
    String proxyUniverse,
  }) {
    _fetchAppConfiguration().then(
      (r) {
        this.appConfiguration = r.copy(
          passPhrase: passPhrase,
          proxyUniverse: proxyUniverse,
        );
      },
      onError: (e) {
        print("Failed to fetch App config");
      },
    );
  }

  Future<AppConfiguration> _fetchAppConfiguration() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    UserEntity appUser;
    AccountEntity account;
    String passPhrase = await AppConfiguration.fetchPassPhrase();
    // To prompt Proxy Universe, don't default proxyUniverse
    String proxyUniverse = await AppConfiguration.fetchProxyUniverse() ?? ProxyUniverse.TEST;
    String deviceId = await AppConfiguration.fetchDeviceId();
    if (firebaseUser != null) {
      appUser = await UserStore.forUser(firebaseUser).fetchUser();
      print("Got App User => $appUser");
    }
    if (appUser?.accountId != null) {
      account = await AccountStore().fetchAccount(appUser.accountId);
      print("Got Account => $account");
    }
    if (account != null) {
      bool isPassPhraseValid = await AccountService(
        firebaseUser: firebaseUser,
        appUser: appUser,
      ).validateEncryptionKey(
        account: account,
        encryptionKey: passPhrase,
      );
      if (!isPassPhraseValid) {
        passPhrase = null;
      }
    }
    return AppConfiguration(
      preferences: sharedPreferences,
      firebaseUser: firebaseUser,
      appUser: appUser,
      account: account,
      passPhrase: passPhrase,
      proxyUniverse: proxyUniverse,
      deviceId: deviceId,
    );
  }

  void signOut() {
    print("SignOut");
    appConfiguration = AppConfiguration(
      preferences: appConfiguration.preferences,
      firebaseUser: null,
      appUser: null,
      account: null,
      passPhrase: null,
      proxyUniverse: appConfiguration.proxyUniverse,
      deviceId: appConfiguration.deviceId,
    );
    FirebaseAuth.instance.signOut();
  }
}

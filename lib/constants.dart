import 'package:proxy_core/core.dart';

class Constants {
  static const String ANDROID_PACKAGE_NAME = 'in.yagnyam.pid';
  static const String IOS_BUNDLE_ID = 'in.yagnyam.pid';
  static const String IOS_APP_STORE_ID = '1484384533';
  static const String IOS_APP_ID = 'DC88C76M86.in.yagnyam.pid';
  static const String IOS_APP_STORE_URL = "https://apps.apple.com/app/id$IOS_APP_STORE_ID";
  static const String ANDROID_PLAY_STORE_URL = "market://details?id=$ANDROID_PACKAGE_NAME";

  static final ProxyId PROXY_ID_APP_BACKEND_PROXY_ID = ProxyId("proxy-id-app", "eOR-DX4DpYaSfWc5kOMpZL8ZDmf8bvtBpsEckGq5Zpc");
}

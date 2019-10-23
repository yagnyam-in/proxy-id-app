import 'package:proxy_id/config/app_configuration.dart';

mixin AppAuthorizationsHelper {
  AppConfiguration get appConfiguration;

  void showToast(String message);
}

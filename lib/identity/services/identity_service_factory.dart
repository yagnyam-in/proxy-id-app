import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/services/service_factory.dart';

import 'identity_service.dart';

class IdentityServiceFactory {
  static IdentityService identityService(AppConfiguration appConfiguration) {
    return IdentityService(
      appConfiguration,
      messageFactory: ServiceFactory.messageFactory(appConfiguration),
      messageSigningService: ServiceFactory.messageSigningService(),
    );
  }
}

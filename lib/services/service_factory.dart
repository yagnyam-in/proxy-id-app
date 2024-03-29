import 'package:proxy_core/bootstrap.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_core/services.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/db/device_store.dart';
import 'package:proxy_id/db/proxy_key_store.dart';
import 'package:proxy_id/services/alert_service.dart';
import 'package:proxy_id/services/boot_service.dart';
import 'package:proxy_id/services/local_proxy_resolver.dart';
import 'package:proxy_id/services/notification_service.dart';
import 'package:proxy_id/services/register_service.dart';
import 'package:proxy_id/services/secrets_service.dart';

import 'deep_link_service.dart';

class ServiceFactory {
  static final NotificationService _notificationServiceInstance =
      NotificationService(messageSigningService: messageSigningService());

  static NotificationService notificationService() => _notificationServiceInstance;

  static ProxyResolver proxyResolver(AppConfiguration appConfiguration) => CachedProxyResolver(
        proxyResolver: LocalProxyResolver(
          appConfiguration,
          remoteProxyResolver: RemoteProxyResolver(),
        ),
      );

  static get cryptographyService => PointyCastleCryptographyService();

  static get proxyKeyFactory => PointyCastleProxyKeyFactory();

  static get proxyRequestFactory => PointyCastleProxyRequestFactory(cryptographyService);

  static MessageVerificationService messageVerificationService(AppConfiguration appConfiguration) {
    return new MessageVerificationService(
      cryptographyService: cryptographyService,
      proxyResolver: proxyResolver(appConfiguration),
    );
  }

  static MessageBuilder messageBuilder() {
    return MessageBuilder();
  }

  static MessageFactory messageFactory(AppConfiguration appConfiguration) {
    return MessageFactory(
      messageBuilder: messageBuilder(),
      messageVerificationService: messageVerificationService(appConfiguration),
    );
  }

  static MessageSigningService messageSigningService() {
    return MessageSigningService(cryptographyService: cryptographyService);
  }

  static ProxyIdFactory proxyIdFactory() => ProxyIdFactory.instance();

  static DeepLinkService deepLinkService() {
    return DeepLinkService();
  }

  static final BootService _bootServiceInstance = BootService();

  static BootService bootService() => _bootServiceInstance;

  static RegisterService registerService() => RegisterService();

  static AlertService alertService(AppConfiguration appConfiguration) => AlertService(
        appConfiguration,
        messageSigningService: messageSigningService(),
        proxyKeyStore: ProxyKeyStore(appConfiguration),
        deviceStore: DeviceStore(appConfiguration),
      );


  static SecretsService secretsService(AppConfiguration appConfiguration) =>
      SecretsService(
        appConfiguration,
        cryptographyService: cryptographyService,
      );

}

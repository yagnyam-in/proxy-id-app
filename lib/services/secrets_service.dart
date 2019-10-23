import 'package:flutter/cupertino.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_core/services.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/constants.dart';
import 'package:proxy_id/url_config.dart';
import 'package:proxy_messages/authorization.dart';
import 'package:uuid/uuid.dart';

import 'service_helper.dart';

class SecretsService with ProxyUtils, HttpClientUtils, ServiceHelper, DebugUtils {
  final AppConfiguration appConfiguration;
  final CryptographyService cryptographyService;
  final HttpClientFactory httpClientFactory;
  final Uuid uuidFactory = Uuid();
  final String appBackendUrl;

  SecretsService(
    this.appConfiguration, {
    @required this.cryptographyService,
    HttpClientFactory httpClientFactory,
    String appBackendUrl,
  })  : appBackendUrl = appBackendUrl ?? "${UrlConfig.APP_BACKEND}/api",
        httpClientFactory = httpClientFactory ?? ProxyHttpClient.client;

  Future<void> saveSecrets(
    List<SecretForPhoneNumberRecipient> secretsForPhoneNumberRecipients,
    List<SecretForEmailRecipient> secretsForEmailRecipients,
  ) async {
    SendSecretsRequest request = SendSecretsRequest(
      senderProxyId: appConfiguration.masterProxyId,
      routerProxyId: Constants.PROXY_ID_APP_BACKEND_PROXY_ID,
      validFrom: DateTime.now().toUtc(),
      validTill: DateTime.now().toUtc().add(Duration(days: 30)),
      secretsForPhoneNumberRecipients: secretsForPhoneNumberRecipients,
      secretsForEmailRecipients: secretsForEmailRecipients,
    );
    final signedRequest = await signMessage(
      signer: appConfiguration.masterProxyId,
      request: request,
    );
    await send(
      url: appBackendUrl,
      signedRequest: signedRequest,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_core/services.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/identity/db/proxy_subject_store.dart';
import 'package:proxy_id/services/service_helper.dart';
import 'package:proxy_id/url_config.dart';
import 'package:uuid/uuid.dart';

class IdentityService with ProxyUtils, HttpClientUtils, ServiceHelper, DebugUtils {
  final AppConfiguration appConfiguration;
  final Uuid uuidFactory = Uuid();
  final String proxyBankingUrl;
  final HttpClientFactory httpClientFactory;
  final MessageFactory messageFactory;
  final MessageSigningService messageSigningService;
  final ProxySubjectStore _proxySubjectStore;

  IdentityService(
    this.appConfiguration, {
    String proxyBankingUrl,
    HttpClientFactory httpClientFactory,
    @required this.messageFactory,
    @required this.messageSigningService,
  })  : proxyBankingUrl = proxyBankingUrl ?? "${UrlConfig.PROXY_IDENTITY}/api",
        httpClientFactory = httpClientFactory ?? ProxyHttpClient.client,
        _proxySubjectStore = ProxySubjectStore(appConfiguration) {
    assert(appConfiguration != null);
    assert(isNotEmpty(this.proxyBankingUrl));
  }
}

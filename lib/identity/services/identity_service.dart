import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_core/services.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/db/service_provider_store.dart';
import 'package:proxy_id/identity/db/pending_subject_store.dart';
import 'package:proxy_id/identity/db/proxy_subject_store.dart';
import 'package:proxy_id/identity/model/pending_subject_entity.dart';
import 'package:proxy_id/identity/model/proxy_subject_entity.dart';
import 'package:proxy_id/identity/model/service_provider_entity.dart';
import 'package:proxy_id/identity/subject_input_dialog.dart';
import 'package:proxy_id/services/service_helper.dart';
import 'package:proxy_id/url_config.dart';
import 'package:proxy_messages/identity.dart';
import 'package:uuid/uuid.dart';

class IdentityService with ProxyUtils, HttpClientUtils, ServiceHelper, DebugUtils {
  final AppConfiguration appConfiguration;
  final Uuid uuidFactory = Uuid();
  final String proxyBankingUrl;
  final HttpClientFactory httpClientFactory;
  final MessageFactory messageFactory;
  final MessageSigningService messageSigningService;
  final ProxySubjectStore _proxySubjectStore;
  final PendingSubjectStore _pendingSubjectStore;

  IdentityService(
    this.appConfiguration, {
    String proxyBankingUrl,
    HttpClientFactory httpClientFactory,
    @required this.messageFactory,
    @required this.messageSigningService,
  })  : proxyBankingUrl = proxyBankingUrl ?? "${UrlConfig.PROXY_IDENTITY}/api",
        httpClientFactory = httpClientFactory ?? ProxyHttpClient.client,
        _proxySubjectStore = ProxySubjectStore(appConfiguration),
        _pendingSubjectStore = PendingSubjectStore(appConfiguration) {
    assert(appConfiguration != null);
    assert(isNotEmpty(this.proxyBankingUrl));
  }

  Future<ServiceProviderEntity> _fetchDefaultServiceProvider({String proxyUniverse}) {
    proxyUniverse = proxyUniverse ?? appConfiguration.proxyUniverse;
    String serviceProviderId = proxyUniverse == ProxyUniverse.PRODUCTION ? "aadhaar" : "test-aadhaar";
    return ServiceProviderStore().fetchServiceProvider(
      proxyUniverse: proxyUniverse,
      serviceProviderId: serviceProviderId,
    );
  }

  Future<PendingSubjectEntity> initiateSubjectVerification({
    @required ProxyId ownerProxyId,
    @required String proxyUniverse,
    @required SubjectInput input,
  }) async {
    ServiceProviderEntity serviceProvider = await _fetchDefaultServiceProvider(proxyUniverse: proxyUniverse);
    AadhaarVerificationRequest request = AadhaarVerificationRequest(
      requestId: uuidFactory.v4(),
      proxyUniverse: proxyUniverse,
      ownerProxyId: ownerProxyId,
      issuerProxyId: serviceProvider.serviceProviderProxyId,
      aadhaarNumber: input.aadhaarNumber,
    );
    final signedRequest = await signMessage(
      signer: ownerProxyId,
      request: request,
    );
    final signedResponse = await sendAndReceive(
      url: proxyBankingUrl,
      signedRequest: signedRequest,
      responseParser: AadhaarVerificationChallenge.fromJson,
    );
    return _pendingSubjectStore
        .savePendingSubject(PendingSubjectEntity.fromAadhaarVerificationChallenge(signedResponse));
  }

  Future<ProxySubjectEntity> completeSubjectVerification({
    @required PendingSubjectEntity pendingSubjectEntity,
    @required String verificationCode,
  }) async {
    AadhaarVerificationChallengeResponse request = AadhaarVerificationChallengeResponse(
      challenge: pendingSubjectEntity.signedAadhaarVerificationChallenge,
      response: verificationCode,
    );
    final signedRequest = await signMessage(
      signer: pendingSubjectEntity.ownerProxyId,
      request: request,
    );

    final signedResponse = await sendAndReceive(
      url: proxyBankingUrl,
      signedRequest: signedRequest,
      responseParser: ProxySubject.fromJson,
    );
    await _pendingSubjectStore.savePendingSubject(pendingSubjectEntity.copy(active: false, verified: true));
    return _proxySubjectStore.saveSubject(ProxySubjectEntity.fromProxySubject(signedResponse));
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_core/services.dart';
import 'package:proxy_id/identity/db/payment_authorization_store.dart';
import 'package:proxy_id/identity/model/payment_authorization_entity.dart';
import 'package:proxy_id/identity/model/payment_authorization_payee_entity.dart';
import 'package:proxy_id/identity/model/proxy_account_entity.dart';
import 'package:proxy_id/identity/payment_authorization_input_dialog.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/services/secrets_service.dart';
import 'package:proxy_id/services/service_factory.dart';
import 'package:proxy_id/services/service_helper.dart';
import 'package:proxy_id/url_config.dart';
import 'package:proxy_id/utils/random_utils.dart';
import 'package:proxy_messages/authorization.dart';
import 'package:proxy_messages/banking.dart';
import 'package:proxy_messages/payments.dart';
import 'package:uuid/uuid.dart';

class PaymentAuthorizationService with ProxyUtils, HttpClientUtils, ServiceHelper, DebugUtils, RandomUtils {
  final AppConfiguration appConfiguration;
  final Uuid uuidFactory = Uuid();
  final String proxyBankingUrl;
  final HttpClientFactory httpClientFactory;
  final MessageFactory messageFactory;
  final MessageSigningService messageSigningService;
  final CryptographyService cryptographyService;
  final PaymentAuthorizationStore _paymentAuthorizationStore;
  final SecretsService secretsService;

  PaymentAuthorizationService(
    this.appConfiguration, {
    String proxyBankingUrl,
    HttpClientFactory httpClientFactory,
    @required this.messageFactory,
    @required this.messageSigningService,
    @required this.cryptographyService,
    @required this.secretsService,
  })  : proxyBankingUrl = proxyBankingUrl ?? "${UrlConfig.PROXY_BANKING}/api",
        httpClientFactory = httpClientFactory ?? ProxyHttpClient.client,
        _paymentAuthorizationStore = PaymentAuthorizationStore(appConfiguration) {
    assert(appConfiguration != null);
    assert(isNotEmpty(this.proxyBankingUrl));
  }

  Future<PaymentAuthorizationPayeeEntity> _inputToPayee(
    String proxyUniverse,
    String paymentAuthorizationId,
    PaymentAuthorizationPayeeInput input,
  ) async {
    String paymentEncashmentId = uuidFactory.v4();
    final encryptionService = SymmetricKeyEncryptionService();

    return PaymentAuthorizationPayeeEntity(
      proxyUniverse: proxyUniverse,
      paymentAuthorizationId: paymentAuthorizationId,
      paymentEncashmentId: paymentEncashmentId,
      payeeType: input.payeeType,
      proxyId: input.payeeProxyId,
      email: input.customerEmail,
      emailHash: await _computeHash(input.customerEmail),
      phone: input.customerPhone,
      phoneHash: await _computeHash(input.customerPhone),
      secret: input.secret,
      secretEncrypted: await encryptionService.encrypt(
        key: appConfiguration.passPhrase,
        encryptionAlgorithm: SymmetricKeyEncryptionService.ENCRYPTION_ALGORITHM,
        plainText: input.secret,
      ),
      secretHash: await _computeHash(input.secret),
    );
  }

  Future<HashValue> _computeHash(String input) {
    if (input == null) {
      return Future.value(null);
    }
    return cryptographyService.getHash(
      input: input,
      hashAlgorithm: 'SHA256',
    );
  }

  Future<List<PaymentAuthorizationPayeeEntity>> _inputsToPayees(
      String proxyUniverse, String paymentAuthorizationId, List<PaymentAuthorizationPayeeInput> inputs) async {
    return Future.wait(inputs.map((i) => _inputToPayee(proxyUniverse, paymentAuthorizationId, i)).toList());
  }

  Future<void> _uploadSecrets(List<PaymentAuthorizationPayeeEntity> payees) async {
    final encryptionService = SymmetricKeyEncryptionService();
    List<SecretForPhoneNumberRecipient> secretsForPhoneNumberRecipients = payees
        .where((payee) => payee.payeeType == PayeeTypeEnum.Phone)
        .map(
          (payee) => SecretForPhoneNumberRecipient(
            phoneNumber: payee.phone,
            secret: payee.secret ??
                encryptionService.decrypt(
                  key: appConfiguration.passPhrase,
                  cipherText: payee.secretEncrypted,
                ),
            secretHash: payee.secretHash,
          ),
        )
        .toList();
    List<SecretForEmailRecipient> secretsForEmailRecipients = payees
        .where((payee) => payee.payeeType == PayeeTypeEnum.Email)
        .map(
          (payee) => SecretForEmailRecipient(
            email: payee.email,
            secret: payee.secret ??
                encryptionService.decrypt(
                  key: appConfiguration.passPhrase,
                  cipherText: payee.secretEncrypted,
                ),
            secretHash: payee.secretHash,
          ),
        )
        .toList();
    if (secretsForPhoneNumberRecipients.isNotEmpty || secretsForEmailRecipients.isNotEmpty) {
      await secretsService.saveSecrets(secretsForPhoneNumberRecipients, secretsForEmailRecipients);
    }
  }

  Payee _payeeEntityToPayee(PaymentAuthorizationPayeeEntity payeeEntity) {
    return Payee(
      paymentEncashmentId: payeeEntity.paymentEncashmentId,
      payeeType: payeeEntity.payeeType,
      proxyId: payeeEntity.proxyId,
      emailHash: payeeEntity.emailHash,
      phoneHash: payeeEntity.phoneHash,
      secretHash: payeeEntity.secretHash,
    );
  }

  Future<PaymentAuthorizationEntity> createPaymentAuthorization(
    ProxyLocalizations localizations,
    ProxyAccountEntity proxyAccount,
    PaymentAuthorizationInput input,
  ) async {
    String paymentAuthorizationId = uuidFactory.v4();
    String proxyUniverse = proxyAccount.proxyUniverse;

    List<PaymentAuthorizationPayeeEntity> payeeEntityList =
        await _inputsToPayees(proxyUniverse, paymentAuthorizationId, input.payees);

    await _uploadSecrets(payeeEntityList);

    PaymentAuthorization request = PaymentAuthorization(
      paymentAuthorizationId: paymentAuthorizationId,
      proxyAccount: proxyAccount.signedProxyAccount,
      amount: Amount(
        currency: input.currency,
        value: input.amount,
      ),
      payees: payeeEntityList.map(_payeeEntityToPayee).toList(),
    );
    final signedPaymentAuthorization = await signMessage(
      signer: proxyAccount.ownerProxyId,
      request: request,
    );
    Uri paymentLink = await ServiceFactory.deepLinkService().createDeepLink(
      Uri.parse('${UrlConfig.PROXY_BANKING}/actions/accept-payment'
          '?proxyUniverse=$proxyUniverse&paymentAuthorizationId=$paymentAuthorizationId'),
      title: localizations.sharePaymentTitle,
      description: localizations.sharePaymentDescription,
    );

    PaymentAuthorizationEntity paymentAuthorizationEntity = _createAuthorizationEntity(
      proxyAccount: proxyAccount,
      signedPaymentAuthorization: signedPaymentAuthorization,
      paymentLink: paymentLink.toString(),
      payees: payeeEntityList,
    );

    try {
      final signedResponse = await sendAndReceive(
        url: proxyBankingUrl,
        signedRequest: signedPaymentAuthorization,
        responseParser: PaymentAuthorizationRegistered.fromJson,
      );
      paymentAuthorizationEntity = paymentAuthorizationEntity.copy(
        status: signedResponse.message.paymentAuthorizationStatus,
      );
    } catch (e) {
      print("Error while registering Payment Authorization: $e");
    }

    await _paymentAuthorizationStore.savePaymentAuthorization(paymentAuthorizationEntity);
    return paymentAuthorizationEntity;
  }

  Future<void> _refreshPaymentAuthorizationStatus(
    PaymentAuthorizationEntity authorizationEntity,
  ) async {
    print('Refreshing $authorizationEntity');
    final paymentAuthorization = authorizationEntity.signedPaymentAuthorization;
    PaymentAuthorizationStatusRequest request = PaymentAuthorizationStatusRequest(
      requestId: uuidFactory.v4(),
      paymentAuthorization: paymentAuthorization,
    );
    final signedRequest = await signMessage(
      signer: authorizationEntity.payerProxyId,
      request: request,
    );

    final signedResponse = await sendAndReceive(
      url: proxyBankingUrl,
      signedRequest: signedRequest,
      responseParser: PaymentAuthorizationStatusResponse.fromJson,
    );
    await _savePaymentAuthorizationStatus(
      authorizationEntity,
      signedResponse.message.paymentAuthorizationStatus,
    );
  }

  PaymentAuthorizationEntity _createAuthorizationEntity({
    @required ProxyAccountEntity proxyAccount,
    @required List<PaymentAuthorizationPayeeEntity> payees,
    @required SignedMessage<PaymentAuthorization> signedPaymentAuthorization,
    @required String paymentLink,
  }) {
    PaymentAuthorization paymentAuthorization = signedPaymentAuthorization.message;

    return PaymentAuthorizationEntity(
      proxyUniverse: proxyAccount.proxyUniverse,
      paymentAuthorizationId: paymentAuthorization.paymentAuthorizationId,
      status: PaymentAuthorizationStatusEnum.Created,
      amount: paymentAuthorization.amount,
      payerAccountId: proxyAccount.accountId,
      payerProxyId: proxyAccount.ownerProxyId,
      paymentAuthorizationLink: paymentLink,
      creationTime: DateTime.now(),
      lastUpdatedTime: DateTime.now(),
      signedPaymentAuthorization: signedPaymentAuthorization,
      completed: false,
      payees: payees,
    );
  }

  Future<PaymentAuthorizationEntity> _savePaymentAuthorizationStatus(
    PaymentAuthorizationEntity entity,
    PaymentAuthorizationStatusEnum status,
  ) async {
    // print("Setting ${entity.paymentAuthorizationEntityId} status to $localStatus");
    if (status == null || status == entity.status) {
      return entity;
    }
    PaymentAuthorizationEntity clone = entity.copy(
      status: status ?? entity.status,
      lastUpdatedTime: DateTime.now(),
    );
    await _paymentAuthorizationStore.savePaymentAuthorization(clone);
    return clone;
  }

  Future<SignedMessage<PaymentAuthorization>> fetchPaymentAuthorization({
    @required String proxyUniverse,
    @required String paymentAuthorizationId,
  }) async {
    String jsonResponse = await get(httpClientFactory(),
        "${UrlConfig.PROXY_BANKING}/payment-authorization?proxyUniverse=$proxyUniverse&paymentAuthorizationId=$paymentAuthorizationId");
    return messageFactory.buildAndVerifySignedMessage(jsonResponse, PaymentAuthorization.fromJson);
  }

  Future<void> refreshPaymentAuthorizationStatus({
    String proxyUniverse,
    String paymentAuthorizationId,
  }) async {
    PaymentAuthorizationEntity paymentAuthorizationEntity = await _paymentAuthorizationStore.fetchPaymentAuthorization(
      proxyUniverse: proxyUniverse,
      paymentAuthorizationId: paymentAuthorizationId,
    );
    if (paymentAuthorizationEntity != null) {
      await _refreshPaymentAuthorizationStatus(paymentAuthorizationEntity);
    }
  }

  Future<void> processPaymentAuthorizationUpdatedAlert(PaymentAuthorizationUpdatedAlert alert) {
    return refreshPaymentAuthorizationStatus(
      proxyUniverse: alert.proxyUniverse,
      paymentAuthorizationId: alert.paymentAuthorizationId,
    );
  }

  Future<void> processPaymentAuthorizationUpdatedLiteAlert(PaymentAuthorizationUpdatedLiteAlert alert) {
    return refreshPaymentAuthorizationStatus(
      proxyUniverse: alert.proxyUniverse,
      paymentAuthorizationId: alert.paymentAuthorizationId,
    );
  }
}
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/db/firestore_utils.dart';
import 'package:proxy_id/identity/model/deposit_entity.dart';
import 'package:proxy_id/identity/model/deposit_event.dart';

import 'cleanup_service.dart';
import 'event_store.dart';

class DepositStore with ProxyUtils {
  final AppConfiguration appConfiguration;
  final EventStore _eventStore;
  final CleanupService _cleanupService;

  DepositStore(this.appConfiguration)
      : _eventStore = EventStore(appConfiguration),
        _cleanupService = CleanupService(appConfiguration);

  DocumentReference _ref({
    @required String proxyUniverse,
    @required String depositId,
  }) {
    return FirestoreUtils.accountRootRef(appConfiguration.accountId, proxyUniverse: proxyUniverse)
        .collection('deposits')
        .document(depositId);
  }

  Future<DepositEntity> fetchDeposit({
    @required String proxyUniverse,
    @required String depositId,
  }) async {
    DocumentSnapshot snapshot = await _ref(
      proxyUniverse: proxyUniverse,
      depositId: depositId,
    ).get();
    if (snapshot.exists) {
      return DepositEntity.fromJson(snapshot.data);
    }
    return null;
  }

  Stream<DepositEntity> subscribeForDeposit({
    @required String proxyUniverse,
    @required String depositId,
  }) {
    return _ref(
      proxyUniverse: proxyUniverse,
      depositId: depositId,
    ).snapshots().map(
          (s) => s.exists ? DepositEntity.fromJson(s.data) : null,
        );
  }

  Future<DepositEntity> saveDeposit(DepositEntity deposit) async {
    final ref = _ref(proxyUniverse: deposit.proxyUniverse, depositId: deposit.depositId);
    await Future.wait([
      ref.setData(deposit.toJson()),
      _eventStore.saveEvent(DepositEvent.fromDepositEntity(deposit)),
      _cleanupService.onDeposit(deposit)
    ]);
    return deposit;
  }
}

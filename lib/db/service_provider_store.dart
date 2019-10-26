import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/identity/model/service_provider_entity.dart';

class ServiceProviderStore with ProxyUtils {
  final CollectionReference _root;

  ServiceProviderStore() : _root = Firestore.instance.collection('/service-providers');

  Future<ServiceProviderEntity> fetchBank({
    @required String proxyUniverse,
    ProxyId serviceProviderProxyId,
    String serviceProviderId,
  }) async {
    var query = _root.where(ServiceProviderEntity.PROXY_UNIVERSE, isEqualTo: proxyUniverse);
    if (serviceProviderProxyId != null) {
      query = query.where(ServiceProviderEntity.SERVICE_PROVIDER_ID, isEqualTo: serviceProviderProxyId.id).where(
            ServiceProviderEntity.SERVICE_PROVIDER_SHA256_THUMBPRINT,
            isEqualTo: serviceProviderProxyId.sha256Thumbprint,
          );
    } else if (serviceProviderId != null) {
      query = query.where(ServiceProviderEntity.SERVICE_PROVIDER_ID, isEqualTo: serviceProviderId);
    } else {
      throw ArgumentError("Either serviceProviderProxyId or serviceProviderId must be specified");
    }
    return _querySnapshotToAccounts(await query.getDocuments()).first;
  }

  ServiceProviderEntity _documentSnapshotToAccount(DocumentSnapshot snapshot) {
    if (snapshot != null && snapshot.exists) {
      return ServiceProviderEntity.fromJson(snapshot.data);
    } else {
      return null;
    }
  }

  List<ServiceProviderEntity> _querySnapshotToAccounts(QuerySnapshot snapshot) {
    if (snapshot.documents != null) {
      return snapshot.documents.map(_documentSnapshotToAccount).where((a) => a != null).toList();
    } else {
      return [];
    }
  }
}

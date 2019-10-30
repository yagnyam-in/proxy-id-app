import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/identity/model/identity_provider_entity.dart';

class IdentityProviderStore with ProxyUtils {
  final CollectionReference _root;

  IdentityProviderStore() : _root = Firestore.instance.collection('/identity-providers');

  Future<IdentityProviderEntity> fetchIdentityProvider({
    @required String proxyUniverse,
    ProxyId identityProviderProxyId,
    String identityProviderId,
  }) async {
    var query = _root.where(IdentityProviderEntity.PROXY_UNIVERSE, isEqualTo: proxyUniverse);
    if (identityProviderProxyId != null) {
      query = query.where(IdentityProviderEntity.IDENTITY_PROVIDER_ID, isEqualTo: identityProviderProxyId.id).where(
            IdentityProviderEntity.IDENTITY_PROVIDER_SHA256_THUMBPRINT,
            isEqualTo: identityProviderProxyId.sha256Thumbprint,
          );
    } else if (identityProviderId != null) {
      query = query.where(IdentityProviderEntity.IDENTITY_PROVIDER_ID, isEqualTo: identityProviderId);
    } else {
      throw ArgumentError("Either identityProviderProxyId or identityProviderId must be specified");
    }
    print("Query: $query");
    return _querySnapshotToAccounts(await query.getDocuments()).first;
  }

  IdentityProviderEntity _documentSnapshotToAccount(DocumentSnapshot snapshot) {
    if (snapshot != null && snapshot.exists) {
      return IdentityProviderEntity.fromJson(snapshot.data);
    } else {
      return null;
    }
  }

  List<IdentityProviderEntity> _querySnapshotToAccounts(QuerySnapshot snapshot) {
    if (snapshot.documents != null) {
      return snapshot.documents.map(_documentSnapshotToAccount).where((a) => a != null).toList();
    } else {
      return [];
    }
  }
}

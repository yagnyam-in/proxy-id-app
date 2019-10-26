import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/db/firestore_utils.dart';
import 'package:proxy_id/model/dismissed_enticement_entity.dart';

class DismissedEnticementStore with ProxyUtils {
  final AppConfiguration appConfiguration;

  DismissedEnticementStore(this.appConfiguration);

  CollectionReference enticementsRef() {
    return FirestoreUtils.accountRootRef(appConfiguration.accountId, proxyUniverse: appConfiguration.proxyUniverse)
        .collection('dismissed-enticements');
  }

  DocumentReference ref(String enticementId) {
    return enticementsRef().document(enticementId);
  }

  Stream<List<DismissedEnticementEntity>> subscribeForEnticements() {
    print("Subscribing for dismissed enticements");
    return enticementsRef().snapshots().map(_querySnapshotToEntities);
  }

  Future<List<DismissedEnticementEntity>> fetchEnticements() async {
    print("Fetching all dismissed enticements");
    return _querySnapshotToEntities(await enticementsRef().getDocuments());
  }

  DismissedEnticementEntity _documentSnapshotToEntity(DocumentSnapshot snapshot) {
    if (snapshot != null && snapshot.exists) {
      return DismissedEnticementEntity.fromJson(snapshot.data);
    } else {
      return null;
    }
  }

  List<DismissedEnticementEntity> _querySnapshotToEntities(QuerySnapshot snapshot) {
    if (snapshot.documents != null) {
      return snapshot.documents.map(_documentSnapshotToEntity).where((a) => a != null).toList();
    } else {
      return [];
    }
  }

  Future<DismissedEnticementEntity> saveEnticement(DismissedEnticementEntity enticement) async {
    await ref(enticement.id).setData(enticement.toJson());
    return enticement;
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/db/firestore_utils.dart';
import 'package:proxy_id/identity/model/pending_subject_entity.dart';

import 'cleanup_service.dart';

class PendingSubjectStore with ProxyUtils {
  final AppConfiguration appConfiguration;
  final CleanupService _cleanupService;

  PendingSubjectStore(this.appConfiguration) : _cleanupService = CleanupService(appConfiguration) {
    assert(appConfiguration != null);
  }

  CollectionReference _subjectsRef({
    @required String proxyUniverse,
  }) {
    return FirestoreUtils.accountRootRef(appConfiguration.accountId, proxyUniverse: proxyUniverse)
        .collection('pending-proxy-subjects');
  }

  DocumentReference _ref({
    @required String proxyUniverse,
    @required String id,
  }) {
    return _subjectsRef(proxyUniverse: proxyUniverse).document(id);
  }

  Stream<List<PendingSubjectEntity>> subscribeForPendingSubjects() {
    return _subjectsRef(proxyUniverse: appConfiguration.proxyUniverse)
        .where(PendingSubjectEntity.ACTIVE, isEqualTo: true)
        .snapshots()
        .map(_querySnapshotToPendingSubjects);
  }

  Stream<PendingSubjectEntity> subscribeForSubject({@required String proxyUniverse, @required String id}) {
    print("subscribeForSubject(proxyUniverse: $proxyUniverse, id: $id)");
    return _ref(proxyUniverse: proxyUniverse, id: id).snapshots().map(_documentSnapshotToPendingSubject);
  }

  Future<PendingSubjectEntity> fetchPendingSubject({@required String proxyUniverse, @required String id}) async {
    DocumentSnapshot doc = await _ref(proxyUniverse: proxyUniverse, id: id).get();
    return _documentSnapshotToPendingSubject(doc);
  }

  PendingSubjectEntity _documentSnapshotToPendingSubject(DocumentSnapshot snapshot) {
    if (snapshot != null && snapshot.exists) {
      final pendingSubject = PendingSubjectEntity.fromJson(snapshot.data);
      if (isEmpty(pendingSubject.id)) {
        return pendingSubject.copy(id: snapshot.documentID);
      }
      return pendingSubject;
    } else {
      return null;
    }
  }

  List<PendingSubjectEntity> _querySnapshotToPendingSubjects(QuerySnapshot snapshot) {
    if (snapshot.documents != null) {
      return snapshot.documents.map(_documentSnapshotToPendingSubject).where((a) => a != null).toList();
    } else {
      return [];
    }
  }

  Future<PendingSubjectEntity> savePendingSubject(PendingSubjectEntity subject) async {
    final ref = _ref(proxyUniverse: subject.proxyUniverse, id: subject.id);
    final data = {
      'id': ref.documentID,
      ...subject.toJson(),
    };
    await Future.wait([
      ref.setData(data),
      _cleanupService.onPendingProxySubject(subject),
    ]);
    return subject;
  }

  Future<void> archivePendingSubject(PendingSubjectEntity subject) {
    return _ref(
      proxyUniverse: subject.proxyUniverse,
      id: subject.id,
    ).setData({
      PendingSubjectEntity.ACTIVE: false,
    }, merge: true);
  }

  Future<void> deletePendingSubject(PendingSubjectEntity subject) {
    return _ref(
      proxyUniverse: subject.proxyUniverse,
      id: subject.id,
    ).delete();
  }
}

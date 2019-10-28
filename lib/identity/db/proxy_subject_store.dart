import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/db/firestore_utils.dart';
import 'package:proxy_id/identity/model/proxy_subject_entity.dart';
import 'package:proxy_messages/identity.dart';

import 'cleanup_service.dart';

class ProxySubjectStore with ProxyUtils {
  final AppConfiguration appConfiguration;
  final CleanupService _cleanupService;

  ProxySubjectStore(this.appConfiguration) : _cleanupService = CleanupService(appConfiguration) {
    assert(appConfiguration != null);
  }

  CollectionReference _subjectsRef({
    @required String proxyUniverse,
  }) {
    return FirestoreUtils.accountRootRef(appConfiguration.accountId, proxyUniverse: proxyUniverse)
        .collection('proxy-subjects');
  }

  DocumentReference _ref({
    @required String proxyUniverse,
    @required String subjectId,
  }) {
    return _subjectsRef(proxyUniverse: proxyUniverse).document(subjectId);
  }

  Stream<List<ProxySubjectEntity>> subscribeForSubjects() {
    return _subjectsRef(proxyUniverse: appConfiguration.proxyUniverse)
        .where(ProxySubjectEntity.ACTIVE, isEqualTo: true)
        .snapshots()
        .map(_querySnapshotToSubjects);
  }

  Stream<ProxySubjectEntity> subscribeForSubject(ProxySubjectId subjectId) {
    return _ref(proxyUniverse: subjectId.proxyUniverse, subjectId: subjectId.subjectId)
        .snapshots()
        .map(_documentSnapshotToSubject);
  }

  Future<ProxySubjectEntity> fetchSubject(ProxySubjectId subjectId) async {
    DocumentSnapshot doc = await _ref(proxyUniverse: subjectId.proxyUniverse, subjectId: subjectId.subjectId).get();
    return _documentSnapshotToSubject(doc);
  }

  Future<List<ProxySubjectEntity>> fetchActiveSubjects({
    @required ProxyId masterProxyId,
    @required String proxyUniverse,
  }) async {
    QuerySnapshot querySnapshot = await _subjectsRef(proxyUniverse: proxyUniverse)
        .where(ProxySubjectEntity.ID_OF_OWNER_PROXY_ID, isEqualTo: masterProxyId.id)
        .where(ProxySubjectEntity.ACTIVE, isEqualTo: true)
        .getDocuments();
    return _querySnapshotToSubjects(querySnapshot).where((a) => a.ownerProxyId == masterProxyId).toList();
  }

  ProxySubjectEntity _documentSnapshotToSubject(DocumentSnapshot snapshot) {
    if (snapshot != null && snapshot.exists) {
      return ProxySubjectEntity.fromJson(snapshot.data);
    } else {
      return null;
    }
  }

  List<ProxySubjectEntity> _querySnapshotToSubjects(QuerySnapshot snapshot) {
    if (snapshot.documents != null) {
      return snapshot.documents.map(_documentSnapshotToSubject).where((a) => a != null).toList();
    } else {
      return [];
    }
  }

  Future<ProxySubjectEntity> saveSubject(ProxySubjectEntity subject) async {
    final ref = _ref(proxyUniverse: subject.proxyUniverse, subjectId: subject.subjectId.subjectId);
    await Future.wait([
      ref.setData(subject.toJson()),
      _cleanupService.onProxySubject(subject),
    ]);
    return subject;
  }

  Future<void> archiveSubject(ProxySubjectEntity subject) async {
    final ref = _ref(proxyUniverse: subject.proxyUniverse, subjectId: subject.subjectId.subjectId);
    return ref.setData({ProxySubjectEntity.ACTIVE: false}, merge: true);
  }

  Future<void> deleteSubject(ProxySubjectEntity subject) {
    return _ref(
      proxyUniverse: subject.proxyUniverse,
      subjectId: subject.subjectId.subjectId,
    ).delete();
  }
}

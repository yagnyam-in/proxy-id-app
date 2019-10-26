// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_subject_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProxySubjectEntity _$ProxySubjectEntityFromJson(Map json) {
  return ProxySubjectEntity(
    subjectId: ProxySubjectId.fromJson(json['subjectId'] as Map),
    subjectName: json['subjectName'] as String,
    issuerName: json['issuerName'] as String,
    ownerProxyId: ProxyId.fromJson(json['ownerProxyId'] as Map),
    signedProxySubject:
        ProxySubject.signedMessageFromJson(json['signedProxySubject'] as Map),
    active: json['active'] as bool,
  );
}

Map<String, dynamic> _$ProxySubjectEntityToJson(ProxySubjectEntity instance) {
  final val = <String, dynamic>{
    'subjectId': instance.subjectId.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('subjectName', instance.subjectName);
  writeNotNull('issuerName', instance.issuerName);
  val['ownerProxyId'] = instance.ownerProxyId.toJson();
  val['signedProxySubject'] = instance.signedProxySubject.toJson();
  val['active'] = instance.active;
  return val;
}

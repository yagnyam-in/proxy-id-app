// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_subject_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProxySubjectEntity _$ProxySubjectEntityFromJson(Map json) {
  return ProxySubjectEntity(
    subjectIdType:
        _$enumDecode(_$SubjectIdTypeEnumEnumMap, json['subjectIdType']),
    subjectId: ProxySubjectId.fromJson(json['subjectId'] as Map),
    ownerProxyId: ProxyId.fromJson(json['ownerProxyId'] as Map),
    identityProviderProxyId:
        ProxyId.fromJson(json['identityProviderProxyId'] as Map),
    subjectName: json['subjectName'] as String,
    issuerName: json['issuerName'] as String,
    signedProxySubject:
        ProxySubject.signedMessageFromJson(json['signedProxySubject'] as Map),
    active: json['active'] as bool,
  );
}

Map<String, dynamic> _$ProxySubjectEntityToJson(ProxySubjectEntity instance) {
  final val = <String, dynamic>{
    'subjectIdType': _$SubjectIdTypeEnumEnumMap[instance.subjectIdType],
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
  val['identityProviderProxyId'] = instance.identityProviderProxyId.toJson();
  writeNotNull('signedProxySubject', instance.signedProxySubject?.toJson());
  val['active'] = instance.active;
  return val;
}

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

const _$SubjectIdTypeEnumEnumMap = {
  SubjectIdTypeEnum.IN_AADHAAR: 'IN_AADHAAR',
};

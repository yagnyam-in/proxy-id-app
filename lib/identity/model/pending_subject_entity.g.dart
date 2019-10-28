// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_subject_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingSubjectEntity _$PendingSubjectEntityFromJson(Map json) {
  return PendingSubjectEntity(
    subjectIdType:
        _$enumDecode(_$SubjectIdTypeEnumEnumMap, json['subjectIdType']),
    proxyUniverse: json['proxyUniverse'] as String,
    ownerProxyId: ProxyId.fromJson(json['ownerProxyId'] as Map),
    issuerProxyId: ProxyId.fromJson(json['issuerProxyId'] as Map),
    signedAadhaarVerificationChallenge:
        AadhaarVerificationChallenge.signedMessageFromJson(
            json['signedAadhaarVerificationChallenge'] as Map),
    active: json['active'] as bool,
  );
}

Map<String, dynamic> _$PendingSubjectEntityToJson(
    PendingSubjectEntity instance) {
  final val = <String, dynamic>{
    'subjectIdType': _$SubjectIdTypeEnumEnumMap[instance.subjectIdType],
    'proxyUniverse': instance.proxyUniverse,
    'ownerProxyId': instance.ownerProxyId.toJson(),
    'issuerProxyId': instance.issuerProxyId.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('signedAadhaarVerificationChallenge',
      instance.signedAadhaarVerificationChallenge?.toJson());
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

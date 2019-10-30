// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_provider_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdentityProviderEntity _$IdentityProviderEntityFromJson(Map json) {
  return IdentityProviderEntity(
    id: json['id'] as String,
    proxyUniverse: json['proxyUniverse'] as String,
    identityProviderProxyId:
        ProxyId.fromJson(json['identityProviderProxyId'] as Map),
    serviceProviderName: json['serviceProviderName'] as String,
    apiUrl: json['apiUrl'] as String,
  );
}

Map<String, dynamic> _$IdentityProviderEntityToJson(
    IdentityProviderEntity instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'proxyUniverse': instance.proxyUniverse,
    'identityProviderProxyId': instance.identityProviderProxyId.toJson(),
    'apiUrl': instance.apiUrl,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('serviceProviderName', instance.serviceProviderName);
  return val;
}

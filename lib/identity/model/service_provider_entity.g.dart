// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_provider_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceProviderEntity _$ServiceProviderEntityFromJson(Map json) {
  return ServiceProviderEntity(
    id: json['id'] as String,
    proxyUniverse: json['proxyUniverse'] as String,
    serviceProviderProxyId:
        ProxyId.fromJson(json['serviceProviderProxyId'] as Map),
    serviceProviderName: json['serviceProviderName'] as String,
    apiUrl: json['apiUrl'] as String,
  );
}

Map<String, dynamic> _$ServiceProviderEntityToJson(
    ServiceProviderEntity instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'proxyUniverse': instance.proxyUniverse,
    'serviceProviderProxyId': instance.serviceProviderProxyId.toJson(),
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

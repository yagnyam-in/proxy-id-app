// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_provider_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceProviderEntity _$ServiceProviderEntityFromJson(Map json) {
  return ServiceProviderEntity(
    proxyUniverse: json['proxyUniverse'] as String,
    serviceProviderProxyId:
        ProxyId.fromJson(json['serviceProviderProxyId'] as Map),
    serviceProviderName: json['serviceProviderName'] as String,
    supportedCurrencies:
        (json['supportedCurrencies'] as List).map((e) => e as String).toSet(),
    apiUrl: json['apiUrl'] as String,
  );
}

Map<String, dynamic> _$ServiceProviderEntityToJson(
    ServiceProviderEntity instance) {
  final val = <String, dynamic>{
    'proxyUniverse': instance.proxyUniverse,
    'serviceProviderProxyId': instance.serviceProviderProxyId.toJson(),
    'supportedCurrencies': instance.supportedCurrencies.toList(),
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

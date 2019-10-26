import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';

part 'service_provider_entity.g.dart';

@JsonSerializable()
class ServiceProviderEntity with ProxyUtils {
  static const PROXY_UNIVERSE = 'proxyUniverse';
  static const SERVICE_PROVIDER_ID = 'serviceProviderId';
  static const SERVICE_PROVIDER_SHA256_THUMBPRINT = 'serviceProviderSha256Thumbprint';

  @JsonKey(name: PROXY_UNIVERSE, nullable: false)
  final String proxyUniverse;

  @JsonKey(nullable: false)
  final ProxyId serviceProviderProxyId;

  @JsonKey(nullable: false)
  final Set<String> supportedCurrencies;

  @JsonKey(nullable: false)
  final String apiUrl;

  @JsonKey(name: SERVICE_PROVIDER_ID, nullable: false)
  final String serviceProviderId;

  @JsonKey(name: SERVICE_PROVIDER_SHA256_THUMBPRINT, nullable: false)
  final String serviceProviderSha256Thumbprint;

  @JsonKey(nullable: true)
  final String serviceProviderName;

  ServiceProviderEntity({
    @required this.proxyUniverse,
    @required this.serviceProviderProxyId,
    @required this.serviceProviderName,
    @required this.supportedCurrencies,
    @required this.apiUrl,
  })  : serviceProviderId = serviceProviderProxyId.id,
        serviceProviderSha256Thumbprint = serviceProviderProxyId.sha256Thumbprint;

  Map<String, dynamic> toJson() => _$ServiceProviderEntityToJson(this);

  static ServiceProviderEntity fromJson(Map json) => _$ServiceProviderEntityFromJson(json);
}

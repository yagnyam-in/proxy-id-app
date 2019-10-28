import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';

part 'service_provider_entity.g.dart';

@JsonSerializable()
class ServiceProviderEntity with ProxyUtils {
  static const PROXY_UNIVERSE = 'proxyUniverse';
  static const SERVICE_PROVIDER_ID = 'serviceProviderProxyId.id';
  static const SERVICE_PROVIDER_SHA256_THUMBPRINT = 'serviceProviderProxyId.sha256Thumbprint';

  @JsonKey(nullable: false)
  final String id;

  @JsonKey(name: PROXY_UNIVERSE, nullable: false)
  final String proxyUniverse;

  @JsonKey(nullable: false)
  final ProxyId serviceProviderProxyId;

  @JsonKey(nullable: false)
  final String apiUrl;

  @JsonKey(nullable: true)
  final String serviceProviderName;

  ServiceProviderEntity({
    @required this.id,
    @required this.proxyUniverse,
    @required this.serviceProviderProxyId,
    @required this.serviceProviderName,
    @required this.apiUrl,
  });

  Map<String, dynamic> toJson() => _$ServiceProviderEntityToJson(this);

  static ServiceProviderEntity fromJson(Map json) => _$ServiceProviderEntityFromJson(json);
}

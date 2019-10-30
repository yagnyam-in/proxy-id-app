import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';

part 'identity_provider_entity.g.dart';

@JsonSerializable()
class IdentityProviderEntity with ProxyUtils {
  static const PROXY_UNIVERSE = 'proxyUniverse';
  static const IDENTITY_PROVIDER_ID = 'identityProviderProxyId.id';
  static const IDENTITY_PROVIDER_SHA256_THUMBPRINT = 'identityProviderProxyId.sha256Thumbprint';

  @JsonKey(nullable: false)
  final String id;

  @JsonKey(name: PROXY_UNIVERSE, nullable: false)
  final String proxyUniverse;

  @JsonKey(nullable: false)
  final ProxyId identityProviderProxyId;

  @JsonKey(nullable: false)
  final String apiUrl;

  @JsonKey(nullable: true)
  final String serviceProviderName;

  IdentityProviderEntity({
    @required this.id,
    @required this.proxyUniverse,
    @required this.identityProviderProxyId,
    @required this.serviceProviderName,
    @required this.apiUrl,
  });

  Map<String, dynamic> toJson() => _$IdentityProviderEntityToJson(this);

  static IdentityProviderEntity fromJson(Map json) => _$IdentityProviderEntityFromJson(json);
}

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_messages/banking.dart';
import 'package:proxy_messages/identity.dart';

part 'proxy_subject_entity.g.dart';

@JsonSerializable()
class ProxySubjectEntity with ProxyUtils {
  static const String ACTIVE = 'active';
  static const String ID_OF_OWNER_PROXY_ID = 'idOfOwnerProxyId';

  @JsonKey(nullable: false)
  final ProxySubjectId subjectId;

  @JsonKey(nullable: true)
  final String subjectName;

  @JsonKey(nullable: true)
  final String issuerName;

  @JsonKey(nullable: false)
  final ProxyId ownerProxyId;

  @JsonKey(nullable: false, fromJson: ProxySubject.signedMessageFromJson)
  final SignedMessage<ProxySubject> signedProxySubject;

  @JsonKey(name: ACTIVE, nullable: false)
  final bool active;

  @JsonKey(name: ID_OF_OWNER_PROXY_ID, nullable: false)
  final String idOfOwnerProxyId;

  String get validName => isNotEmpty(subjectName) ? subjectName : subjectId.subjectId;

  String get validIssuerName => isNotEmpty(issuerName) ? issuerName : subjectId.issuerId;

  String get proxyUniverse => subjectId.proxyUniverse;

  ProxySubjectEntity({
    @required this.subjectId,
    @required this.subjectName,
    @required this.issuerName,
    @required this.ownerProxyId,
    @required this.signedProxySubject,
    bool active,
  })  : this.active = active ?? true,
        this.idOfOwnerProxyId = ownerProxyId.id;

  ProxySubjectEntity copy({
    Amount balance,
    String subjectName,
    String issuerName,
    bool active,
  }) {
    return ProxySubjectEntity(
      subjectId: this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      issuerName: issuerName ?? this.issuerName,
      ownerProxyId: this.ownerProxyId,
      signedProxySubject: this.signedProxySubject,
      active: active ?? this.active,
    );
  }

  @override
  String toString() {
    return "ProxySubjectEntity(name: $validName, issuer: $validIssuerName, active: $active)";
  }

  Map<String, dynamic> toJson() => _$ProxySubjectEntityToJson(this);

  static ProxySubjectEntity fromJson(Map json) => _$ProxySubjectEntityFromJson(json);
}

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_messages/identity.dart';

part 'proxy_subject_entity.g.dart';

@JsonSerializable()
class ProxySubjectEntity with ProxyUtils {
  static const String ACTIVE = 'active';
  static const String ID_OF_OWNER_PROXY_ID = 'ownerProxyId.id';

  @JsonKey(nullable: false)
  final SubjectIdTypeEnum subjectIdType;

  @JsonKey(nullable: false)
  final ProxySubjectId subjectId;

  @JsonKey(nullable: true)
  final String subjectName;

  @JsonKey(nullable: true)
  final String issuerName;

  @JsonKey(nullable: false)
  final ProxyId ownerProxyId;

  @JsonKey(nullable: false)
  final ProxyId identityProviderProxyId;

  @JsonKey(nullable: true, fromJson: ProxySubject.signedMessageFromJson)
  final SignedMessage<ProxySubject> signedProxySubject;

  @JsonKey(name: ACTIVE, nullable: false)
  final bool active;

  String get proxyUniverse => subjectId.proxyUniverse;

  SubjectDetails get subjectDetails => signedProxySubject?.message?.subjectDetails;

  String get aadhaarNumber => subjectDetails?.aadhaarNumber;

  String get formatterAadhaarNumber {
    if (isNotEmpty(aadhaarNumber)) {
      return "${aadhaarNumber.substring(0, 4)}-${aadhaarNumber.substring(4, 8)}-${aadhaarNumber.substring(8, 12)}";
    }
    return aadhaarNumber;
  }

  ProxySubjectEntity({
    @required this.subjectIdType,
    @required this.subjectId,
    @required this.ownerProxyId,
    @required this.identityProviderProxyId,
    @required this.subjectName,
    @required this.issuerName,
    this.signedProxySubject,
    bool active,
  }) : this.active = active ?? true;

  factory ProxySubjectEntity.fromProxySubject(SignedMessage<ProxySubject> signedProxySubject) {
    return ProxySubjectEntity(
      subjectIdType: SubjectIdTypeEnum.IN_AADHAAR,
      subjectId: signedProxySubject.message.proxySubjectId,
      ownerProxyId: signedProxySubject.message.ownerProxyId,
      identityProviderProxyId: signedProxySubject.message.identityProviderProxyId,
      subjectName: signedProxySubject.message.subjectDetails?.name,
      issuerName: signedProxySubject.message.identityProviderProxyId.id,
      signedProxySubject: signedProxySubject,
      active: true,
    );
  }

  ProxySubjectEntity copy({
    String subjectName,
    String issuerName,
    bool active,
  }) {
    return ProxySubjectEntity(
      subjectIdType: subjectIdType,
      subjectId: subjectId,
      ownerProxyId: ownerProxyId,
      identityProviderProxyId: identityProviderProxyId,
      signedProxySubject: signedProxySubject,
      subjectName: subjectName ?? this.subjectName,
      issuerName: issuerName ?? this.issuerName,
      active: active ?? this.active,
    );
  }

  @override
  String toString() {
    return "ProxySubjectEntity(subject: ${subjectName ?? subjectId.subjectId}, issuer: ${issuerName ?? identityProviderProxyId.id}, active: $active)";
  }

  Map<String, dynamic> toJson() => _$ProxySubjectEntityToJson(this);

  static ProxySubjectEntity fromJson(Map json) => _$ProxySubjectEntityFromJson(json);
}

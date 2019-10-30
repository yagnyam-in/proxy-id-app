import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_messages/identity.dart';

part 'pending_subject_entity.g.dart';

@JsonSerializable()
class PendingSubjectEntity with ProxyUtils {
  static const String ACTIVE = 'active';
  static const String ID_OF_OWNER_PROXY_ID = 'ownerProxyId.id';

  @JsonKey(ignore: true)
  final String id;

  @JsonKey(nullable: false)
  final SubjectIdTypeEnum subjectIdType;

  @JsonKey(nullable: false)
  final String proxyUniverse;

  @JsonKey(nullable: false)
  final ProxyId ownerProxyId;

  @JsonKey(nullable: false)
  final ProxyId identityProviderProxyId;

  @JsonKey(nullable: true, fromJson: AadhaarVerificationChallenge.signedMessageFromJson)
  final SignedMessage<AadhaarVerificationChallenge> signedAadhaarVerificationChallenge;

  @JsonKey(name: ACTIVE, nullable: false)
  final bool active;

  @JsonKey(nullable: false)
  final bool verified;

  String get aadhaarNumber => signedAadhaarVerificationChallenge?.message?.aadhaarNumber;

  String get formatterAadhaarNumber {
    if (isNotEmpty(aadhaarNumber)) {
      return "${aadhaarNumber.substring(0, 4)}-${aadhaarNumber.substring(4, 8)}-${aadhaarNumber.substring(8, 12)}";
    }
    return aadhaarNumber;
  }

  PendingSubjectEntity({
    this.id,
    @required this.subjectIdType,
    @required this.proxyUniverse,
    @required this.ownerProxyId,
    @required this.identityProviderProxyId,
    @required this.signedAadhaarVerificationChallenge,
    bool active,
    bool verified,
  })  : this.active = active ?? true,
        this.verified = verified ?? false;

  factory PendingSubjectEntity.fromAadhaarVerificationChallenge(
      SignedMessage<AadhaarVerificationChallenge> signedAadhaarVerificationChallenge) {
    return PendingSubjectEntity(
      subjectIdType: SubjectIdTypeEnum.IN_AADHAAR,
      proxyUniverse: signedAadhaarVerificationChallenge.message.proxyUniverse,
      ownerProxyId: signedAadhaarVerificationChallenge.message.ownerProxyId,
      identityProviderProxyId: signedAadhaarVerificationChallenge.message.identityProviderProxyId,
      signedAadhaarVerificationChallenge: signedAadhaarVerificationChallenge,
      active: true,
      verified: false,
    );
  }

  PendingSubjectEntity copy({String id, bool active, bool verified}) {
    return PendingSubjectEntity(
      id: id ?? this.id,
      subjectIdType: subjectIdType,
      proxyUniverse: proxyUniverse,
      ownerProxyId: ownerProxyId,
      identityProviderProxyId: identityProviderProxyId,
      signedAadhaarVerificationChallenge: signedAadhaarVerificationChallenge,
      active: active ?? this.active,
      verified: verified ?? this.verified,
    );
  }

  @override
  String toString() {
    return "PendingSubjectEntity(subjectIdType: $subjectIdType, ownerProxyId: $ownerProxyId)";
  }

  Map<String, dynamic> toJson() => _$PendingSubjectEntityToJson(this);

  static PendingSubjectEntity fromJson(Map json) => _$PendingSubjectEntityFromJson(json);
}

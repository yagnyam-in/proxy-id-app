import 'package:flutter/material.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/identity/model/pending_subject_entity.dart';
import 'package:proxy_id/identity/services/identity_service_factory.dart';
import 'package:proxy_id/identity/subject_input_dialog.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/widgets/basic_types.dart';

mixin ProxySubjectsHelper {
  AppConfiguration get appConfiguration;

  void showToast(String message);

  Future<T> invoke<T>(
    FutureCallback<T> callback, {
    String name,
    bool silent = false,
    VoidCallback onError,
  });

  Future<void> addProxySubject(BuildContext context) async {
    SubjectInput subjectInput = await _acceptSubjectInput(context);
    if (subjectInput == null) {
      return null;
    }
    final pendingSubject = await invoke(
      () => IdentityServiceFactory.identityService(appConfiguration).initiateSubjectVerification(
        ownerProxyId: appConfiguration.masterProxyId,
        proxyUniverse: appConfiguration.proxyUniverse,
        input: subjectInput,
      ),
      name: 'Initiate Subject Verification',
      onError: () => showToast(ProxyLocalizations.of(context).somethingWentWrong),
    );
    print("Added $pendingSubject");
  }


  Future<SubjectInput> _acceptSubjectInput(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute<SubjectInput>(
      builder: (context) => SubjectInputDialog(
        appConfiguration,
      ),
      fullscreenDialog: true,
    ));
  }
}

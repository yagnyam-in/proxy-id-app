import 'package:flutter/material.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/identity/db/pending_subject_store.dart';
import 'package:proxy_id/identity/model/pending_subject_entity.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/model/action_menu_item.dart';
import 'package:proxy_id/widgets/async_helper.dart';
import 'package:proxy_id/widgets/loading.dart';

import 'proxy_subject_page.dart';
import 'services/identity_service_factory.dart';

class PendingSubjectPage extends StatefulWidget {
  final AppConfiguration appConfiguration;
  final PendingSubjectEntity pendingSubject;

  const PendingSubjectPage(
    this.appConfiguration, {
    Key key,
    @required this.pendingSubject,
  }) : super(key: key);

  @override
  PendingSubjectPageState createState() {
    return PendingSubjectPageState(
      appConfiguration: appConfiguration,
      pendingSubject: pendingSubject,
    );
  }
}

class PendingSubjectPageState extends LoadingSupportState<PendingSubjectPage> {
  static const String CANCEL = "cancel";

  final AppConfiguration appConfiguration;
  final PendingSubjectEntity pendingSubject;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<PendingSubjectEntity> _pendingSubjectStream;
  bool loading = false;

  final TextEditingController _verificationCodeController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FocusNode _verificationCodeFocusNode;
  FocusNode _verifyFocusNode;

  PendingSubjectPageState({
    @required this.appConfiguration,
    @required this.pendingSubject,
  }) : _verificationCodeController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _pendingSubjectStream = PendingSubjectStore(appConfiguration).subscribeForSubject(
      proxyUniverse: pendingSubject.proxyUniverse,
      id: pendingSubject.id,
    );
    _verificationCodeFocusNode = new FocusNode();
    _verifyFocusNode = new FocusNode();
  }

  @override
  void dispose() {
    _verificationCodeFocusNode.dispose();
    _verifyFocusNode.dispose();
    super.dispose();
  }

  List<ActionMenuItem> actions(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return [
      ActionMenuItem(title: localizations.cancelVerificationTooltip, icon: Icons.cancel, action: CANCEL),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(localizations.verifySubjectTitle + appConfiguration.proxyUniverseSuffix),
        actions: <Widget>[
          PopupMenuButton<ActionMenuItem>(
            onSelected: (action) => _performAction(context, action),
            itemBuilder: (BuildContext context) {
              return actions(context).map((ActionMenuItem choice) {
                return PopupMenuItem<ActionMenuItem>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: BusyChildWidget(
        loading: loading,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: streamBuilder(
            initialData: pendingSubject,
            stream: _pendingSubjectStream,
            builder: body,
            emptyWidget: _noDatFound(context),
          ),
        ),
      ),
    );
  }

  Widget body(
    BuildContext context,
    PendingSubjectEntity pendingSubject,
  ) {
    ThemeData themeData = Theme.of(context);
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    List<Widget> rows = [
      const SizedBox(height: 16.0),
      Icon(Icons.fingerprint, size: 64.0),
    ];

    if (pendingSubject.formatterAadhaarNumber != null) {
      rows.addAll([
        const SizedBox(height: 24.0),
        Center(
          child: Text(
            localizations.aadhaarNumber,
          ),
        ),
        const SizedBox(height: 8.0),
        Center(
          child: Text(
            pendingSubject.formatterAadhaarNumber,
            style: themeData.textTheme.title,
          ),
        ),
        const SizedBox(height: 24.0),
        Center(
          child: Text(
            localizations.verificationCode,
          ),
        ),
        const SizedBox(height: 8.0),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 32, right: 32),
            child: TextFormField(
              controller: _verificationCodeController,
              focusNode: _verificationCodeFocusNode,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              keyboardType: TextInputType.visiblePassword,
              textAlign: TextAlign.center,
              style: themeData.textTheme.title,
              validator: (value) => _fieldValidator(localizations, value),
              onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_verifyFocusNode),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
      ]);
    }

    List<Widget> actions = [];
    if (pendingSubject.active && !pendingSubject.verified) {
      actions.add(
        RaisedButton(
          focusNode: _verifyFocusNode,
          onPressed: () => _verify(context, pendingSubject),
          child: Text(localizations.verifyButtonLabel),
        ),
      );
    }
    if (actions.isNotEmpty) {
      rows.add(const SizedBox(height: 24.0));
      rows.add(
        ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: actions,
        ),
      );
    }
    return Form(
      key: _formKey,
      child: ListView(
        children: rows,
      ),
    );
  }

  Widget _noDatFound(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return ListView(
      children: <Widget>[
        const SizedBox(height: 16.0),
        Icon(Icons.error, size: 64.0),
        const SizedBox(height: 24.0),
        Center(
          child: Text(
            localizations.somethingWentWrong,
          ),
        ),
        const SizedBox(height: 32.0),
        RaisedButton.icon(
          onPressed: _close,
          icon: Icon(Icons.close),
          label: Text(localizations.closeButtonLabel),
        ),
      ],
    );
  }

  void _close() {
    Navigator.of(context).pop();
  }

  void _performAction(BuildContext context, ActionMenuItem action) {
    if (action.action == CANCEL) {
      _cancel(context);
    } else {
      print("Unknown action $action");
    }
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _cancel(BuildContext context) async {
    await PendingSubjectStore(appConfiguration).archivePendingSubject(pendingSubject.copy(active: false));
    Navigator.of(context).pop();
  }

  Future<void> _verify(BuildContext context, PendingSubjectEntity pendingSubject) async {
    if (!_formKey.currentState.validate()) {
      print("Validation failure");
      return;
    }
    if (pendingSubject.verified) {
      showMessage(ProxyLocalizations.of(context).subjectAlreadyVerified);
      return;
    }
    final verifiedSubject = await invoke(
      () => IdentityServiceFactory.identityService(appConfiguration).completeSubjectVerification(
        pendingSubjectEntity: pendingSubject,
        verificationCode: _verificationCodeController.text,
      ),
      name: 'Initiate Subject Verification',
      onError: () => showMessage(ProxyLocalizations.of(context).somethingWentWrong),
    );
    print("Verified $verifiedSubject");
    if (verifiedSubject != null) {
      Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
          builder: (context) => ProxySubjectPage(
            appConfiguration,
            proxySubject: verifiedSubject,
          ),
        ),
      );
    }
  }

  String _fieldValidator(ProxyLocalizations localizations, String value) {
    if (value == null || value.isEmpty) {
      return localizations.fieldIsMandatory(localizations.thisField);
    }
    return null;
  }
}

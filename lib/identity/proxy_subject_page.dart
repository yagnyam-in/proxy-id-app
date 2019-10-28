import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/identity/db/proxy_subject_store.dart';
import 'package:proxy_id/identity/model/proxy_subject_entity.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/model/action_menu_item.dart';
import 'package:proxy_id/widgets/async_helper.dart';
import 'package:proxy_id/widgets/loading.dart';
import 'package:quiver/strings.dart';

class ProxySubjectPage extends StatefulWidget {
  final AppConfiguration appConfiguration;
  final ProxySubjectEntity proxySubject;

  const ProxySubjectPage(
    this.appConfiguration, {
    Key key,
    @required this.proxySubject,
  }) : super(key: key);

  @override
  ProxySubjectPageState createState() {
    return ProxySubjectPageState(
      appConfiguration: appConfiguration,
      proxySubject: proxySubject,
    );
  }
}

class ProxySubjectPageState extends LoadingSupportState<ProxySubjectPage> {
  static const String DELETE = "delete";

  final AppConfiguration appConfiguration;
  final ProxySubjectEntity proxySubject;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<ProxySubjectEntity> _proxySubjectStream;
  bool loading = false;

  ProxySubjectPageState({
    @required this.appConfiguration,
    @required this.proxySubject,
  });

  @override
  void initState() {
    super.initState();
    _proxySubjectStream = ProxySubjectStore(appConfiguration).subscribeForSubject(proxySubject.subjectId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<ActionMenuItem> actions(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return [
      ActionMenuItem(title: localizations.deleteSubjectMenuItem, icon: Icons.delete, action: DELETE),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(localizations.proxySubjectTitle + appConfiguration.proxyUniverseSuffix),
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
            initialData: proxySubject,
            stream: _proxySubjectStream,
            builder: body,
            emptyWidget: _noDatFound(context),
          ),
        ),
      ),
    );
  }

  Widget body(
    BuildContext context,
    ProxySubjectEntity proxySubject,
  ) {
    ThemeData themeData = Theme.of(context);
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    List<Widget> rows = [
      const SizedBox(height: 16.0),
      Icon(Icons.fingerprint, size: 64.0),
    ];

    if (isNotEmpty(proxySubject.formatterAadhaarNumber)) {
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
            proxySubject.formatterAadhaarNumber,
            style: themeData.textTheme.title,
          ),
        ),
        const SizedBox(height: 24.0),
        Center(
          child: Text(
            localizations.subjectName,
          ),
        ),
        const SizedBox(height: 8.0),
        Center(
          child: Text(
            proxySubject.subjectName,
            style: themeData.textTheme.title,
          ),
        ),
        if (proxySubject?.subjectDetails?.dateOfBirth != null) ...[
          const SizedBox(height: 24.0),
          Center(
            child: Text(
              localizations.dateOfBirth,
            ),
          ),
          const SizedBox(height: 8.0),
          Center(
            child: Text(
              DateFormat.yMMMd().format(proxySubject?.subjectDetails?.dateOfBirth),
              style: themeData.textTheme.title,
            ),
          ),
        ],
        const SizedBox(height: 8.0),
      ]);
    }

    List<Widget> actions = [];
    if (actions.isNotEmpty) {
      rows.add(const SizedBox(height: 24.0));
      rows.add(
        ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: actions,
        ),
      );
    }
    return ListView(
      children: rows,
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
    if (action.action == DELETE) {
      _delete(context);
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

  Future<void> _delete(BuildContext context) async {
    await ProxySubjectStore(appConfiguration).archiveSubject(proxySubject);
    Navigator.of(context).pop();
  }
}

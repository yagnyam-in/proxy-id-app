import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/home_page_navigation.dart';
import 'package:proxy_id/identity/db/pending_subject_store.dart';
import 'package:proxy_id/identity/pending_subject_page.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/model/action_menu_item.dart';
import 'package:proxy_id/model/enticement.dart';
import 'package:proxy_id/services/enticement_factory.dart';
import 'package:proxy_id/services/enticement_service.dart';
import 'package:proxy_id/services/service_factory.dart';
import 'package:proxy_id/services/upgrade_helper.dart';
import 'package:proxy_id/widgets/async_helper.dart';
import 'package:proxy_id/widgets/enticement_helper.dart';
import 'package:proxy_id/widgets/loading.dart';
import 'package:uuid/uuid.dart';

import 'db/proxy_subject_store.dart';
import 'model/pending_subject_entity.dart';
import 'model/proxy_subject_entity.dart';
import 'proxy_subject_page.dart';
import 'proxy_subjects_helper.dart';
import 'widgets/pending_subject_card.dart';
import 'widgets/proxy_subject_card.dart';

final Uuid uuidFactory = Uuid();

class ProxySubjectsPage extends StatefulWidget {
  final AppConfiguration appConfiguration;
  final ChangeHomePage changeHomePage;

  ProxySubjectsPage(
    this.appConfiguration, {
    Key key,
    @required this.changeHomePage,
  }) : super(key: key) {
    print("Constructing ProxySubjectsPage");
    assert(appConfiguration != null);
  }

  @override
  _ProxySubjectsPageState createState() {
    return _ProxySubjectsPageState(appConfiguration, changeHomePage);
  }
}

class _ProxySubjectsPageState extends LoadingSupportState<ProxySubjectsPage>
    with ProxyUtils, EnticementHelper, HomePageNavigation, ProxySubjectsHelper, UpgradeHelper {
  static const String VERIFY = "verify";
  final AppConfiguration appConfiguration;
  final ChangeHomePage changeHomePage;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<List<ProxySubjectEntity>> _proxySubjectsStream;
  Stream<List<PendingSubjectEntity>> _pendingSubjectsStream;
  Stream<List<Enticement>> _enticementsStream;
  bool loading = false;
  Timer _newVersionCheckTimer;

  _ProxySubjectsPageState(this.appConfiguration, this.changeHomePage);

  @override
  void initState() {
    super.initState();
    _proxySubjectsStream = ProxySubjectStore(appConfiguration).subscribeForSubjects();
    _pendingSubjectsStream = PendingSubjectStore(appConfiguration).subscribeForPendingSubjects();
    _enticementsStream = EnticementService(appConfiguration).subscribeForFirstEnticement();
    ServiceFactory.bootService().warmUpBackends();
    _newVersionCheckTimer = Timer(const Duration(milliseconds: 5000), () => checkForUpdates(context));
  }

  @override
  void dispose() {
    super.dispose();
    if (_newVersionCheckTimer != null) {
      _newVersionCheckTimer.cancel();
    }
  }

  void showToast(String message) {
    showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  List<ActionMenuItem> _menuActions(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return [
      ActionMenuItem(title: localizations.verifyActionItemTitle, icon: Icons.add, action: VERIFY),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(localizations.proxySubjectsPageTitle + appConfiguration.proxyUniverseSuffix),
        actions: <Widget>[
          PopupMenuButton<ActionMenuItem>(
            onSelected: (action) => _onAction(context, action),
            itemBuilder: (BuildContext context) {
              return _menuActions(context).map((ActionMenuItem choice) {
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
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return streamBuilder(
                  name: "Subjects Loading",
                  stream: _proxySubjectsStream,
                  builder: (context, subjects) => _subjects(context, subjects),
                );
              case 1:
                return streamBuilder(
                  name: "Pending Subjects Loading",
                  stream: _pendingSubjectsStream,
                  loadingWidget: SizedBox.shrink(),
                  builder: (context, enticements) => _pendingSubjects(context, enticements),
                );
              default:
                return streamBuilder(
                  name: "Enticement Loading",
                  stream: _enticementsStream,
                  loadingWidget: SizedBox.shrink(),
                  builder: (context, enticements) => _enticements(context, enticements),
                );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showToast(localizations.notYetImplemented),
        label: Text(localizations.authorizeFabLabel),
      ),
      bottomNavigationBar: navigationBar(
        context,
        HomePage.ProxySubjectsPage,
        busy: loading,
        changeHomePage: changeHomePage,
      ),
    );
  }

  Widget _pendingSubjects(
    BuildContext context,
    List<PendingSubjectEntity> pendingSubjects,
  ) {
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: pendingSubjects.expand((subject) {
        return [
          const SizedBox(height: 4.0),
          _pendingSubjectCard(context, subject),
        ];
      }).toList(),
    );
  }

  Widget _subjects(
    BuildContext context,
    List<ProxySubjectEntity> subjects,
  ) {
    // print("subjects : $subjects");
    if (subjects.isEmpty) {
      return ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          const SizedBox(height: 4.0),
          enticementCard(context, EnticementFactory.noProxySubjects, cancellable: false),
        ],
      );
    }
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: subjects.expand((subject) {
        return [
          const SizedBox(height: 4.0),
          _subjectCard(context, subject),
        ];
      }).toList(),
    );
  }

  Widget _enticements(
    BuildContext context,
    List<Enticement> enticements,
  ) {
    // print("enticements : $enticements");
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: enticements.expand((enticement) {
        return [
          const SizedBox(height: 4.0),
          enticementCard(context, enticement),
        ];
      }).toList(),
    );
  }

  Widget _subjectCard(
    BuildContext context,
    ProxySubjectEntity subject,
  ) {

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: GestureDetector(
        onTap: () => _launchSubject(context, subject),
        child: ProxySubjectCard(subject: subject),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: ProxyLocalizations.of(context).archive,
          color: Colors.red,
          icon: Icons.archive,
          onTap: () => _archiveSubject(context, subject),
        ),
      ],
    );
  }

  Widget _pendingSubjectCard(
    BuildContext context,
    PendingSubjectEntity subject,
  ) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: PendingSubjectCard(
        subject: subject,
        verify: () => _verifyPendingSubject(context, subject),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: ProxyLocalizations.of(context).archive,
          color: Colors.red,
          icon: Icons.archive,
          onTap: () => _archivePendingSubject(context, subject),
        ),
      ],
    );
  }

  Future<void> _verifyPendingSubject(BuildContext context, PendingSubjectEntity pendingSubject) {
    print("Launching $pendingSubject");
    return Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => PendingSubjectPage(
          appConfiguration,
          pendingSubject: pendingSubject,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _onAction(BuildContext context, ActionMenuItem action) {
    if (action.action == VERIFY) {
      addProxySubject(context);
    } else {
      print("Unknown action $action");
    }
  }

  Future<void> _launchSubject(BuildContext context, ProxySubjectEntity subject) {
    return Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => ProxySubjectPage(
          appConfiguration,
          proxySubject: subject,
        ),
      ),
    );
  }

  Future<void> _archiveSubject(BuildContext context, ProxySubjectEntity subject) {
    return ProxySubjectStore(appConfiguration).archiveSubject(subject);
  }

  Future<void> _archivePendingSubject(BuildContext context, PendingSubjectEntity subject) {
    return PendingSubjectStore(appConfiguration).archivePendingSubject(subject);
  }


  @override
  void showSnackBar(SnackBar snackbar) {
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }
}

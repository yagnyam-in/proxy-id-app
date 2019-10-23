import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/home_page_navigation.dart';
import 'package:proxy_id/localizations.dart';
import 'package:proxy_id/services/enticement_factory.dart';
import 'package:proxy_id/widgets/async_helper.dart';
import 'package:proxy_id/widgets/enticement_helper.dart';
import 'package:uuid/uuid.dart';

import 'db/event_store.dart';
import 'events_helper.dart';
import 'model/event_entity.dart';
import 'app_authorizations_helper.dart';
import 'widgets/event_card.dart';

final Uuid uuidFactory = Uuid();

class EventsPage extends StatefulWidget {
  final AppConfiguration appConfiguration;
  final ChangeHomePage changeHomePage;

  EventsPage(this.appConfiguration, {Key key, @required this.changeHomePage}) : super(key: key) {
    assert(appConfiguration != null);
    print("Constructing EventsPage");
  }

  @override
  _EventsPageState createState() {
    return _EventsPageState(appConfiguration, changeHomePage);
  }
}

class _EventsPageState extends LoadingSupportState<EventsPage>
    with HomePageNavigation, EnticementHelper, AppAuthorizationsHelper, EventsHelper {
  final AppConfiguration appConfiguration;
  final ChangeHomePage changeHomePage;
  bool loading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final EventStore _eventStore;
  Stream<List<EventEntity>> _eventStream;

  _EventsPageState(this.appConfiguration, this.changeHomePage) : _eventStore = EventStore(appConfiguration);

  @override
  void initState() {
    super.initState();
    _eventStream = _eventStore.subscribeForEvents();
  }

  void showToast(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: new Text(localizations.eventsPageTitle + appConfiguration.proxyUniverseSuffix),
      ),
      body: streamBuilder(
        name: "Account Loading",
        stream: _eventStream,
        builder: (context, events) => _events(context, events),
      ),
      bottomNavigationBar: navigationBar(
        context,
        HomePage.EventsPage,
        changeHomePage: changeHomePage,
        busy: loading,
      ),
    );
  }

  Widget _events(BuildContext context, List<EventEntity> events) {
    // print("events : $events");
    if (events.isEmpty) {
      return ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          const SizedBox(height: 4.0),
          enticementCard(context, EnticementFactory.noEvents, cancellable: false),
        ],
      );
    }
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: events.expand((account) {
        return [
          const SizedBox(height: 4.0),
          _eventCard(context, account),
        ];
      }).toList(),
    );
  }

  Widget _eventCard(BuildContext context, EventEntity event) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: GestureDetector(
        child: EventCard(event: event),
        onTap: () => launchEvent(context, event),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: localizations.refreshButtonHint,
          color: Colors.orange,
          icon: Icons.refresh,
          onTap: () => invoke(() => _refreshEvent(context, event), name: "Refresh Event"),
        ),
        new IconSlideAction(
          caption: localizations.archive,
          color: Colors.red,
          icon: Icons.archive,
          onTap: () => _archiveEvent(context, event),
        ),
      ],
    );
  }

  void _archiveEvent(BuildContext context, EventEntity event) async {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);
    if (!event.completed) {
      showToast(localizations.withdrawalNotYetComplete);
    }
    await _eventStore.deleteEvent(event);
  }

  Future<void> _refreshEvent(BuildContext context, EventEntity event) async {
    switch (event.eventType) {
      case EventType.Deposit:
        break;
      default:
        print("Not yet handled");
    }
  }
}

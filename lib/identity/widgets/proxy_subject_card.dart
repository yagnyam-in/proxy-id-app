import 'package:flutter/material.dart';
import 'package:proxy_id/identity/model/proxy_subject_entity.dart';

class ProxySubjectCard extends StatelessWidget {
  final ProxySubjectEntity subject;

  const ProxySubjectCard({Key key, this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(subject);
    return makeCard(context);
  }

  Widget makeCard(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: new EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Container(
        decoration: BoxDecoration(),
        child: makeListTile(context),
      ),
    );
  }

  String get name => subject.validName;

  String get issuerName => subject.validIssuerName;

  Widget makeListTile(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text(
        name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          issuerName,
        ),
      ),
    );
  }
}

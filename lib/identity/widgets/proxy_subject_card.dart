import 'package:flutter/material.dart';
import 'package:proxy_id/identity/model/proxy_subject_entity.dart';
import 'package:quiver/strings.dart';

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

  String getTitle(BuildContext context) {
    if (isNotEmpty(subject.subjectName)) {
      return subject.subjectName;
    }
    if (isNotEmpty(subject.issuerName)) {
      return subject.issuerName;
    }
    if (isNotEmpty(subject?.subjectDetails?.name)) {
      return subject.subjectDetails.name;
    }
    return subject.subjectId.subjectId;
  }

  String getSubTitle(BuildContext context) {
    return subject.formatterAadhaarNumber ?? subject.subjectId.subjectId;
  }

  Widget makeListTile(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text(
        getTitle(context),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          getSubTitle(context),
        ),
      ),
    );
  }
}

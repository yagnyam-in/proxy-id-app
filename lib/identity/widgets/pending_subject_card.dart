import 'package:flutter/material.dart';
import 'package:proxy_id/identity/model/pending_subject_entity.dart';
import 'package:proxy_id/localizations.dart';

class PendingSubjectCard extends StatelessWidget {
  final PendingSubjectEntity subject;
  final VoidCallback verify;

  const PendingSubjectCard({
    Key key,
    @required this.subject,
    @required this.verify,
  }) : super(key: key);

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

  String getTitle(ProxyLocalizations localizations) {
    if (subject.signedAadhaarVerificationChallenge != null) {
      return localizations.aadhaarNumber;
    }
    print("Not handled Title for $subject");
    return localizations.unknownIdentity;
  }

  String getSubTitle(ProxyLocalizations localizations) {
    if (subject.formatterAadhaarNumber != null) {
      return subject.formatterAadhaarNumber;
    }
    print("Not handled Sub Title for $subject");
    return "Pending Verification";
  }

  Widget makeListTile(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
      title: Text(
        getTitle(localizations),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(getSubTitle(localizations)),
            ButtonBar(
              children: <Widget>[
                RaisedButton(
                  child: Text(localizations.verifyButtonLabel),
                  onPressed: verify,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

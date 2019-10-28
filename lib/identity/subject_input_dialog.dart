import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proxy_core/core.dart';
import 'package:proxy_id/config/app_configuration.dart';
import 'package:proxy_id/localizations.dart';
import 'package:quiver/strings.dart';

typedef SetupMasterProxyCallback = void Function(ProxyId proxyId);

class SubjectInput extends ProxyBaseObject with ProxyUtils {
  final String aadhaarNumber;

  SubjectInput({@required this.aadhaarNumber}) {
    assertValid();
  }

  @override
  void assertValid() {
    assertNotEmpty(aadhaarNumber);
  }

  @override
  bool isValid() {
    return isNotEmpty(aadhaarNumber);
  }
}

class SubjectInputDialog extends StatefulWidget {
  final AppConfiguration appConfiguration;
  final SubjectInput subjectInput;

  SubjectInputDialog(this.appConfiguration, {Key key, this.subjectInput}) : super(key: key) {
    print("Constructing SubjectInputDialog with Input $subjectInput");
  }

  @override
  _SubjectInputDialogState createState() => _SubjectInputDialogState(
        appConfiguration,
        subjectInput,
      );
}

class _SubjectInputDialogState extends State<SubjectInputDialog> {
  final AppConfiguration appConfiguration;
  final SubjectInput subjectInput;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController aadhaarNumberController;

  FocusNode _aadhaarNumberFocusNode;
  FocusNode _submitFocusNode;

  _SubjectInputDialogState(this.appConfiguration, this.subjectInput)
      : aadhaarNumberController = TextEditingController(text: subjectInput?.aadhaarNumber);

  void showError(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  void initState() {
    super.initState();
    _aadhaarNumberFocusNode = new FocusNode();
    _submitFocusNode = new FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _aadhaarNumberFocusNode.dispose();
    _submitFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(localizations.subjectInputTitle),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: form(context),
      ),
    );
  }

  Widget form(BuildContext context) {
    ProxyLocalizations localizations = ProxyLocalizations.of(context);

    List<Widget> children = [];

    children.addAll([
      const SizedBox(height: 16.0),
      TextFormField(
        controller: aadhaarNumberController,
        focusNode: _aadhaarNumberFocusNode,
        decoration: InputDecoration(
          labelText: localizations.aadhaarNumber,
        ),
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        validator: (value) => _fieldValidator(localizations, value),
        onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(_submitFocusNode),
      ),
    ]);

    children.addAll([
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        alignment: Alignment.center,
        child: RaisedButton(
          focusNode: _submitFocusNode,
          onPressed: () => _submit(localizations),
          child: Text(localizations.verifyButtonLabel),
        ),
      ),
    ]);

    return Form(
      key: _formKey,
      child: ListView(
        children: children,
      ),
    );
  }

  void _submit(ProxyLocalizations localizations) {
    if (_formKey.currentState.validate()) {
      SubjectInput result = SubjectInput(
        aadhaarNumber: aadhaarNumberController.text,
      );
      print("Accepting $result");
      Navigator.of(context).pop(result);
    } else {
      print("Validation failure");
    }
  }

  String _fieldValidator(ProxyLocalizations localizations, String value) {
    if (value == null || value.isEmpty) {
      return localizations.fieldIsMandatory(localizations.thisField);
    }
    return null;
  }
}

import '../stylings/stylings_util.dart';
import '/index.dart';
import 'help_widget.dart' show HelpWidget;
import 'package:flutter/material.dart';

class HelpModel extends FlutterFlowModel<HelpWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for qs widget.
  FocusNode? qsFocusNode;
  TextEditingController? qsTextController;
  String? Function(BuildContext, String?)? qsTextControllerValidator;
  // Stores action output result for [Gemini - Generate Text] action in Button widget.
  String? geminiOutput;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    qsFocusNode?.dispose();
    qsTextController?.dispose();
  }
}

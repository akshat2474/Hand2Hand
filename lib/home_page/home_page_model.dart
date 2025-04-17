import '/components/hand1_widget.dart';
import '/components/hand2_widget.dart';
import '../stylings/stylings_util.dart';
import '/index.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';


class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for hand1 component.
  late Hand1Model hand1Model;
  // Model for hand2 component.
  late Hand2Model hand2Model;

  @override
  void initState(BuildContext context) {
    hand1Model = createModel(context, () => Hand1Model());
    hand2Model = createModel(context, () => Hand2Model());
  }

  @override
  void dispose() {
    hand1Model.dispose();
    hand2Model.dispose();
  }
}

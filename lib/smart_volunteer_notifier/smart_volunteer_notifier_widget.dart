import '../stylings/stylings_theme.dart';
import '../stylings/stylings_util.dart';
import '../main_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'smart_volunteer_notifier_model.dart';
export 'smart_volunteer_notifier_model.dart';

class SmartVolunteerNotifierWidget extends StatefulWidget {
  const SmartVolunteerNotifierWidget({super.key});

  static String routeName = 'SmartVolunteerNotifier';
  static String routePath = '/smartVolunteerNotifier';

  @override
  State<SmartVolunteerNotifierWidget> createState() =>
      _SmartVolunteerNotifierWidgetState();
}

class _SmartVolunteerNotifierWidgetState
    extends State<SmartVolunteerNotifierWidget> {
  late SmartVolunteerNotifierModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SmartVolunteerNotifierModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
            ),
            child: const SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.SmartVolunteerNotifier(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

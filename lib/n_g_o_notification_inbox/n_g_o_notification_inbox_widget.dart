import '../stylings/stylings_theme.dart';
import '../stylings/stylings_util.dart';
import '../main_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'n_g_o_notification_inbox_model.dart';
export 'n_g_o_notification_inbox_model.dart';

class NGONotificationInboxWidget extends StatefulWidget {
  const NGONotificationInboxWidget({super.key});

  static String routeName = 'NGONotificationInbox';
  static String routePath = '/nGONotificationInbox';

  @override
  State<NGONotificationInboxWidget> createState() =>
      _NGONotificationInboxWidgetState();
}

class _NGONotificationInboxWidgetState
    extends State<NGONotificationInboxWidget> {
  late NGONotificationInboxModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NGONotificationInboxModel());
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
              child:  custom_widgets.NGONotificationInbox(
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

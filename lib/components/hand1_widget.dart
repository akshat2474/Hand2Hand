import '../stylings/stylings_theme.dart';
import '../stylings/stylings_util.dart';
import 'package:flutter/material.dart';
import 'hand1_model.dart';
export 'hand1_model.dart';

class Hand1Widget extends StatefulWidget {
  const Hand1Widget({super.key});

  @override
  State<Hand1Widget> createState() => _Hand1WidgetState();
}

class _Hand1WidgetState extends State<Hand1Widget> {
  late Hand1Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Hand1Model());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hand2',
      style: FlutterFlowTheme.of(context).bodyLarge.override(
            fontFamily: 'EB Garamond',
            color: const Color(0xFF0097B2),
            fontSize: 50.0,
            letterSpacing: 0.0,
          ),
    );
  }
}

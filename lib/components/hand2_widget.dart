import '../stylings/stylings_theme.dart';
import '../stylings/stylings_util.dart';
import 'package:flutter/material.dart';
import 'hand2_model.dart';
export 'hand2_model.dart';

class Hand2Widget extends StatefulWidget {
  const Hand2Widget({super.key});

  @override
  State<Hand2Widget> createState() => _Hand2WidgetState();
}

class _Hand2WidgetState extends State<Hand2Widget> {
  late Hand2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Hand2Model());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hand',
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'EB Garamond',
            color: const Color(0xFF0097B2),
            fontSize: 50.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

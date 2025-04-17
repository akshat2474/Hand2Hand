import '../stylings/stylings_util.dart';
import '../stylings/form_field_controller.dart';
import '/index.dart';
import 'n_g_o_profile_widget.dart' show NGOProfileWidget;
import 'package:flutter/material.dart';


class NGOProfileModel extends FlutterFlowModel<NGOProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for yourName widget.
  FocusNode? yourNameFocusNode;
  TextEditingController? yourNameTextController;
  String? Function(BuildContext, String?)? yourNameTextControllerValidator;
  // State field(s) for phone widget.
  FocusNode? phoneFocusNode;
  TextEditingController? phoneTextController;
  String? Function(BuildContext, String?)? phoneTextControllerValidator;
  // State field(s) for officeAddress widget.
  FocusNode? officeAddressFocusNode;
  TextEditingController? officeAddressTextController;
  String? Function(BuildContext, String?)? officeAddressTextControllerValidator;
  // State field(s) for yearfounded widget.
  FocusNode? yearfoundedFocusNode;
  TextEditingController? yearfoundedTextController;
  String? Function(BuildContext, String?)? yearfoundedTextControllerValidator;
  // State field(s) for registration widget.
  FocusNode? registrationFocusNode;
  TextEditingController? registrationTextController;
  String? Function(BuildContext, String?)? registrationTextControllerValidator;
  // State field(s) for volunteers widget.
  FocusNode? volunteersFocusNode;
  TextEditingController? volunteersTextController;
  String? Function(BuildContext, String?)? volunteersTextControllerValidator;
  // State field(s) for city widget.
  String? cityValue;
  FormFieldController<String>? cityValueController;
  // State field(s) for myBio widget.
  FocusNode? myBioFocusNode;
  TextEditingController? myBioTextController;
  String? Function(BuildContext, String?)? myBioTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    yourNameFocusNode?.dispose();
    yourNameTextController?.dispose();

    phoneFocusNode?.dispose();
    phoneTextController?.dispose();

    officeAddressFocusNode?.dispose();
    officeAddressTextController?.dispose();

    yearfoundedFocusNode?.dispose();
    yearfoundedTextController?.dispose();

    registrationFocusNode?.dispose();
    registrationTextController?.dispose();

    volunteersFocusNode?.dispose();
    volunteersTextController?.dispose();

    myBioFocusNode?.dispose();
    myBioTextController?.dispose();
  }
}

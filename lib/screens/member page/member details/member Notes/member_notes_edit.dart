import 'package:flutter/material.dart';

class EditMemberNote extends StatefulWidget {
  final List<dynamic> memberNotesDetails;

  const EditMemberNote({Key? key, required this.memberNotesDetails}) : super(key: key);


  @override
  State<EditMemberNote> createState() => _EditMemberNoteState();
}

class _EditMemberNoteState extends State<EditMemberNote> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

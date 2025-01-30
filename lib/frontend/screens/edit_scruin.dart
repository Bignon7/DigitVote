import 'package:flutter/material.dart';

class EditScrutinForm extends StatefulWidget {
  final String scrutinId;
  const EditScrutinForm({required this.scrutinId, super.key});

  @override
  State<EditScrutinForm> createState() => _EditScrutinFormState();
}

class _EditScrutinFormState extends State<EditScrutinForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
              'Formulaire de modification du scrutin ${widget.scrutinId} ')),
    );
  }
}

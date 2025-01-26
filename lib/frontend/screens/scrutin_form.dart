import 'package:flutter/material.dart';

import '../../backend/services/scrutin_service.dart';
import '../../backend/models/scrutin.dart';
import 'candidat_form.dart';

class CreateScrutinForm extends StatefulWidget {
  @override
  _CreateScrutinFormState createState() => _CreateScrutinFormState();
}

class _CreateScrutinFormState extends State<CreateScrutinForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _createurIdController = TextEditingController();
  bool _isSecureVote =
      false; // Ajouter un booléen pour savoir si la case est cochée

  final ScrutinService _scrutinService = ScrutinService();

  // Fonction de validation
  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  void _submitScrutinForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text;
      final description = _descriptionController.text;
      final startDate = DateTime.parse(_startDateController.text);
      final endDate = DateTime.parse(_endDateController.text);
      final createurId = _createurIdController.text;

      // Créer un scrutin
      final scrutin = Scrutin(
        id: '',
        titre: title,
        description: description,
        dateOuverture: startDate,
        dateCloture: endDate,
        createurId: createurId,
        code: '',
        voteMultiple: false,
        candidatsIds: [],
      );

      // Si la case "Sécuriser le vote" est cochée, générer un code
      if (_isSecureVote) {
        scrutin.generateCode();
      }

      try {
        final scrutinId = await _scrutinService.createScrutin(scrutin);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scrutin créé avec succès !')),
        );

        // Aller vers la page d'ajout de candidats pour ce scrutin
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateCandidatForm(scrutinId: scrutinId)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un Scrutin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre du Scrutin'),
                validator: _validateField,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: _validateField,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _startDateController,
                decoration:
                    InputDecoration(labelText: 'Date de début (YYYY-MM-DD)'),
                validator: _validateField,
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _endDateController,
                decoration:
                    InputDecoration(labelText: 'Date de fin (YYYY-MM-DD)'),
                validator: _validateField,
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _createurIdController,
                decoration: InputDecoration(labelText: 'ID du créateur'),
                validator: _validateField,
              ),
              SizedBox(height: 10),
              // Ajouter la case à cocher "Sécuriser le vote"
              CheckboxListTile(
                title: Text("Sécuriser le vote"),
                value: _isSecureVote,
                onChanged: (bool? value) {
                  setState(() {
                    _isSecureVote = value ?? false;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitScrutinForm,
                child: Text('Créer le Scrutin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

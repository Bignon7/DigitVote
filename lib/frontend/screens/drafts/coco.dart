import 'package:flutter/material.dart';
import '../../../backend/services/candidat_service.dart';
import '../../../backend/services/scrutin_service.dart';
import '../../../backend/models/candidat.dart';

class CreateCandidatForm extends StatefulWidget {
  final String scrutinId;
  CreateCandidatForm({required this.scrutinId});

  @override
  _CreateCandidatFormState createState() => _CreateCandidatFormState();
}

class _CreateCandidatFormState extends State<CreateCandidatForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _biographieController = TextEditingController();
  final _posteController = TextEditingController();
  final _imageController = TextEditingController();
  final CandidatService _candidatService = CandidatService();
  final ScrutinService _scrutinService = ScrutinService();

  // Validation pour les champs
  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  void _submitCandidatForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final nom = _nomController.text;
      final biographie = _biographieController.text;
      final image = _imageController.text;

      final candidat = Candidat(
        id: '',
        scrutinId: widget.scrutinId,
        nom: nom,
        biographie: biographie,
        image: image,
        nombreVotes: 0,
      );

      try {
        final candidatId = await _candidatService.createCandidat(candidat);
        await _scrutinService.addCandidatToScrutin(widget.scrutinId, candidat);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Candidat ajouté avec succès !')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du candidat : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter un Candidat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom du Candidat'),
                validator: _validateField,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _biographieController,
                decoration: InputDecoration(labelText: 'Biographie'),
                validator: _validateField,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _posteController,
                decoration: InputDecoration(labelText: 'Poste'),
                validator: _validateField,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: _validateField,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitCandidatForm,
                child: Text('Ajouter le Candidat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

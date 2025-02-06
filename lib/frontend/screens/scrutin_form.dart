import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/colors.dart';
import 'package:digit_vote/backend/providers/user_provider.dart';
import '../../backend/services/scrutin_service.dart';
import '../../backend/models/scrutin.dart';
import 'package:provider/provider.dart';
import '../utils/custom_loader.dart';
import 'success_scrutin.dart';
import 'dart:io';
import '../../backend/services/supabase_service.dart';

class ScrutinForm extends StatefulWidget {
  @override
  _ScrutinFormState createState() => _ScrutinFormState();
}

class _ScrutinFormState extends State<ScrutinForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _dateOuvertureController = TextEditingController();
  final _dateClotureController = TextEditingController();
  final _imageController =
      TextEditingController(text: "Aucune imge sélectionnée");
  final _descriptionController = TextEditingController();
  bool _isSecure = false;
  bool _isLoading = false;
  bool _voteMultiple = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageController.text = pickedFile.name;
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void _submitScrutinForm(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      //partieimage
      setState(() {
        _isLoading = true;
      });
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await SupabaseService().uploadImageForScrutin(
          file: _selectedImage!,
          bucketName: 'votify_files',
          context: context,
        );
      }
      // print('Image téléchargée avec succès : $imageUrl');
      final titre = _nomController.text.trim();
      final description = _descriptionController.text.trim();
      final dateOuverture = DateTime.parse(_dateOuvertureController.text);
      final dateCloture = DateTime.parse(_dateClotureController.text);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userData = userProvider.userData;

      final scrutin = Scrutin(
        id: '',
        titre: titre,
        description: description,
        dateOuverture: dateOuverture,
        dateCloture: dateCloture,
        createurId: userData?['id'],
        code: '',
        voteMultiple: _voteMultiple,
        candidatsIds: [],
        imageScrutin: imageUrl,
      );
      if (_isSecure) {
        scrutin.generateCode();
      }

      try {
        final ScrutinService _scrutinService = ScrutinService();
        await _scrutinService.createScrutin(scrutin);
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessScreen()),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erreur',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;

    if (userData == null) {
      return Scaffold(
        body: CustomLoader(),
      );
    }

    final username = userData['nom'] ?? 'Utilisateur';
    final imageUrl = userData['image_url'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bonjour,",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            Text(
              username,
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: (imageUrl.isEmpty ||
                      !Uri.tryParse(imageUrl)!.isAbsolute)
                  ? AssetImage('assets/images/default2.png') as ImageProvider
                  : NetworkImage(imageUrl),
              radius: 20,
            ),
          ),
        ],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Créer un nouveau scrutin",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  "Nom du Scrutin",
                  _nomController,
                  Icons.check_circle,
                  true,
                ),
                _buildDateField("Date d’ouverture", _dateOuvertureController),
                _buildDateField("Date de clôture", _dateClotureController),
                // Section Photo avec image picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _imageController.text.split('/').last,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const Icon(Icons.folder_outlined,
                                color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

                _buildDescriptionField(),
                SizedBox(height: 20),
                _buildVoteMultipleSwitch(),
                SizedBox(height: 10),
                _buildSwitchField(),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _submitScrutinForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Créer",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
          ),
          onTap: () => _selectDate(context, controller),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez choisir une date';
            }

            final parsedDate = DateTime.tryParse(value);
            if (parsedDate == null) {
              return 'Format de date invalide. Utilisez YYYY-MM-DD.';
            }

            if (label == "Date de clôture" &&
                _dateOuvertureController.text.isNotEmpty) {
              final dateOuverture =
                  DateTime.tryParse(_dateOuvertureController.text);
              if (dateOuverture != null && parsedDate.isBefore(dateOuverture)) {
                return 'La date de clôture doit être après la date d’ouverture';
              }
            }

            return null;
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez fournir une description';
            }
            if (value.length < 10) {
              return 'La description doit contenir au moins 10 caractères';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSwitchField() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Sécuriser votre scrutin",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Switch(
              value: _isSecure,
              onChanged: (value) {
                setState(() {
                  _isSecure = value;
                });
              },
              activeColor: const Color(0xFF2FB364),
            ),
          ],
        ),
        if (_isSecure)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Un code vous sera envoyé dans votre mail pour sécuriser votre vote',
              style: TextStyle(color: Color(0xFF2FB364), fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      [bool isValid = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon:
                Icon(icon, color: isValid ? AppColors.primary : Colors.grey),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez remplir ce champ';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVoteMultipleSwitch() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Autoriser le vote multiple",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Switch(
              value: _voteMultiple,
              onChanged: (bool value) {
                setState(() {
                  _voteMultiple = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (_voteMultiple)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "Les électeurs pourront voter plusieurs fois pour votre scrutin.",
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

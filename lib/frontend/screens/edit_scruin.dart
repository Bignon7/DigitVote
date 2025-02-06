import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../../backend/services/email_service.dart';
import '../../backend/services/scrutin_service.dart';
import '../../backend/models/scrutin.dart';
import '../../backend/services/supabase_service.dart';
import '../utils/colors.dart';
import '../utils/custom_loader.dart';
import 'package:provider/provider.dart';
import '../../backend/providers/user_provider.dart';
import 'main_page.dart';

class UpdateScrutinScreen extends StatefulWidget {
  final String scrutinId;

  const UpdateScrutinScreen({Key? key, required this.scrutinId})
      : super(key: key);

  @override
  _UpdateScrutinScreenState createState() => _UpdateScrutinScreenState();
}

class _UpdateScrutinScreenState extends State<UpdateScrutinScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrutinService _scrutinService = ScrutinService();
  final EmailService _emailService = EmailService();
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _imagePicker = ImagePicker();

  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateOuvertureController = TextEditingController();
  final _dateClotureController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdating = false;
  bool _voteMultiple = false;
  bool _isSecure = false;
  File? _selectedImage;
  String _currentImageUrl = '';
  late bool _isSecureSwitchShowed;

  @override
  void initState() {
    super.initState();
    _loadScrutinData();
  }

  Future<void> _loadScrutinData() async {
    try {
      Scrutin scrutin = await _scrutinService.getScrutinById(widget.scrutinId);
      setState(() {
        _titreController.text = scrutin.titre;
        _descriptionController.text = scrutin.description;
        _dateOuvertureController.text =
            scrutin.dateOuverture.toString().split(' ')[0];
        _dateClotureController.text =
            scrutin.dateCloture.toString().split(' ')[0];
        _voteMultiple = scrutin.voteMultiple;
        _isSecure = scrutin.code.isNotEmpty;
        _currentImageUrl = scrutin.imageScrutin ?? '';
        _isLoading = false;
        _isSecureSwitchShowed = scrutin.code.isEmpty;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(context, e.toString());
    }
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, bool isClosingDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog(context, "Erreur lors de la sélection de l'image: $e");
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _currentImageUrl;

    final imageUrl = await _supabaseService.uploadImageForScrutin(
      file: _selectedImage!,
      bucketName: 'votify_files',
      context: context,
    );

    return imageUrl;
  }

  Future<void> _updateScrutin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUpdating = true);

      try {
        String? newImageUrl = _currentImageUrl;

        if (_selectedImage != null) {
          newImageUrl = await _uploadImage();
          if (newImageUrl == null) {
            throw Exception("Échec du téléchargement de l'image");
          }
        }
        //à revoir
        final scrutinData =
            await _scrutinService.getScrutinById(widget.scrutinId);
        String? currentCode = scrutinData.code;
        String? newCode = currentCode;

        if (currentCode.isEmpty) {
          if (_isSecure) {
            newCode = _scrutinService.getGeneratedCode();
            try {
              await EmailService.sendEmailWithCodeForCurrentUser(
                  newCode, _titreController.text.trim());
            } catch (e) {
              _showErrorDialog(context,
                  "L'email contenant votre code n'a pas pu être envoyé : $e");
            }
          } else {
            newCode = '';
          }
        } else {
          newCode = currentCode;
        }
        //à revoir

        await _scrutinService.updateScrutin(
          widget.scrutinId,
          {
            'titre': _titreController.text,
            'description': _descriptionController.text,
            'date_ouverture': _dateOuvertureController.text,
            'date_cloture': _dateClotureController.text,
            'vote_multiple': _voteMultiple,
            'image_scrutin': newImageUrl,
            'code': newCode,
          },
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessPage()),
        );
      } catch (e) {
        _showErrorDialog(context, "Erreur lors de la mise à jour : $e");
      } finally {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erreur',
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;

    if (_isLoading || userData == null) {
      return Scaffold(body: CustomLoader());
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
                    "Modifier le scrutin",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              height: 200,
                              width: 300,
                              fit: BoxFit.cover,
                            )
                          : (_currentImageUrl.isNotEmpty
                              ? Image.network(
                                  _currentImageUrl,
                                  height: 200,
                                  width: 300,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const SizedBox(
                                      height: 200,
                                      width: 300,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox.shrink();
                                  },
                                )
                              : const SizedBox.shrink()),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  "Nom du Scrutin",
                  _titreController,
                  Icons.check_circle,
                  true,
                ),
                _buildDateField(
                    "Date d'ouverture", _dateOuvertureController, false),
                SizedBox(height: 20),
                _buildDateField(
                    "Date de clôture", _dateClotureController, true),
                SizedBox(height: 20),
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
                          _selectedImage != null
                              ? _selectedImage!.path.split('/').last
                              : 'Sélectionner une image',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.photo_library,
                            color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                _buildDescriptionField(),
                SizedBox(height: 20),
                _buildVoteMultipleSwitch(),
                SizedBox(height: 20),
                _buildSecureSwitch(),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updateScrutin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    ),
                    child: _isUpdating
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Mettre à jour",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildDateField(
      String label, TextEditingController controller, bool isClosingDate) {
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
          onTap: () => _selectDate(context, controller, isClosingDate),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez choisir une date';
            }
            final parsedDate = DateTime.tryParse(value);
            if (parsedDate == null) {
              return 'Format de date invalide. Utilisez YYYY-MM-DD.';
            }

            if (isClosingDate) {
              final dateOuverture =
                  DateTime.tryParse(_dateOuvertureController.text);
              if (dateOuverture != null && parsedDate.isBefore(dateOuverture)) {
                return 'La date de clôture doit être après la date d\'ouverture';
              }
            }
            DateTime today = DateTime.now();
            DateTime todayOnly = DateTime(today.year, today.month, today.day);
            DateTime selectedDateOnly =
                DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
            if (selectedDateOnly.isBefore(todayOnly)) {
              return 'La date doit être future';
            }
            return null;
          },
        ),
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

  Widget _buildSecureSwitch() {
    if (!_isSecureSwitchShowed) return SizedBox();
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
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (_isSecure)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Un code vous sera envoyé dans votre mail pour sécuriser votre vote',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/Animation1.json',
                      height: 350,
                      repeat: true,
                    ),
                    //SizedBox(height: 20),
                    Text(
                      "Bingo !",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Scrutin mis à jour avec succès.",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  "Retourner à l'accueil",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

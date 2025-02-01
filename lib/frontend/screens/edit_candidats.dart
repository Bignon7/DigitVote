import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/custom_loader.dart';
import '../../backend/services/candidat_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../backend/services/supabase_service.dart';
import 'dart:io';

class EditCandidatPage extends StatefulWidget {
  final String candidatId;

  const EditCandidatPage({Key? key, required this.candidatId})
      : super(key: key);

  @override
  _EditCandidatPageState createState() => _EditCandidatPageState();
}

class _EditCandidatPageState extends State<EditCandidatPage> {
  final CandidatService _candidatService = CandidatService();
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = true;
  bool _isSaving = false;
  File? _selectedImage;

  late TextEditingController _nomController;
  late TextEditingController _biographieController;
  late TextEditingController _imageController;
  late String _currentImageUrl;

  String? _nomError;
  String? _biographieError;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _biographieController = TextEditingController();
    _imageController = TextEditingController();
    _loadCandidatData();
  }

  Future<void> _loadCandidatData() async {
    try {
      final candidat =
          await _candidatService.getCandidatById(widget.candidatId);
      setState(() {
        _nomController.text = candidat.nom;
        _biographieController.text = candidat.biographie;
        _imageController.text = candidat.image;
        _currentImageUrl = candidat.image;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
      Navigator.pop(context);
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
          _imageController.text = image.path.split('/').last;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _currentImageUrl;

    final imageUrl = await _supabaseService.uploadImageForCandidat(
      file: _selectedImage!,
      bucketName: 'votify_files',
      context: context,
    );

    return imageUrl;
  }

  Future<void> _saveChanges() async {
    setState(() {
      _nomError = _nomController.text.isEmpty ? 'Le nom est requis' : null;
      _biographieError = _biographieController.text.isEmpty
          ? 'La biographie est requise'
          : null;
    });

    if (_nomError != null || _biographieError != null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl = _currentImageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) {
          throw Exception("Échec du téléchargement de l'image");
        }
      }
      await _candidatService.updateCandidat(
        widget.candidatId,
        {
          'nom': _nomController.text,
          'biographie': _biographieController.text,
          'image': imageUrl,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Modifications enregistrées avec succès')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _biographieController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier le candidat',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CustomLoader())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : (_currentImageUrl.isNotEmpty
                                          ? NetworkImage(_currentImageUrl)
                                          : const AssetImage(
                                              'assets/images/default2.png'))
                                      as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nom et Prénom',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(15),
                        ),
                      ),
                    ),
                    if (_nomError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _nomError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    const Text(
                      'Biographie',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _biographieController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(15),
                        ),
                      ),
                    ),
                    if (_biographieError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _biographieError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2FB364),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _isSaving ? null : _saveChanges,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2FB364),
                            ),
                            child: _isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Icon(
                                    Icons.save,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

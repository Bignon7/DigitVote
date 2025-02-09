import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../../backend/services/candidat_service.dart';
import '../../backend/services/scrutin_service.dart';
import '../../backend/models/candidat.dart';
import '../../backend/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../backend/services/supabase_service.dart';
import 'success_candidat.dart';
import '../utils/custom_loader.dart';
import 'dart:io';

class CandidatFormSequence extends StatefulWidget {
  final String scrutinId;
  final int nombreTotal;

  const CandidatFormSequence({
    Key? key,
    required this.scrutinId,
    required this.nombreTotal,
  }) : super(key: key);

  @override
  _CandidatFormSequenceState createState() => _CandidatFormSequenceState();
}

class _CandidatFormSequenceState extends State<CandidatFormSequence> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentIndex > 0) {
          setState(() {
            currentIndex--;
          });
          return false;
        }
        return true;
      },
      child: CandidatPage(
        scrutinId: widget.scrutinId,
        candidatNumber: currentIndex + 1,
        totalCandidats: widget.nombreTotal,
        onSave: (success) {
          if (success) {
            if (currentIndex < widget.nombreTotal - 1) {
              setState(() {
                currentIndex++;
              });
            } else {
              //Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SuccessCandidat()),
              );
            }
          }
        },
      ),
    );
  }
}

class CandidatPage extends StatefulWidget {
  final String scrutinId;
  final int candidatNumber;
  final int totalCandidats;
  final Function(bool) onSave;

  const CandidatPage({
    Key? key,
    required this.scrutinId,
    required this.candidatNumber,
    required this.totalCandidats,
    required this.onSave,
  }) : super(key: key);

  @override
  _CandidatPageState createState() => _CandidatPageState();
}

class _CandidatPageState extends State<CandidatPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _imageController =
      TextEditingController(text: "Aucune image sélectionnée");
  final ScrutinService _scrutinService =
      ScrutinService(candidatService: CandidatService());
  bool _isLoading = false;
  String imagePath = 'assets/images/default2.png';
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  String? _nomError;
  String? _descriptionError;

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

  void validateFields() {
    setState(() {
      _nomError = _nomController.text.isEmpty
          ? 'Veuillez entrer le nom du candidat'
          : null;
      _descriptionError = _descriptionController.text.isEmpty
          ? 'Veuillez entrer la biographie du candidat'
          : null;
    });
  }

  bool isFormValid() {
    validateFields();
    return _nomError == null && _descriptionError == null;
  }

  Future<void> saveCandidat() async {
    if (!isFormValid()) return;

    setState(() => _isLoading = true);
    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await SupabaseService().uploadImageForCandidat(
        file: _selectedImage!,
        bucketName: 'votify_files',
        context: context,
      );
    }
    try {
      final candidat = Candidat(
        id: '',
        nom: _nomController.text.trim(),
        image: imageUrl ?? imagePath,
        biographie: _descriptionController.text.trim(),
        nombreVotes: 0,
        scrutinId: widget.scrutinId,
      );

      await _scrutinService.addCandidatToScrutin(widget.scrutinId, candidat);
      _nomController.clear();
      _descriptionController.clear();
      _imageController.clear();
      _imageController.text = "Aucune image sélectionnée";
      setState(() {
        _selectedImage = null;
        imagePath = 'assets/images/default2.png';
      });
      widget.onSave(true);
    } catch (e) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Erreur',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent),
          ),
          content: Text('Une erreur est survenue : ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Candidat ${widget.candidatNumber}/${widget.totalCandidats}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
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
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(15),
                  ),
                ),
              ),
              if (_nomError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _nomError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
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
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(15),
                  ),
                ),
              ),
              if (_descriptionError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _descriptionError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => widget.onSave(false),
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
                  // GestureDetector(
                  //   onTap: _isLoading ? null : saveCandidat,
                  //   child: Container(
                  //     width: 40,
                  //     height: 40,
                  //     decoration: const BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Color(0xFF2FB364),
                  //     ),
                  //     child: _isLoading
                  //         ? const CircularProgressIndicator(color: Colors.white)
                  //         : const Icon(
                  //             Icons.save,
                  //             color: Colors.white,
                  //             size: 20,
                  //           ),
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: _isLoading ? null : saveCandidat,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2FB364),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Ajouter",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                //fontWeight: FontWeight.bold,
                              ),
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

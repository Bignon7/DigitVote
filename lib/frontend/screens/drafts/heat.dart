// ElevatedButton(
//                                         onPressed: statut == "En cours" ||
//                                                 statut == "Terminé"
//                                             ? () {
//                                                 if (statut == "En cours") {
//                                                   if (scrutin.code != null &&
//                                                       scrutin.code.isNotEmpty) {
//                                                     // Redirige vers la page de vérification
//                                                     Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             VerifyPage(
//                                                           scrutinId: scrutin.id,
//                                                           scrutinCode:
//                                                               scrutin.code,
//                                                         ),
//                                                       ),
//                                                     );
//                                                   } else {
//                                                     // Redirige directement vers la page des candidats
//                                                     Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             VoteCandidatsPage(
//                                                                 scrutinId:
//                                                                     scrutin.id),
//                                                       ),
//                                                     );
//                                                   }
//                                                 } else if (statut ==
//                                                     "Terminé") {
//                                                   Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           ResultsPage(
//                                                         scrutinId: scrutin.id,
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }
//                                               }
//                                             : null,
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: statut == "En cours"
//                                               ? AppColors.primary
//                                               : Colors.grey,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(20),
//                                           ),
//                                           minimumSize: Size(70, 36),
//                                         ),
//                                         child: Text(
//                                           statut == "Terminé"
//                                               ? 'Résultats'
//                                               : 'Voter',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),

////forulair_candidat est fonctionnel
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../../backend/services/candidat_service.dart';
import '../../../backend/services/scrutin_service.dart';
import '../../../backend/models/candidat.dart';
import '../../../backend/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../backend/services/supabase_service.dart';
import '../success_candidat.dart';
import '../../utils/custom_loader.dart';
import 'dart:io';

class NombreCandidatsPage extends StatefulWidget {
  final String scrutinId;

  const NombreCandidatsPage({Key? key, required this.scrutinId})
      : super(key: key);

  @override
  _NombreCandidatsPageState createState() => _NombreCandidatsPageState();
}

class _NombreCandidatsPageState extends State<NombreCandidatsPage> {
  final TextEditingController _nombreController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _continuerVersFormulaire() {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le nombre de candidats')),
      );
      return;
    }

    final nombre = int.tryParse(_nombreController.text);
    if (nombre == null || nombre <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nombre valide')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidatFormSequence(
          scrutinId: widget.scrutinId,
          nombreTotal: nombre,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Nombre de Candidats',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Entrez le nombre de candidats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _nombreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),
              const Spacer(),
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
                    onTap: _continuerVersFormulaire,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2FB364),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
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
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _imageController =
      TextEditingController(text: "Aucune image sélectionnée");
  final ScrutinService _scrutinService =
      ScrutinService(candidatService: CandidatService());
  bool _isLoading = false;
  String imagePath = 'assets/images/default2.png';
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

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _postController.dispose();
    super.dispose();
  }

  Future<void> saveCandidat() async {
    if (_nomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le nom du candidat')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_selectedImage != null) {
      final imageUrl = await SupabaseService().uploadImageForScrutin(
        file: _selectedImage!,
        bucketName: 'votify_files',
        context: context,
      );

      if (imageUrl != null) {
        try {
          final candidat = Candidat(
            id: '',
            nom: _nomController.text,
            image: imageUrl,
            biographie: _descriptionController.text,
            nombreVotes: 0,
            scrutinId: widget.scrutinId,
          );

          await _scrutinService.addCandidatToScrutin(
              widget.scrutinId, candidat);
          _nomController.clear();
          _descriptionController.clear();
          _postController.clear();
          setState(() {
            imagePath =
                'assets/images/default2.png'; // Réinitialiser l'image à la valeur par défaut
          });
          widget.onSave(true);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        } finally {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erreur: Veuillez sélectionner une image avant de télécharger.')),
        );
      }
    }
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
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Poste',
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
                  controller: _postController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
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
                  GestureDetector(
                    onTap: _isLoading ? null : saveCandidat,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2FB364),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
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

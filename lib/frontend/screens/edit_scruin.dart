import 'package:flutter/material.dart';
import '../../backend/services/scrutin_service.dart';
import '../../backend/models/scrutin.dart';
import '../utils/colors.dart';
import '../utils/custom_loader.dart';
import 'package:provider/provider.dart';
import '../../backend/providers/user_provider.dart';

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

  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateOuvertureController = TextEditingController();
  final _dateClotureController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdating = false;

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _updateScrutin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });
      try {
        await _scrutinService.updateScrutin(widget.scrutinId, {
          'titre': _titreController.text,
          'description': _descriptionController.text,
          'date_ouverture': _dateOuvertureController.text,
          'date_cloture': _dateClotureController.text,
        });
        Navigator.pop(context);
      } catch (e) {
        _showErrorDialog(context, e.toString());
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;

    if (_isLoading || userData == null) {
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
                    "Modifier le scrutin",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                _buildDateField(
                    "Date de clôture", _dateClotureController, true),
                _buildDescriptionField(),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updateScrutin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    ),
                    child: _isUpdating
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Mettre à jour",
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
}

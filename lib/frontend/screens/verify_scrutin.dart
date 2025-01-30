import 'package:flutter/material.dart';
import 'candidats_page.dart';

class VerifyPage extends StatefulWidget {
  final String scrutinId;
  final String scrutinCode;

  VerifyPage({
    required this.scrutinId,
    required this.scrutinCode,
  });

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  int failedAttempts = 0;
  int codeLength = 8;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(codeLength, (_) => TextEditingController());
    focusNodes = List.generate(codeLength, (_) => FocusNode());
    // Initialiser le focus sur la première case
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Vérifie si tous les champs sont remplis
    bool isButtonEnabled =
        controllers.every((controller) => controller.text.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topbar avec bouton retour et titre centré
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    const Text(
                      "Vérification",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                        width: 48), // Espace pour équilibrer visuellement
                  ],
                ),

                const SizedBox(height: 40),

                // Icône du cadenas
                Center(
                  child: Image.asset(
                    'assets/lock.png', // Remplacez par le chemin de votre image
                    height: 120,
                  ),
                ),

                const SizedBox(height: 20),

                // Texte d'instruction
                const Center(
                  child: Text(
                    "Renseignez le code de vérification de ce scrutin pour voter.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Champs de saisie pour le code
                Center(
                  child: Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: List.generate(codeLength, (index) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < codeLength - 1) {
                              focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              focusNodes[index - 1].requestFocus();
                            }
                            setState(() {});
                          },
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton Envoyer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled
                        ? () {
                            _validateCode(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled
                          ? const Color(0xFF2FB364)
                          : Colors.grey, // Bouton grisé
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      "Envoyer",
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
        ),
      ),
    );
  }

  /* void _validateCode(BuildContext context) {
    final enteredCode = controllers
        .map((controller) => controller.text)
        .join(); // Combine les valeurs

    if (enteredCode == widget.scrutinCode) {
      // Si le code est correct
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VoteCandidatsPage(scrutinId: widget.scrutinId),
        ),
      );
    } else {
      // Si le code est incorrect
      setState(() {
        failedAttempts++;
        for (var controller in controllers) {
          controller.clear(); // Vide les champs
        }
        // Réinitialise le focus sur la première case
        focusNodes.first.requestFocus();
      });

      if (failedAttempts < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Code incorrect. Tentative ${failedAttempts}/3"),
          ),
        );
      } else {
        // Affiche un AlertDialog après 3 échecs
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Accès refusé"),
            content: const Text(
              "Vous n'avez pas la permission de voter pour ce scrutin.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
        Navigator.pop(context);
      }
    }
  }
*/

  void _validateCode(BuildContext context) {
    final enteredCode = controllers
        .map((controller) => controller.text)
        .join(); // Combine les valeurs

    if (enteredCode == widget.scrutinCode) {
      // Si le code est correct
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VoteCandidatsPage(scrutinId: widget.scrutinId),
        ),
      );
    } else {
      // Si le code est incorrect
      setState(() {
        failedAttempts++;
        for (var controller in controllers) {
          controller.clear(); // Vide les champs
        }
        // Réinitialise le focus sur la première case
        focusNodes.first.requestFocus();
      });

      if (failedAttempts < 3) {
        // SnackBar amélioré
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Code incorrect. Tentative ${failedAttempts}/3",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        );
      } else {
        // AlertDialog amélioré après 3 échecs
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(
                  Icons.error,
                  color: Colors.redAccent,
                ),
                SizedBox(width: 10),
                Text(
                  "Accès refusé",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Vous n'avez pas la permission de voter pour ce scrutin.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.cancel,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "3 tentatives échouées",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Retour",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}

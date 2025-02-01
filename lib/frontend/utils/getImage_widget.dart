import 'package:flutter/material.dart';

Widget getImage(String imagePath) {
  if (imagePath.isEmpty) {
    return _buildDefaultImage();
  }

  if (imagePath.startsWith('http')) {
    return Image.network(
      imagePath,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          imagePath,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultImage();
          },
        );
      },
    );
  }
  return Image.asset(
    imagePath,
    height: 250,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return _buildDefaultImage();
    },
  );
}

Widget _buildDefaultImage() {
  return Image.asset(
    'assets/images/default2.png',
    height: 250,
    width: double.infinity,
    fit: BoxFit.cover,
  );
}

// Utilisation
// ClipRRect(
//   borderRadius: BorderRadius.circular(20),
//   child: getImage(widget.candidat.image),
// )

// CircleAvatar(
//   radius: 30,
//   backgroundImage: _getImageProvider(candidat.image),
// )

ImageProvider<Object> getImageProvider(String imagePath) {
  if (imagePath.isEmpty || !_isValidImagePath(imagePath)) {
    return const AssetImage("assets/images/default2.png");
  }
  if (imagePath.startsWith('http')) {
    try {
      return NetworkImage(imagePath);
    } catch (e) {
      return const AssetImage("assets/images/default2.png");
    }
  }
  if (_isAssetImage(imagePath)) {
    return AssetImage(imagePath);
  }
  return const AssetImage("assets/images/default2.png");
}

bool _isValidImagePath(String path) {
  return path.isNotEmpty &&
      (path.startsWith('assets/') ||
          path.startsWith('lib/assets/') ||
          path.startsWith('http'));
}

bool _isAssetImage(String path) {
  final validAssets = [
    "assets/images/default2.png",
  ];
  return validAssets.contains(path);
}

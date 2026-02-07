import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../theme/theme_manager.dart';

class ProfileHeader extends StatelessWidget {
  final String name, uid, selectedAvatar, rankName;
  final bool isGlitching;
  final Animation<double> scannerAnimation;
  final int level;
  final Function(String) onAvatarChange;

  const ProfileHeader({super.key, required this.name, required this.uid, required this.selectedAvatar, required this.isGlitching, required this.scannerAnimation, required this.level, required this.rankName, required this.onAvatarChange});

  String get shortId => uid.length > 4 ? uid.substring(uid.length - 4).toUpperCase() : uid;

  ImageProvider _getAvatarProvider(String path) {
    if (path.startsWith('assets/')) return AssetImage(path);
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    return Row(
      children: [
        RotatedBox(quarterTurns: 3, child: Text("UNIT #$shortId", style: TextStyle(color: theme.subText, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _pickImage(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isGlitching ? theme.textColor : theme.accentColor, width: 2),
              boxShadow: [BoxShadow(color: theme.accentColor.withOpacity(0.2), blurRadius: isGlitching ? 20 : 10)],
            ),
            child: CircleAvatar(backgroundColor: theme.bgColor, backgroundImage: _getAvatarProvider(selectedAvatar)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(color: isGlitching ? Colors.cyanAccent : theme.textColor, fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Level $level • $rankName", style: TextStyle(color: theme.accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ]),
        ),
        GestureDetector(
          onTap: () => showDialog(context: context, builder: (c) => Center(child: Container(width: 250, padding: EdgeInsets.all(12), color: Colors.white, child: QrImageView(data: uid)))),
          child: SizedBox(width: 30, height: 30, child: Icon(Icons.qr_code, color: theme.textColor)),
        )
      ],
    );
  }

  void _pickImage(BuildContext context) async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(img != null) onAvatarChange(img.path);
  }
}
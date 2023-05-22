import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final Function(File pickedImage) imagePickFn;

  UserImagePicker(this.imagePickFn);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final option = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("Source"),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 1),
            child: const Text("Camera"),
          ),
          const SizedBox(
            height: 20,
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 2),
            child: const Text("Gallery"),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );

    if (option == null) {
      return;
    }
    final XFile? image = await picker.pickImage(
        source: option == 1 ? ImageSource.camera : ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
      widget.imagePickFn(_pickedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 30,
          backgroundColor: _pickedImage == null ? Colors.blue : null,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text("Pick your avatar"),
        ),
      ],
    );
  }
}

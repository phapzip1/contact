import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  static StorageMethods? _instance;
  FirebaseStorage? _storage;

  StorageMethods._() {
    _storage = FirebaseStorage.instance;
  }

  static StorageMethods getInstance() {
    if (_instance == null) {
      _instance = StorageMethods._();
      return _instance!;
    }
    return _instance!;
  }

  Future<String> uploadImage(File file, String filename) async {
    try {
      final ref = _storage!.ref().child("avatars/$filename");
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return "Upload failed";
    }
  }
}
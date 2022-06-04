import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/services/cloud_fire.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class FireStorage {
  final _user = FirebaseAuth.instance.currentUser;
  final _fireStorage = FirebaseStorage.instance;
  final CloudFire _cloudFire = CloudFire();

  Future<void> uploadProfileImage({
    required File? image,
    // required bool delete,
  }) async {
    try {
      // Delete profile image if the user has not seletecd a image and delete is true.

      final result = await InternetConnectionChecker().hasConnection;

      if (result) {
        // if (image == null && delete) {
        //   await deleteProfileImage();
        //   await _cloudFire.updatePhotoURL(photoUrl: null);
        //   await _user?.updatePhotoURL(null);
        //   return;
        // }

        if (image != null && _user?.uid != null) {
          final ref = await _fireStorage
              .ref()
              .child('users/${_user?.uid}/images/${_user?.uid}')
              .putFile(image);
          final url = await getPhotoUrl(fileRef: ref.ref.fullPath);
          await _user?.updatePhotoURL(url);
          await _cloudFire.updatePhotoURL(photoUrl: url);
        }
      } else {
        throw kConnectionException;
      }
    } on FirebaseStorage catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<String> getPhotoUrl({required String fileRef}) async {
    return await _fireStorage.ref(fileRef).getDownloadURL();
  }

  Future<void> deleteProfileImage() async {
    try {
      final userId = _user?.uid;
      if (userId != null) {
        final user = await _cloudFire.getUser(id: userId);
        if (user?.photoURL != null) {
          await _fireStorage.ref('users/$userId/images/$userId').delete();
        }
        await _cloudFire.updatePhotoURL(photoUrl: null);
        await _user?.updatePhotoURL(null);
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}

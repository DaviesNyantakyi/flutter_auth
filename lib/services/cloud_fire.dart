import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/models/user_model.dart';

class CloudFire {
  final FirebaseFirestore _cloudFire = FirebaseFirestore.instance;

  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> createUser({required UserModel user}) async {
    try {
      final result = await InternetConnectionChecker().hasConnection;
      if (result) {
        await _cloudFire
            .collection('users')
            .doc(_firebaseAuth.currentUser?.uid ?? user.id)
            .set(user.toMap());
      } else {
        throw kConnectionException;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserModel?> getUser({required String? id}) async {
    try {
      final result = await InternetConnectionChecker().hasConnection;
      if (result) {
        final doc = await _cloudFire.collection('users').doc(id).get();
        if (doc.exists) {
          return UserModel.fromMap(map: doc.data()!);
        }
        return null;
      } else {
        throw kConnectionException;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Stream<UserModel?> userStream() {
    final docSnap = _cloudFire
        .collection('users')
        .doc(_firebaseAuth.currentUser?.uid)
        .snapshots();

    return docSnap.map((doc) {
      if (doc.data() != null) {
        return UserModel.fromMap(map: doc.data()!);
      }
      return null;
    });
  }

  Future<void> updatePhotoURL({required String? photoUrl}) async {
    try {
      await _cloudFire
          .collection('users')
          .doc(_firebaseAuth.currentUser?.uid)
          .update({
        'photoURL': photoUrl,
      });
      await _firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      rethrow;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateUsername({required String userName}) async {
    try {
      await _cloudFire
          .collection('users')
          .doc(_firebaseAuth.currentUser?.uid)
          .update({'userName': userName});
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateBio({required String? bio}) async {
    try {
      await _cloudFire
          .collection('users')
          .doc(_firebaseAuth.currentUser?.uid)
          .update({
        'bio': bio,
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateUserEmail({required String email}) async {
    try {
      await _cloudFire
          .collection('users')
          .doc(_firebaseAuth.currentUser?.uid)
          .update({
        'email': email,
      });
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      rethrow;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateGender({required String gender}) async {
    try {
      if (gender.isNotEmpty) {
        await _cloudFire
            .collection('users')
            .doc(_firebaseAuth.currentUser?.uid)
            .update({'gender': gender.toLowerCase()});
      }
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      rethrow;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteUserInfo() async {
    try {
      if (_firebaseAuth.currentUser?.uid != null) {
        await _cloudFire
            .collection('users')
            .doc(_firebaseAuth.currentUser!.uid)
            .delete();
      }
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      rethrow;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}

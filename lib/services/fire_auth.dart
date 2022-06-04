import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/models/user_model.dart';
import 'package:flutter_auth/services/cloud_fire.dart';
import 'package:flutter_auth/services/fire_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class FireAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final CloudFire _cloudFire = CloudFire();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> createUserEmailPassword({
    required String userName,
    required String email,
    required String password,
    required String gender,
  }) async {
    try {
      final result = await InternetConnectionChecker().hasConnection;

      if (result) {
        if (email.isNotEmpty && password.isNotEmpty) {
          // Delete anon user if he desides to signup.
          if (_firebaseAuth.currentUser?.isAnonymous == true) {
            await _firebaseAuth.currentUser?.delete();
          }
          await _firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          await _firebaseAuth.currentUser?.updateDisplayName(userName);
          final user = UserModel(
            id: _firebaseAuth.currentUser?.uid,
            userName: userName,
            photoURL: _firebaseAuth.currentUser?.photoURL,
            email: email,
            gender: gender,
          );
          await _cloudFire.createUser(user: user);

          await _firebaseAuth.currentUser?.reload();
          return _firebaseAuth.currentUser;
        }
      } else {
        throw kConnectionException;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
    // return null if authentication fails.
    return null;
  }

  Future<UserCredential?> loginEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await InternetConnectionChecker().hasConnection;

      if (result) {
        if (email.isNotEmpty && password.isNotEmpty) {
          // Delete anon user if he desides to signup.
          if (_firebaseAuth.currentUser?.isAnonymous == true) {
            await _firebaseAuth.currentUser?.delete();
          }
          final user = await _firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          return user;
        }

        // return null if authentication fails.
        return null;
      } else {
        throw kConnectionException;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<User?> loginAnonymous() async {
    try {
      final result = await InternetConnectionChecker().hasConnection;

      if (result) {
        await _firebaseAuth.signInAnonymously();
        return _firebaseAuth.currentUser;
      } else {
        throw kConnectionException;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteAccount({String? password}) async {
    try {
      if (password != null && password.isNotEmpty) {
        final email = _firebaseAuth.currentUser?.email;
        if (email != null) {
          final credential =
              EmailAuthProvider.credential(email: email, password: password);
          _firebaseAuth.currentUser?.reauthenticateWithCredential(
            credential,
          );
          await _firebaseAuth.currentUser?.reload();
          await FireStorage().deleteProfileImage();
          await _cloudFire.deleteUserInfo();

          await _firebaseAuth.currentUser?.delete();
          await logout();
        }
      }
      if (_firebaseAuth.currentUser?.providerData[0].providerId ==
          'google.com') {
        await _firebaseAuth.currentUser?.reload();
        await FireStorage().deleteProfileImage();
        await _cloudFire.deleteUserInfo();
        await _firebaseAuth.currentUser?.delete();
      }
    } catch (e) {
      debugPrint(e.toString());

      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // When a anon user singOut and login again a new anon user gets created.
      // So when the user logs out we delete the account.
      if (_firebaseAuth.currentUser?.isAnonymous == true) {
        await _firebaseAuth.currentUser?.delete();
      }
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserCredential?> loginGoogle() async {
    try {
      final result = await InternetConnectionChecker().hasConnection;

      if (result) {
        if (_firebaseAuth.currentUser?.isAnonymous == true) {
          await _firebaseAuth.currentUser?.delete();
          await _firebaseAuth.signOut();
        }
        // Show the authentication flow (dialog).
        final googleUser = await _googleSignIn.signIn();

        if (googleUser != null) {
          final user = await googleUser.authentication;
          final cred = GoogleAuthProvider.credential(
            idToken: user.idToken,
            accessToken: user.accessToken,
          );
          final userCred = await _firebaseAuth.signInWithCredential(cred);

          // Create create user document if it does not exist.
          // Try to get the user
          final userDoc =
              await _cloudFire.getUser(id: _firebaseAuth.currentUser!.uid);

          // Create a user if in firestore if it does not exits.
          if (userDoc == null) {
            final user = UserModel(
              id: _firebaseAuth.currentUser?.uid,
              userName: _firebaseAuth.currentUser!.displayName!,
              email: _firebaseAuth.currentUser!.email!,
            );
            await _cloudFire.createUser(user: user);
          }
          return userCred;
        }
      } else {
        throw kConnectionException;
      }

      // Return null if the authentication flow fails.
      return null;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
    // return null if authentication fails.
  }

  Future<User?> loginApple() async {
    try {
      final result = await InternetConnectionChecker().hasConnection;

      if (result) {
        // TODO: Implement login with Apple:
        // https://firebase.flutter.dev/docs/auth/social/#:~:text=see%20this%20issue.-,apple
      } else {
        throw kConnectionException;
      }

      // Return null if the authentication flow fails.
      return null;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
    // return null if authentication fails.
  }

  // Send email verifaction.
  Future<void> sendEmailVerfication() async {
    try {
      final result = await InternetConnectionChecker().hasConnection;

      if (result) {
        // Reload the current user info.
        await _firebaseAuth.currentUser?.reload();

        // Check if the user id verifed.
        final verfied = _firebaseAuth.currentUser?.emailVerified;

        // Send verfication mail if the user is not verified.
        if (verfied == false) {
          await _firebaseAuth.currentUser?.sendEmailVerification();
        }
      } else {
        throw kConnectionException;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
    // return null if authentication fails.
  }

  // Update the user display name.
  Future<void> updateDisplayName({required String displayName}) async {
    try {
      final name = displayName.trim();
      if (displayName.isNotEmpty) {
        await _firebaseAuth.currentUser?.updateDisplayName(name);
        await _cloudFire.updateUsername(userName: name);
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  // Send email verifcation before changing the email.
  Future<bool> updateEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await InternetConnectionChecker().hasConnection;
      if (result) {
        if (_firebaseAuth.currentUser?.email != null &&
            email.isNotEmpty &&
            password.isNotEmpty) {
          // Reauthenticat the user. This is necessary for changing email.
          final cred = EmailAuthProvider.credential(
            email: _firebaseAuth.currentUser!.email!,
            password: password,
          );

          await _firebaseAuth.currentUser?.reauthenticateWithCredential(cred);
          await _firebaseAuth.currentUser?.reload();

          // Send email verifaction to the new email.
          await _firebaseAuth.currentUser?.updateEmail(email.trim());
          await _firebaseAuth.currentUser?.reload();
          await _cloudFire.updateUserEmail(email: email);
          await _firebaseAuth.currentUser?.sendEmailVerification();

          await logout();
          return true;
        }
      } else {
        throw kConnectionException;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<bool> sendPasswordReset() async {
    try {
      final result = await InternetConnectionChecker().hasConnection;
      if (result) {
        final email = _firebaseAuth.currentUser?.email;
        if (email != null) {
          await _firebaseAuth.sendPasswordResetEmail(email: email);
          return true;
        }
      } else {
        throw kConnectionException;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}

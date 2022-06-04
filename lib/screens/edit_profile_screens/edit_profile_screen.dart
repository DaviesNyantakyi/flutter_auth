import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/models/user_model.dart';
import 'package:flutter_auth/screens/edit_profile_screens/edit_bio_screen.dart';
import 'package:flutter_auth/screens/edit_profile_screens/edit_email_screen.dart';
import 'package:flutter_auth/screens/edit_profile_screens/edit_gender_screen.dart';
import 'package:flutter_auth/screens/edit_profile_screens/edit_name_screen.dart';
import 'package:flutter_auth/services/cloud_fire.dart';
import 'package:flutter_auth/services/fire_auth.dart';
import 'package:flutter_auth/services/fire_storage.dart';
import 'package:flutter_auth/utilities/image_picker.dart';
import 'package:flutter_auth/utilities/validators.dart';
import 'package:flutter_auth/widgets/dialog.dart';
import 'package:flutter_auth/widgets/textfield.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// 1: Click on update
// 2: Check for sensitive change.
// 3: If no sensitive info changed update normally
// 4: if sensitive info has changed show bottom sheet to confirm.
// 5: Update profile.

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  MyImagePicker myImagePicker = MyImagePicker();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final providerId =
      FirebaseAuth.instance.currentUser?.providerData[0].providerId;
  final userStream = CloudFire().userStream();

  TextEditingController passwordCntrl = TextEditingController();
  final passwordKey = GlobalKey<FormState>();

  final editIcon = const Icon(Icons.edit, color: kBlue);
  Future<void> uploadImage() async {
    try {
      EasyLoading.show();

      await FireStorage().uploadProfileImage(image: myImagePicker.image);
      await _firebaseAuth.currentUser?.reload();
    } on FirebaseException catch (e) {
      kShowSnackbar(context: context, message: e.message ?? '');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      EasyLoading.dismiss();
      setState(() {});
    }
  }

  Future<void> deleteImage() async {
    try {
      EasyLoading.show();
      await FireStorage().deleteProfileImage();
      await _firebaseAuth.currentUser?.reload();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        await CloudFire().updatePhotoURL(photoUrl: null);
        await _firebaseAuth.currentUser?.updatePhotoURL(null);
        return;
      }
      kShowSnackbar(context: context, message: e.message ?? '');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      EasyLoading.dismiss();
      setState(() {});
    }
  }

  Future<void> resetPassword() async {
    try {
      EasyLoading.show();
      bool sent = await FireAuth().sendPasswordReset();
      if (sent) {
        kShowSnackbar(
          context: context,
          message:
              'Password recovery instructions has been sent to ${_firebaseAuth.currentUser?.email}',
        );
      }
    } on FirebaseException catch (e) {
      kShowSnackbar(context: context, message: e.message ?? '');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      EasyLoading.dismiss();
      setState(() {});
    }
  }

  Future<void> deleteAccount() async {
    try {
      Navigator.pop(context);
      EasyLoading.show();

      final validPassword = passwordKey.currentState?.validate();

      if (validPassword == true && passwordCntrl.text.isNotEmpty) {
        await FireAuth().deleteAccount(password: passwordCntrl.text);

        // Pop dialog and and current screen.
        if (mounted) {
          Navigator.of(context).pop();
        }
      }

      if (providerId == 'google.com') {
        await FireAuth().deleteAccount(password: passwordCntrl.text);
        // Pop dialog and and current screen.
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } on FirebaseException catch (e) {
      kShowSnackbar(context: context, message: e.message ?? '');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      EasyLoading.dismiss();
      setState(() {});
    }
  }

  Future<void> showDeleteDialog() async {
    passwordCntrl.clear();
    passwordKey.currentState?.reset();
    showCustomDialog(
      context: context,
      title: const Text(
        'Delete account?',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'This action cannot be undone and all content will be lost.',
          ),
          const SizedBox(height: kContentSpacing8),
          _buildPasswordField(),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          onPressed: deleteAccount,
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Future<void> pickImage() async {
    final delete = await myImagePicker.showBottomSheet(context: context);
    if (myImagePicker.image != null && delete == false) {
      await uploadImage();
      myImagePicker.image = null;
      setState(() {});
    }
    if (delete == true) {
      deleteImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT PROFILE'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<UserModel?>(
              stream: userStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.hasData) {
                  return Column(
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: kContentSpacing32),
                      _buildNameField(name: snapshot.data!.userName),
                      const SizedBox(height: kContentSpacing8),
                      _buildEmailField(email: snapshot.data!.email),
                      const SizedBox(height: kContentSpacing8),
                      _buildGenderField(gender: snapshot.data!.gender!),
                      const SizedBox(height: kContentSpacing8),
                      _buildBioField(bio: snapshot.data?.bio ?? ''),
                      const SizedBox(height: kContentSpacing32),
                      _buildResetButton(),
                      const SizedBox(height: kContentSpacing8),
                      _buildDeleteButton(),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    ImageProvider? image;
    Widget icon = const Icon(
      Icons.person_outline_outlined,
      color: Colors.black45,
      size: 50,
    );

    if (_firebaseAuth.currentUser?.photoURL != null) {
      image = CachedNetworkImageProvider(
        _firebaseAuth.currentUser!.photoURL!,
      );
      icon = Container();
    }

    return GestureDetector(
      onTap: pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: kGreyLight,
            backgroundImage: image,
            child: icon,
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              child: Icon(Icons.edit),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNameField({required String name}) {
    return CustomTextFormField(
      key: Key(name),
      readOnly: true,
      initialValue: name,
      hintText: 'Name',
      suffixIcon: editIcon,
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const EditNameScreen(),
          ),
        );
      },
    );
  }

  Widget _buildEmailField({required String email}) {
    return CustomTextFormField(
      key: Key(email),
      readOnly: true,
      initialValue: email,
      hintText: 'Email',
      suffixIcon: editIcon,
      onTap: () async {
        await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const EditEmailScreen(),
          ),
        );
      },
    );
  }

  Widget _buildGenderField({required String gender}) {
    return CustomTextFormField(
      key: Key(gender),
      initialValue: gender,
      readOnly: true,
      hintText: "Gender",
      suffixIcon: editIcon,
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EditGenderScreen(gender: gender),
          ),
        );
      },
    );
  }

  Widget _buildBioField({required String bio}) {
    return CustomTextFormField(
      key: Key(bio),
      initialValue: bio,
      readOnly: true,
      hintText: 'About me',
      suffixIcon: editIcon,
      onTap: () async {
        await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EditBioScreen(bio: bio),
          ),
        );
      },
    );
  }

  Widget _buildResetButton() {
    return Container(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: resetPassword,
        child: const Text(
          'Reset password',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: showDeleteDialog,
        child: const Text(
          'Delete account',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    if (providerId == 'google.com') {
      return Container();
    }
    return Form(
      key: passwordKey,
      child: CustomTextFormField(
        controller: passwordCntrl,
        maxLines: 1,
        hintText: 'Password',
        obscureText: true,
        validator: Validators.passwordValidator,
      ),
    );
  }
}

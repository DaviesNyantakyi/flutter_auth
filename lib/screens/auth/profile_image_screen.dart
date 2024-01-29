import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/screens/auth/auth_wrapper.dart';
import 'package:flutter_auth/services/fire_storage.dart';
import 'package:flutter_auth/utilities/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ProfileImageScreen extends StatefulWidget {
  const ProfileImageScreen({super.key});

  @override
  State<ProfileImageScreen> createState() => _ProfileImageScreenState();
}

class _ProfileImageScreenState extends State<ProfileImageScreen> {
  late final MyImagePicker myImagePicker = MyImagePicker();

  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> conitnueButton() async {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AuthWrapper(),
      ),
      ModalRoute.withName(AuthWrapper.authWrapper),
    );
  }

  Future<void> uploadImage() async {
    try {
      EasyLoading.show();

      await FireStorage().uploadProfileImage(
        image: myImagePicker.image,
        // delete: false,
      );
      await auth.currentUser?.reload();
    } on FirebaseException catch (e) {
      Future.delayed(Duration.zero,
          () => kShowSnackbar(context: context, message: e.message ?? ''));
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
      await auth.currentUser?.reload();
    } on FirebaseException catch (e) {
      Future.delayed(Duration.zero,
          () => kShowSnackbar(context: context, message: e.message ?? ''));
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      EasyLoading.dismiss();
      setState(() {});
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderText(),
                const SizedBox(height: kContentSpacing32),
                _buildAvatar(),
                const SizedBox(height: kContentSpacing32),
                _buildContinueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return const Text(
      'Add profile image',
      style: TextStyle(fontSize: 20),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAvatar() {
    ImageProvider? image;
    Widget icon = const Icon(
      Icons.person_outline_outlined,
      color: Colors.black45,
      size: 50,
    );

    if (auth.currentUser?.photoURL != null) {
      image = CachedNetworkImageProvider(
        auth.currentUser!.photoURL!,
      );
      icon = Container();
    }

    return Center(
      child: GestureDetector(
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
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: conitnueButton,
      child: const Text('Continue'),
    );
  }
}

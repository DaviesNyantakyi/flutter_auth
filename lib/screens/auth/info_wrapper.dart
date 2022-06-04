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
import 'package:flutter_auth/screens/home_screen.dart';
import 'package:flutter_auth/services/cloud_fire.dart';
import 'package:flutter_auth/services/fire_storage.dart';
import 'package:flutter_auth/utilities/image_picker.dart';
import 'package:flutter_auth/utilities/validators.dart';
import 'package:flutter_auth/widgets/textfield.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class InfoWrapper extends StatefulWidget {
  const InfoWrapper({Key? key}) : super(key: key);

  @override
  State<InfoWrapper> createState() => _InfoWrapperState();
}

class _InfoWrapperState extends State<InfoWrapper> {
  final autStream = CloudFire().userStream();

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: autStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Somthing went wrong.'),
              _buillogoutButton(),
            ],
          ));
        }

        if (snapshot.hasData &&
            snapshot.data?.gender != null &&
            snapshot.data?.userName != null) {
          return const HomeScreen();
        }

        if (snapshot.hasData) {
          return _MissigInfoScreen(
            user: snapshot.data,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buillogoutButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          kBlue,
        ),
      ),
      onPressed: logout,
      child: const Text(
        'Logout',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class _MissigInfoScreen extends StatefulWidget {
  final UserModel? user;
  const _MissigInfoScreen({Key? key, this.user}) : super(key: key);

  @override
  State<_MissigInfoScreen> createState() => _MissigInfoScreenState();
}

class _MissigInfoScreenState extends State<_MissigInfoScreen> {
  MyImagePicker myImagePicker = MyImagePicker();
  final FirebaseAuth? _firebaseAuth = FirebaseAuth.instance;
  final userStream = CloudFire().userStream();

  TextEditingController passwordCntrl = TextEditingController();
  final passwordKey = GlobalKey<FormState>();

  final editIcon = const Icon(Icons.edit, color: kBlue);
  Future<void> uploadImage() async {
    try {
      EasyLoading.show();

      await FireStorage().uploadProfileImage(
        image: myImagePicker.image,
        // delete: false,
      );
      await _firebaseAuth?.currentUser?.reload();
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
      await _firebaseAuth?.currentUser?.reload();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        await CloudFire().updatePhotoURL(photoUrl: null);
        await _firebaseAuth?.currentUser?.updatePhotoURL(null);
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
        title: const Text('Add info'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAvatar(),
                const SizedBox(height: kContentSpacing32),
                _buildNameField(name: widget.user?.userName ?? ''),
                const SizedBox(height: kContentSpacing8),
                _buildEmailField(email: widget.user?.email ?? ''),
                const SizedBox(height: kContentSpacing8),
                _buildGenderField(gender: widget.user?.gender ?? ''),
                const SizedBox(height: kContentSpacing8),
                _buildBioField(bio: widget.user?.bio ?? ''),
              ],
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

    if (_firebaseAuth!.currentUser?.photoURL != null) {
      image = CachedNetworkImageProvider(
        _firebaseAuth!.currentUser!.photoURL!,
      );
      icon = Container();
    }

    return GestureDetector(
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
      onTap: pickImage,
    );
  }

  Widget _buildNameField({required String name}) {
    return CustomTextFormField(
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
      initialValue: gender,
      readOnly: true,
      hintText: "Gender",
      suffixIcon: editIcon,
      validateMode: AutovalidateMode.always,
      validator: Validators.genderValidator,
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
}

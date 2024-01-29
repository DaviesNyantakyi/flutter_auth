import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/services/cloud_fire.dart';
import 'package:flutter_auth/services/fire_auth.dart';
import 'package:flutter_auth/widgets/textfield.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EditBioScreen extends StatefulWidget {
  final String bio;
  const EditBioScreen({super.key, required this.bio});

  @override
  State<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  TextEditingController? bioCntlr;
  final bioKey = GlobalKey<FormState>();

  final fireAuth = FireAuth();
  final coudFire = CloudFire();
  final fireUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    bioCntlr?.dispose();
    bioKey.currentState?.dispose();
    super.dispose();
  }

  Future<void> init() async {
    bioCntlr = TextEditingController(text: widget.bio);
  }

  Future<void> update() async {
    try {
      EasyLoading.show();
      if (bioCntlr?.text != null && bioCntlr?.text.trim() != widget.bio) {
        await coudFire.updateBio(bio: bioCntlr?.text);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      Future.delayed(Duration.zero,
          () => kShowSnackbar(context: context, message: e.message ?? ''));
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT BIO'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kBodyPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBioField(),
              const SizedBox(height: kContentSpacing32),
              _buildUpateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBioField() {
    return Form(
      key: bioKey,
      child: CustomTextFormField(
        controller: bioCntlr,
        hintText: 'About me',
        maxLines: 1,
        maxLength: 150,
        validateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildUpateButton() {
    return ElevatedButton(
      onPressed: update,
      child: const Text('Update'),
    );
  }
}

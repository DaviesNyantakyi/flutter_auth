import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/services/cloud_fire.dart';
import 'package:flutter_auth/utilities/validators.dart';
import 'package:flutter_auth/widgets/textfield.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EditGenderScreen extends StatefulWidget {
  final String gender;
  const EditGenderScreen({Key? key, required this.gender}) : super(key: key);

  @override
  State<EditGenderScreen> createState() => _EditGenderScreenState();
}

class _EditGenderScreenState extends State<EditGenderScreen> {
  TextEditingController? gender;
  final genderKey = GlobalKey<FormState>();

  final fireAuth = CloudFire();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    gender?.dispose();
    genderKey.currentState?.dispose();
    super.dispose();
  }

  Future<void> init() async {
    gender = TextEditingController(text: widget.gender);
  }

  Future<void> update() async {
    try {
      EasyLoading.show();
      if (gender?.text != null && gender?.text != user?.displayName) {
        await fireAuth.updateGender(gender: gender!.text);
      }
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      kShowSnackbar(context: context, message: e.message ?? '');
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
        title: const Text('Gender'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kBodyPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNameField(),
              const SizedBox(height: kContentSpacing32),
              _buildUpateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Form(
      key: genderKey,
      child: CustomTextFormField(
        controller: gender,
        maxLines: 1,
        hintText: 'Gender',
        validator: Validators.genderValidator,
        textInputAction: TextInputAction.done,
        validateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildUpateButton() {
    return ElevatedButton(
      child: const Text('Update'),
      onPressed: update,
    );
  }
}

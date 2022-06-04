import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/services/fire_auth.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/utilities/image_picker.dart';
import 'package:flutter_auth/utilities/validators.dart';
import 'package:flutter_auth/screens/auth/profile_image_screen.dart';
import 'package:flutter_auth/widgets/textfield.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  TextEditingController usernameCntlr = TextEditingController();
  TextEditingController emailCntlr = TextEditingController();
  TextEditingController passwordCntlr = TextEditingController();
  TextEditingController genderCntlr = TextEditingController();
  final userNameKey = GlobalKey<FormState>();
  final emailKey = GlobalKey<FormState>();
  final passwordKey = GlobalKey<FormState>();
  final genderKey = GlobalKey<FormState>();

  FireAuth fireAuth = FireAuth();
  bool isLoading = false;
  late final MyImagePicker myImagePicker;

  @override
  void dispose() {
    emailCntlr.dispose();
    passwordCntlr.dispose();
    genderCntlr.dispose();
    genderKey.currentState?.dispose();
    emailKey.currentState?.dispose();
    passwordKey.currentState?.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    try {
      final validUserName = userNameKey.currentState?.validate();
      final validEmail = emailKey.currentState?.validate();
      final validPassword = passwordKey.currentState?.validate();
      final validGender = genderKey.currentState?.validate();

      if (validUserName == true &&
          validEmail == true &&
          validPassword == true &&
          validGender == true) {
        isLoading = true;
        setState(() {});
        EasyLoading.show();
        await fireAuth.createUserEmailPassword(
          userName: usernameCntlr.text.trim(),
          email: emailCntlr.text.trim(),
          password: passwordCntlr.text,
          gender: genderCntlr.text.toLowerCase(),
        );

        if (mounted) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const ProfileImageScreen(),
            ),
          );
        }
      }
    } on FirebaseException catch (e) {
      kShowSnackbar(context: context, message: e.message ?? '');
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      EasyLoading.dismiss();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create account', style: TextStyle(fontSize: 32)),
              const SizedBox(height: kContentSpacing32),
              _buildNameField(),
              const SizedBox(height: kContentSpacing8),
              _builEmailField(),
              const SizedBox(height: kContentSpacing8),
              _buildPasswordField(),
              const SizedBox(height: kContentSpacing8),
              _buildGenderField(),
              const SizedBox(height: kContentSpacing32),
              _buildCreateButton(),
              const SizedBox(height: kContentSpacing8),
              _buildPrivacyText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Form(
      key: userNameKey,
      child: CustomTextFormField(
        controller: usernameCntlr,
        hintText: 'First & last name',
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        validator: Validators.nameValidator,
      ),
    );
  }

  Widget _builEmailField() {
    return Form(
      key: emailKey,
      child: CustomTextFormField(
        controller: emailCntlr,
        hintText: 'Email',
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        validator: Validators.emailValidator,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Form(
      key: passwordKey,
      child: CustomTextFormField(
        hintText: 'Password',
        obscureText: true,
        maxLines: 1,
        controller: passwordCntlr,
        textInputAction: TextInputAction.next,
        validator: Validators.passwordValidator,
      ),
    );
  }

  Widget _buildGenderField() {
    return Form(
      key: genderKey,
      child: CustomTextFormField(
        controller: genderCntlr,
        hintText: 'Gender',
        maxLines: 1,
        textInputAction: TextInputAction.done,
        validator: Validators.genderValidator,
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(isLoading ? Colors.black38 : kBlue),
      ),
      onPressed: isLoading ? null : signUp,
      child: const Text('Create account'),
    );
  }

  Widget _buildPrivacyText() {
    return Column(
      children: [
        const Text(
          'By creating an account, you agree to the ',
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: const Text(
                'Privacy Policy',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              onTap: () {},
            ),
            const Text(
              ' and',
            ),
            InkWell(
              child: const Text(
                ' Terms of Conditions',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              onTap: () {},
            ),
          ],
        )
      ],
    );
  }
}

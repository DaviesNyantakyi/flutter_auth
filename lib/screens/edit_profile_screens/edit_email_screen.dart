import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/services/fire_auth.dart';
import 'package:flutter_auth/utilities/validators.dart';
import 'package:flutter_auth/widgets/dialog.dart';
import 'package:flutter_auth/widgets/textfield.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EditEmailScreen extends StatefulWidget {
  const EditEmailScreen({Key? key}) : super(key: key);

  @override
  State<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  TextEditingController newEmailCntlr = TextEditingController();
  TextEditingController passwordCntlr = TextEditingController();
  final emailKey = GlobalKey<FormState>();
  final passwordKey = GlobalKey<FormState>();

  final fireAuth = FireAuth();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    newEmailCntlr.dispose();
    emailKey.currentState?.dispose();
    super.dispose();
  }

  Future<void>? showEmailDialog() {
    FocusScope.of(context).unfocus();

    if (newEmailCntlr.text.trim() == user?.email) {
      Navigator.pop(context);
      return null;
    }
    final validNewEmail = emailKey.currentState?.validate();
    final validPassword = passwordKey.currentState?.validate();

    if (validNewEmail == true && validPassword == true) {
      return showCustomDialog(
        context: context,
        title: const Text('PLEASE BE AWARE!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You will now be logged out of your account and asked to log in again with your new e-mail address:',
            ),
            Text(
              newEmailCntlr.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
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
            onPressed: updateEmail,
            child: const Text(
              'Update',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      );
    }
    return null;
  }

  Future<void> updateEmail() async {
    try {
      if (newEmailCntlr.text.trim() == user?.email?.trim()) {
        Navigator.pop(context);
        return;
      }

      final validNewEmail = emailKey.currentState?.validate();
      final validPassword = passwordKey.currentState?.validate();

      if (validNewEmail == true &&
          validPassword == true &&
          newEmailCntlr.text.isNotEmpty) {
        EasyLoading.show();
        final success = await fireAuth.updateEmail(
          email: newEmailCntlr.text,
          password: passwordCntlr.text,
        );
        if (success) {
          if (mounted) {
            Navigator.of(context)
              ..pop()
              ..pop()
              ..pop();
          }
        }
      }
    } on FirebaseException catch (e) {
      kShowSnackbar(context: context, message: e.message!);
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
        title: const Text('Email'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kBodyPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeaderText(),
              const SizedBox(height: kContentSpacing8),
              _buildEmailField(),
              const SizedBox(height: kContentSpacing8),
              _buildPasswordField(),
              const SizedBox(height: kContentSpacing32),
              _buildUpateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Changing your email address is a permanent',
        ),
        Text(
          'and you\'ll have to sign in with the new email address going forward. ',
        )
      ],
    );
  }

  Widget _buildEmailField() {
    return Form(
      key: emailKey,
      child: CustomTextFormField(
        hintText: 'New email',
        controller: newEmailCntlr,
        maxLines: 1,
        validator: Validators.emailValidator,
        textInputAction: TextInputAction.next,
        validateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Form(
      key: passwordKey,
      child: CustomTextFormField(
        hintText: 'Confirm with password',
        controller: passwordCntlr,
        maxLines: 1,
        obscureText: true,
        validator: Validators.passwordValidator,
        textInputAction: TextInputAction.done,
        validateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildUpateButton() {
    return ElevatedButton(
      onPressed: showEmailDialog,
      child: const Text('Update'),
    );
  }
}

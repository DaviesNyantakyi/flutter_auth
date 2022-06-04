import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/services/fire_auth.dart';
import 'package:flutter_auth/utilities/validators.dart';
import 'package:flutter_auth/widgets/textfield.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({Key? key}) : super(key: key);

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  TextEditingController? nameCntlr;
  final nameKey = GlobalKey<FormState>();

  final fireAuth = FireAuth();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    nameCntlr?.dispose();
    nameKey.currentState?.dispose();
    super.dispose();
  }

  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    nameCntlr = TextEditingController(text: user?.displayName);
  }

  Future<void> update() async {
    try {
      EasyLoading.show();
      if (nameCntlr?.text != null &&
          nameCntlr?.text.trim() != user?.displayName) {
        await fireAuth.updateDisplayName(displayName: nameCntlr!.text);
      }
      if (mounted) {
        Navigator.pop(context);
      }
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
        title: const Text('Name'),
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
      key: nameKey,
      child: CustomTextFormField(
        controller: nameCntlr,
        maxLines: 1,
        validator: Validators.nameValidator,
        textInputAction: TextInputAction.done,
        validateMode: AutovalidateMode.onUserInteraction,
        onSubmitted: (value) {},
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

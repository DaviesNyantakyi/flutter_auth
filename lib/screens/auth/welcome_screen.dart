import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/services/fire_auth.dart';
import 'package:flutter_auth/screens/auth/create_account_screen.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/utilities/validators.dart';
import 'package:flutter_auth/widgets/textfield.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isLoading = false;
  TextEditingController emailCntlr = TextEditingController();
  TextEditingController passwordCntlr = TextEditingController();
  final emailKey = GlobalKey<FormState>();
  final passwordKey = GlobalKey<FormState>();

  FireAuth fireAuth = FireAuth();

  FirebaseAuth auth = FirebaseAuth.instance;

  bool? wasAnonymouse;

  @override
  void initState() {
    wasAnonymouse = auth.currentUser?.isAnonymous;
    super.initState();
  }

  @override
  void dispose() {
    emailCntlr.dispose();
    passwordCntlr.dispose();
    wasAnonymouse = null;
    super.dispose();
  }

  Future<void> login() async {
    final emailIsValid = emailKey.currentState?.validate();
    final passwordIsValid = passwordKey.currentState?.validate();
    try {
      if (emailIsValid == true && passwordIsValid == true) {
        isLoading = true;
        EasyLoading.show();
        if (mounted) {
          setState(() {});
        }
        await fireAuth.loginEmailPassword(
          email: emailCntlr.text,
          password: passwordCntlr.text,
        );

        if (wasAnonymouse == true) {
          Navigator.pop(context);
        }
      }
    } on FirebaseException catch (e) {
      kShowSnackbar(context: context, message: e.message ?? '');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      EasyLoading.dismiss();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> loginGoogle() async {
    try {
      isLoading = true;
      EasyLoading.show();
      if (mounted) {
        setState(() {});
      }
      await fireAuth.loginGoogle();
    } on FirebaseException catch (e) {
      kShowSnackbar(context: context, message: e.message ?? '');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      EasyLoading.dismiss();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> skip() async {
    if (auth.currentUser != null) {
      Navigator.pop(context);
      return;
    }
    try {
      isLoading = true;
      EasyLoading.show();
      await fireAuth.loginAnonymous();
    } on FirebaseException catch (e) {
      kShowSnackbar(context: context, message: e.message ?? '');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      EasyLoading.dismiss();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildSkipButton(),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 64),
                const SizedBox(height: kContentSpacing32),
                _buildEmailField(),
                const SizedBox(height: kContentSpacing8),
                _buildPasswordField(),
                const SizedBox(height: kContentSpacing32),
                _buildLoginButton(),
                const SizedBox(height: kContentSpacing8),
                _buildGoogleButton(),
                _buildEmailButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
      ),
      onPressed: isLoading ? null : skip,
      child: const Text(
        'SKIP',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildEmailField() {
    return Form(
      key: emailKey,
      child: CustomTextFormField(
        hintText: 'Email',
        controller: emailCntlr,
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
        controller: passwordCntlr,
        maxLines: 1,
        obscureText: true,
        textInputAction: TextInputAction.next,
        validator: Validators.passwordValidator,
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isLoading ? kDisbaledColor : kBlue,
        ),
      ),
      onPressed: isLoading ? null : login,
      child: const Text(
        'Login',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isLoading ? Colors.black45 : Colors.red,
        ),
      ),
      icon: const Icon(Icons.abc),
      label: const Text('Continue with Google'),
      onPressed: loginGoogle,
    );
  }

  Widget _buildEmailButton() {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.black45),
      ),
      icon: const Icon(Icons.email_outlined),
      label: const Text('Continue with Email'),
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const CreateAccountScreen(),
          ),
        );
      },
    );
  }
}

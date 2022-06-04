import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/models/user_model.dart';
import 'package:flutter_auth/screens/auth/welcome_screen.dart';
import 'package:flutter_auth/screens/edit_profile_screens/edit_profile_screen.dart';
import 'package:flutter_auth/services/cloud_fire.dart';
import 'package:flutter_auth/services/fire_auth.dart';
import 'package:flutter_auth/constant.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  final userStream = CloudFire().userStream();

  @override
  void initState() {
    super.initState();
  }

  Future<void> logout() async {
    try {
      isLoading = true;
      if (mounted) {
        setState(() {});
      }
      await FireAuth().logout();
    } on FirebaseException catch (e) {
      kShowSnackbar(context: context, message: e.message ?? '');
      debugPrint(e.toString());
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> edit() async {
    if (auth.currentUser?.isAnonymous == true) {
      await Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
      if (mounted) {
        setState(() {});
      }
      return;
    }
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          _buildEditButton(),
          _buildLogoutButton(),
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
                const SizedBox(height: 8),
                _buildFireAuthInfo(),
                const Divider(thickness: 2, color: Colors.black),
                _buildCloudUserInfo(),
                const SizedBox(height: 16),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      child: const Text(
        'LOGOUT',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: logout,
    );
  }

  Widget _buildEditButton() {
    return TextButton(
      child: const Text(
        'EDIT PROFILE',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: edit,
    );
  }

  Widget _buildFireAuthInfo() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Firebase Auth', style: TextStyle(fontSize: 20)),
        ),
        _buildAvatar(url: auth.currentUser?.photoURL),
        Text(auth.currentUser?.displayName ?? 'Anon user'),
        Text(auth.currentUser?.email ?? 'Anon user'),
      ],
    );
  }

  Widget _buildCloudUserInfo() {
    const text = 'Cloud Firestore';
    if (auth.currentUser?.isAnonymous == true) {
      return Column(
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            text,
            style: TextStyle(fontSize: 20),
          ),
        ),
        StreamBuilder<UserModel?>(
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
                  _buildAvatar(url: snapshot.data?.photoURL),
                  Text(snapshot.data?.userName ?? ''),
                  Text(snapshot.data?.email ?? ''),
                  Text(snapshot.data?.gender ?? ''),
                ],
              );
            }
            return const Text('');
          },
        ),
      ],
    );
  }

  Widget _buildAvatar({String? url}) {
    ImageProvider? image;
    Widget icon = const Icon(
      Icons.person_outline_outlined,
      color: Colors.black45,
      size: 50,
    );

    if (url != null && url.isNotEmpty) {
      image = CachedNetworkImageProvider(
        url,
      );
      icon = Container();
    }

    return CircleAvatar(
      radius: 70,
      backgroundColor: kGreyLight,
      backgroundImage: image,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: TextButton(
            child: icon,
            onPressed: null,
          ),
        ),
      ),
    );
  }
}

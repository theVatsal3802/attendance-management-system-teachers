import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../widgets/heading_text.dart';
import '../helpers/space_helpers.dart';
import '../widgets/custom_tab_button.dart';
import './qr_generator_screen.dart';
import './get_student_details.dart';
import './login_screen.dart';

class DashBoardScreen extends StatefulWidget {
  static const routeName = "/dashboard";
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  late StreamSubscription subscription;
  bool isConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
    getConnectivity();
  }

  void showDialogBox() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "No Connection",
            textScaleFactor: 1,
          ),
          content: const Text(
            "Please connect to internet or Wi-Fi",
            textScaleFactor: 1,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  isAlertSet = false;
                });
                isConnected = await InternetConnectionChecker().hasConnection;
                if (!isConnected) {
                  showDialogBox();
                  setState(() {
                    isAlertSet = true;
                  });
                }
              },
              child: const Text(
                "OK",
                textScaleFactor: 1,
              ),
            ),
          ],
        );
      },
    );
  }

  void getConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen(
      (result) async {
        isConnected = await InternetConnectionChecker().hasConnection;
        if (!isConnected && isAlertSet == false) {
          showDialogBox();
          setState(() {
            isAlertSet = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("teachers")
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Welcome",
              textScaleFactor: 1,
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut().then(
                        (_) => Navigator.of(context).pushNamedAndRemoveUntil(
                            LoginScreen.routeName, (route) => false),
                      );
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.6,
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: height,
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        HeadingText(
                          text: "Hello, ${snapshot.data!["name"]}",
                          textSize: 32,
                        ),
                        VerticalSizedBox(height: height * 0.02),
                        CustomTabButton(
                          icon: Icons.add_chart,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                QRGeneratorScreen.routeName,
                                arguments: snapshot.data!["name"]);
                          },
                          child: Text(
                            "Take Attendance",
                            textScaleFactor: 1,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .fontSize,
                            ),
                          ),
                        ),
                        VerticalSizedBox(height: height * 0.05),
                        CustomTabButton(
                          icon: Icons.school,
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(GetStudentDetails.routeName);
                          },
                          child: Text(
                            "View Student Report",
                            textScaleFactor: 1,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

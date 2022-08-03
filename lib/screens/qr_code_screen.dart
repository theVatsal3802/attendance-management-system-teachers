import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import './dashboard_screen.dart';
import '../helpers/space_helpers.dart';
import '../helpers/date_helper.dart';

class QRCodeScreen extends StatelessWidget {
  static const routeName = "qr-code";
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan this QR Code to mark attendance",
          textScaleFactor: 1,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImage(
              data: "${data["subject"]}, ${data["batch"]}, ${data["name"]}",
              backgroundColor: Colors.white,
              size: 250,
            ),
            const VerticalSizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              onPressed: () async {
                String month =
                    DateHelper().setMonth(DateTime.now().month.toString());
                await FirebaseFirestore.instance
                    .collection(data["name"]!)
                    .doc(data["batch"])
                    .collection(
                        "${DateTime.now().day} $month, ${DateTime.now().year}")
                    .doc(data["subject"])
                    .update(
                  {
                    "Attendance Closed at":
                        "${DateTime.now().hour}:${DateTime.now().minute}",
                  },
                ).then(
                  (_) {
                    Navigator.of(context)
                        .pushReplacementNamed(DashBoardScreen.routeName);
                  },
                );
              },
              label: const Text(
                "Complete Attendance",
                textScaleFactor: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

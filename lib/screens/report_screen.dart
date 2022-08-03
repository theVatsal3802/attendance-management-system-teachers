import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helpers/date_helper.dart';
import '../widgets/sub_heading_text.dart';
import './get_student_details.dart';

class ReportScreen extends StatefulWidget {
  final String collegeId;
  final String batch;
  final String date;
  final String subject;
  const ReportScreen(
      {Key? key,
      required this.collegeId,
      required this.batch,
      required this.date,
      required this.subject})
      : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedDate = "";
  late Future<bool> exists;

  Future<bool> checkExistence() async {
    final document = await FirebaseFirestore.instance
        .collection(widget.batch.trim().toUpperCase())
        .doc(widget.collegeId.trim().toLowerCase())
        .collection(widget.date.trim())
        .doc(widget.subject.trim().toUpperCase())
        .get();
    if (!document.exists) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "No Attendance Taken on specified day",
              textScaleFactor: 1,
            ),
            content: const Text(
              "Please change the date and try again",
              textScaleFactor: 1,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      GetStudentDetails.routeName, (route) => false);
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
      return false;
    }
    return true;
  }

  void setDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      String day = date.day.toString();
      String month = DateHelper().setMonth(date.month.toString());
      String year = date.year.toString();
      setState(() {
        selectedDate = "$day $month, $year";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedDate = widget.date;
      exists = checkExistence();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.collegeId,
          textScaleFactor: 1,
        ),
      ),
      body: FutureBuilder<bool>(
          future: exists,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (snapshot.data == false) {
              return const Center();
            }
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(widget.batch.trim().toUpperCase())
                  .doc(widget.collegeId.trim().toLowerCase())
                  .collection(widget.date.trim())
                  .doc(widget.subject.trim().toUpperCase())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        const Text(
                          "An Error Occurred.",
                          textScaleFactor: 1,
                        ),
                        ElevatedButton(
                          onPressed: setDate,
                          child: const Text(
                            "Set Date",
                            textScaleFactor: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (snapshot.data == null) {
                  return Center(
                    child: Column(
                      children: [
                        const Text(
                          "No Attendance Taken on this Day",
                          textScaleFactor: 1,
                        ),
                        ElevatedButton(
                          onPressed: setDate,
                          child: const Text(
                            "Set Date",
                            textScaleFactor: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    height: height,
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ListTile(
                          title: const Text(
                            "Date",
                            textScaleFactor: 1,
                          ),
                          subtitle: Text(
                            selectedDate,
                            textScaleFactor: 1,
                          ),
                          trailing: IconButton(
                            onPressed: setDate,
                            icon: const Icon(
                              Icons.calendar_month,
                            ),
                          ),
                        ),
                        const Divider(),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SubHeadingText(
                                text: "Student Name:",
                                textSize: 20,
                              ),
                              Chip(
                                backgroundColor: snapshot.data!["status"]
                                    ? Colors.green[200]
                                    : Colors.red[200],
                                label: Text(
                                  snapshot.data!["name"],
                                  textScaleFactor: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SubHeadingText(
                                text: "Attendance status:",
                                textSize: 20,
                              ),
                              Chip(
                                backgroundColor: snapshot.data!["status"]
                                    ? Colors.green[200]
                                    : Colors.red[200],
                                label: Text(
                                  snapshot.data!["status"]
                                      ? "Present"
                                      : "Absent",
                                  textScaleFactor: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SubHeadingText(
                                text: "Student Location:",
                                textSize: 20,
                              ),
                              Chip(
                                backgroundColor: snapshot.data!["status"]
                                    ? Colors.green[200]
                                    : Colors.red[200],
                                label: Text(
                                  snapshot.data!["location"],
                                  textScaleFactor: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SubHeadingText(
                                text: "Attendance sent for evaluation at:",
                                textSize: 20,
                              ),
                              Chip(
                                backgroundColor: snapshot.data!["status"]
                                    ? Colors.green[200]
                                    : Colors.red[200],
                                label: Text(
                                  snapshot.data!["marked at"],
                                  textScaleFactor: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}

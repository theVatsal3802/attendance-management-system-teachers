import 'package:flutter/material.dart';

import '../helpers/space_helpers.dart';
import '../widgets/custom_container.dart';
import '../widgets/sub_heading_text.dart';
import '../helpers/date_helper.dart';
import './report_screen.dart';
import './dashboard_screen.dart';

class GetStudentDetails extends StatefulWidget {
  static const routeName = "/get-student";
  const GetStudentDetails({Key? key}) : super(key: key);

  @override
  State<GetStudentDetails> createState() => _GetStudentDetailsState();
}

class _GetStudentDetailsState extends State<GetStudentDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String id = "";
  String selectedDate = "";
  String subject = "";
  String batch = "";

  void setBatch(String id) {
    String branch = "";
    String year = id.substring(0, 4);
    if (id.trim().toLowerCase().contains("kucp")) {
      branch = "CSE";
    } else {
      branch = "ECE";
    }
    setState(() {
      batch = branch + year;
    });
  }

  void setDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    String month = DateHelper().setMonth(date!.month.toString());
    String day = date.day.toString();
    String year = date.year.toString();
    setState(() {
      selectedDate = "$day $month, $year";
    });
  }

  void generateReport() {
    FocusScope.of(context).unfocus();
    bool valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    if (selectedDate.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Date Not Selected",
              textScaleFactor: 1,
            ),
            content: const Text(
              "Please select a date first",
              textScaleFactor: 1,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
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
    _formKey.currentState!.save();
    setBatch(id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ReportScreen(
            subject: subject,
            batch: batch,
            collegeId: id,
            date: selectedDate,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enter student details to see report",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textScaleFactor: 1,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushReplacementNamed(DashBoardScreen.routeName);
            },
            icon: const Icon(Icons.home),
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SubHeadingText(
                        text: "College Id",
                        textSize: 20,
                      ),
                      const VerticalSizedBox(
                        height: 10,
                      ),
                      CustomContainer(
                        icon: Icons.person,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.none,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                              hintText: "Student's College ID"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter College id";
                            } else if (value.trim().length != 12) {
                              return "College ID must be exactly 12 characters in length";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            id = value!;
                          },
                        ),
                      ),
                      const VerticalSizedBox(height: 10),
                      ListTile(
                        title: Text(
                          selectedDate.isEmpty
                              ? "Select Date"
                              : "Selected Date:",
                          textScaleFactor: 1,
                        ),
                        subtitle: Text(
                          selectedDate.isEmpty
                              ? "No Date Selected"
                              : selectedDate,
                          textScaleFactor: 1,
                        ),
                        trailing: IconButton(
                          onPressed: setDate,
                          icon: const Icon(
                            Icons.calendar_month,
                          ),
                        ),
                      ),
                      const SubHeadingText(
                        text: "Subject",
                        textSize: 20,
                      ),
                      const VerticalSizedBox(
                        height: 10,
                      ),
                      CustomContainer(
                        icon: Icons.person,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                              hintText: "Subject you want to see report for"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter subject";
                            } else if (value.trim().length != 6) {
                              return "Subject must be exactly 6 characters in length";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            subject = value!;
                          },
                        ),
                      ),
                      const VerticalSizedBox(height: 20),
                      ElevatedButton(
                        onPressed: generateReport,
                        child: const Text(
                          "Generate Report",
                          textScaleFactor: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_import
import 'dart:ffi';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_web1/database/databaseservice.dart';
import 'package:project_web1/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<HomeScreen> {
  TextEditingController controller = TextEditingController();
  String dropdownValue = "weight";
  String selectedTab = "All";

  // Build tabs for All / Weight / Height
  Widget buildTab(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = text;
          });
        },
        child: Chip(
          elevation: 10,
          backgroundColor: selectedTab == text ? Colors.redAccent : Colors.grey,
          label: Text(
            text,
            style: textStyle(18, Colors.white, FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // Open Add Dialog
  void openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter statesetter) {
              return SizedBox(
                height: 220,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: [
                      Text(
                        "Add",
                        style: textStyle(28, Colors.black, FontWeight.w700),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 125,
                            height: 40,
                            child: TextFormField(
                              controller: controller,
                              style: textStyle(
                                20,
                                Colors.black,
                                FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: dropdownValue == "weight"
                                    ? "In kg"
                                    : "In cm",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DropdownButton(
                            hint: Text(
                              "Choose",
                              style: textStyle(
                                18,
                                Colors.black,
                                FontWeight.w700,
                              ),
                            ),
                            dropdownColor: Colors.grey,
                            onChanged: (value) {
                              statesetter(() {
                                dropdownValue = value.toString();
                              });
                            },
                            value: dropdownValue,
                            items: const [
                              DropdownMenuItem(
                                value: "weight",
                                child: Text("Weight"),
                              ),
                              DropdownMenuItem(
                                value: "height",
                                child: Text("Height"),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      IconButton(
                        iconSize: 50,
                        color: Colors.redAccent,
                        onPressed: () async {
                          if (controller.text.isEmpty) return;
                          await DatabaseService.instance.addActivity({
                            DatabaseService.type: dropdownValue,
                            DatabaseService.date: DateTime.now().toString(),
                            DatabaseService.data: double.parse(controller.text),
                          });
                          controller.clear();
                          setState(() {}); // Refresh the list
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.double_arrow_rounded),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBF5F5),
      floatingActionButton: Chip(
        backgroundColor: Colors.redAccent,
        onDeleted: () => openAddDialog(context),
        deleteIcon: Icon(Icons.add, color: Colors.white, size: 26),
        label: Text("Add", style: textStyle(22, Colors.white, FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            children: [
              Text(
                "Fitify",
                style: textStyle(45, Colors.black, FontWeight.w600),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  children: [
                    buildTab("All"),
                    buildTab("Weight"),
                    buildTab("Height"),
                  ],
                ),
              ),
              FutureBuilder<List<Map<String, Object?>>>(
                future: DatabaseService.instance.getActivities(
                  selectedTab.toLowerCase(),
                ),
                builder: (context, asyncSnapshot) {
                  if (!asyncSnapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final activities = asyncSnapshot.data!;
                  if (activities.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        "No data available",
                        style: textStyle(20, Colors.black, FontWeight.w500),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: activities.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      final id = activity['columid'] as int?;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: ListTile(
                              leading: Image(
                                width: 50,
                                height: 50,
                                image: AssetImage(
                                  activity['type'] == 'weight'
                                      ? 'images/dumble.png'
                                      : 'images/height.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                "${activity['data']} ${activity['type'] == 'weight' ? 'KG' : 'CM'}",
                                style: textStyle(
                                  27,
                                  Colors.black,
                                  FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 28,
                                ),
                                onPressed: () async {
                                  if (id != null) {
                                    await DatabaseService.instance
                                        .deleteActivity(id);
                                    setState(() {}); // Refresh after delete
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

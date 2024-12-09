import 'dart:convert';

import 'package:flutter/material.dart';

class InsuranceForm extends StatefulWidget {
  final Function getDetails;
  final String? subType;
  final String fillDetails;
  final List? fields;
  final bool isView;

  const InsuranceForm(
      {super.key,
      required this.getDetails,
      this.subType,
      this.fields,
      this.fillDetails = '',
      this.isView = false});

  @override
  _InsuranceFormState createState() => _InsuranceFormState();
}

class _InsuranceFormState extends State<InsuranceForm> {
  Map<String, TextEditingController> newValue = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant InsuranceForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subType != oldWidget.subType) {
      _initializeControllers();
    }
  }

  void _initializeControllers() async {
    print("gg");
    Map? data;
    if (widget.fillDetails != '') {
      data = jsonDecode(widget.fillDetails);
    }
    print(widget.fields);
    setState(() {
      newValue.forEach((_, controller) => controller.dispose());
      newValue = {};
      widget.fields!.forEach((field) {
        if (widget.fillDetails != '') {
          newValue[field["field_name"]] =
              TextEditingController(text: data![field["field_name"]]);
        } else {
          newValue[field["field_name"]] = TextEditingController();
        }
      });
    });
    print(newValue);
  }

  @override
  void dispose() {
    newValue.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Map<String, dynamic> endorsementDetails() {
    return <String, dynamic>{
      "new_value": jsonEncode(
        newValue.map((key, controller) => MapEntry(key, controller.text)),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 15,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: widget.fields != null
          ? widget.fields!.map<Widget>((field) {
              // if (field["Type"] == "Text") {
              return Wrap(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      expands: false,
                      enabled: widget.isView == false,
                      controller: newValue[field["field_name"]],
                      onChanged: (value) {
                        widget.getDetails(endorsementDetails());
                      },
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        floatingLabelStyle: const TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(143, 19, 168, 1),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                        isCollapsed: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 8),
                        labelText: field["field_name"],
                        labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(143, 19, 168, 1),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black12, width: 2),
                            borderRadius: BorderRadius.circular(6)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(13, 154, 189, 1), width: 2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        prefixIconColor: MaterialStateColor.resolveWith(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.focused)) {
                            return const Color.fromRGBO(13, 154, 189, 1);
                          }
                          return Colors.grey;
                        }),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter details';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              );
              // } else if (field["Type"] == "Date") {
              //   return Column(
              //     children: [
              //       TextFormField(
              //         enabled: widget.fillDetails == '',
              //         controller: newValue[field["field_name"]],
              //         onChanged: (value) {
              //           widget.getDetails(endorsementDetails());
              //         },
              //         decoration: InputDecoration(
              //           labelText: field["field_name"],
              //           enabledBorder: OutlineInputBorder(
              //               borderSide: const BorderSide(
              //                   color: Colors.black12, width: 2),
              //               borderRadius: BorderRadius.circular(10)),
              //           focusedBorder: OutlineInputBorder(
              //             borderSide: const BorderSide(
              //                 color: Color.fromRGBO(13, 154, 189, 1), width: 2),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           prefixIconColor: MaterialStateColor.resolveWith(
              //               (Set<MaterialState> states) {
              //             if (states.contains(MaterialState.focused)) {
              //               return const Color.fromRGBO(13, 154, 189, 1);
              //             }
              //             return Colors.grey;
              //           }),
              //           border: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10)),
              //         ),
              //         onTap: () async {
              //           FocusScope.of(context).requestFocus(FocusNode());
              //           DateTime? pickedDate = await showDatePicker(
              //             context: context,
              //             initialDate: DateTime.now(),
              //             firstDate: DateTime(2000),
              //             lastDate: DateTime(2101),
              //           );
              //           if (pickedDate != null) {
              //             newValue[field["field_name"]]!.text =
              //                 pickedDate.toLocal().toString().split(' ')[0];
              //             widget.getDetails(endorsementDetails());
              //           }
              //         },
              //       ),
              //       SizedBox(
              //           height:
              //               16), // Replace with CommonFunction.heightGap() if defined
              //     ],
              //   );
              // }
              // return Container();
            }).toList()
          : [SizedBox.shrink()],
    );
  }
}

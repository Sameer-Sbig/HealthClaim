import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  final List<String> items;
  final value;
  final String hintText;
  final onChanged;
  final String label;
  final bool notMandatory;
  final bool view;
  var mandatoryField;
  DropdownWidget(
      {required this.items,
      required this.hintText,
      this.value = '',
      this.onChanged,
      this.label = '',
      this.notMandatory = false,
      this.view = false,
      this.mandatoryField});

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String? selectedBranch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 250,
          // height: 35,
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            // isDense: false,

            decoration: InputDecoration(
              isCollapsed: false,
              isDense: true,
              labelText: widget.label,
              labelStyle: const TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(143, 19, 168, 1),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8),
              focusColor: const Color.fromRGBO(143, 19, 168, 1),
              enabledBorder: OutlineInputBorder(
                  borderSide: widget.mandatoryField == true
                      ? const BorderSide(
                          color: Color.fromARGB(255, 172, 32, 22), width: 2)
                      : const BorderSide(color: Colors.black12, width: 2),
                  borderRadius: BorderRadius.circular(6)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(143, 19, 168, 1), width: 2),
                  borderRadius: BorderRadius.circular(6)),
              border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black12, width: 2),
                  borderRadius: BorderRadius.circular(6)),
            ),
            hint: Text(
              widget.hintText,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),

            items: widget.items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
            validator: (value) {
              if (value == null && widget.notMandatory == false) {
                return '  Please Select ${widget.label}';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,

            onChanged: widget.view == false ? widget.onChanged : null,

            // (value) {
            //   selectedBranch = value;
            // },
            onSaved: (value) {},
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ),
              iconSize: 24,
              iconEnabledColor: const Color.fromRGBO(13, 154, 189, 1),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
            value: widget.value,
          ),
        ),
        const SizedBox(
          height: 14,
        ),
        // widget.mandatoryField == true
        //     ? SizedBox(
        //         width: 250,
        //         child: Text(
        //           'Please select ${widget.label}',
        //           style: const TextStyle(
        //               color: Color.fromARGB(255, 172, 32, 22), fontSize: 10),
        //         ),
        //       )
        //     : const SizedBox.shrink()
      ],
    );
  }
}

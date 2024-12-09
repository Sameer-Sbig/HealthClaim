import 'package:flutter/material.dart';
import 'package:secure_app/commonFunction.dart';

class CustomRadioButton extends StatefulWidget {
  final String text;
  final List<String> options;
  String? groupValue;
  final Function onChanged;

  final bool view;
  CustomRadioButton({
    super.key,
    required this.text,
    required this.options,
    required this.groupValue,
    required this.onChanged,
    this.view = false,
  });

  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Wrap(
        // spacing: 10,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        // runSpacing: 15,
        children: [
          SizedBox(
            // width: MediaQuery.of(context).size.width * 0.35,
            width: 120,
            child: Text(
              '${widget.text}:',
              style: const TextStyle(
                fontSize: 15,
                color: Color.fromRGBO(13, 154, 189, 1),
              ),
            ),
          ),
          // const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 15,
            children: widget.options.map((option) {
              return Wrap(
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 15,
                children: [
                  Radio(
                    activeColor: const Color.fromRGBO(13, 154, 189, 1),
                    value: option,
                    groupValue: widget.groupValue,
                    onChanged: widget.view == false
                        ? (value) {
                            widget.onChanged(value);
                            setState(() {
                              widget.groupValue = value as String;
                            });
                          }
                        : null,
                  ),
                  Text(option),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DatePickerFormField extends StatefulWidget {
  final String labelText;
  final String date;
  final bool disabled;
  var mandatoryField;

  final Function(DateTime?) onChanged;

  DatePickerFormField(
      {Key? key,
      required this.labelText,
      required this.date,
      required this.onChanged,
      this.disabled = false,
      this.mandatoryField})
      : super(key: key ?? ObjectKey(DateTime.now()));

  @override
  _DatePickerFormFieldState createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (widget.disabled) return; // Do nothing if disabled

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onChanged(_selectedDate);
      });
    }
  }

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
          child: InkWell(
            onTap: widget.disabled ? null : () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                isCollapsed: false,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 11, horizontal: 5),
                labelText: widget.labelText,
                labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(143, 19, 168, 1),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
                floatingLabelStyle: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(143, 19, 168, 1),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
                border: OutlineInputBorder(
                  borderSide: widget.disabled
                      ? const BorderSide(
                          color: Color.fromARGB(255, 197, 197, 197),
                        )
                      : const BorderSide(
                          color: Color.fromRGBO(143, 19, 168, 1),
                        ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.date,
                    style: TextStyle(
                        fontSize: 12,
                        color: widget.disabled ? Colors.grey : Colors.black),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 15,
                    color: widget.disabled
                        ? Colors.grey
                        : const Color.fromRGBO(143, 19, 168, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 14,
        ),
        // widget.mandatoryField == true
        //     ? const SizedBox(
        //         width: 250,
        //         child: Text(
        //           '',
        //           style: TextStyle(color: Colors.transparent, fontSize: 10),
        //         ),
        //       )
        //     : const SizedBox.shrink()
      ],
    );
  }
}

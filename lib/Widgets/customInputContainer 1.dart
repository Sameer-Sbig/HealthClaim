import 'package:flutter/material.dart';

class CustomInputContainer extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const CustomInputContainer({
    Key? key,
    this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      // width: double.infinity,

      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color:
                  //  Color.fromRGBO(231, 181, 229, 0.9),
                  Color.fromRGBO(16, 47, 184, 0.123),
              blurRadius: 3.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
              offset: Offset(
                5.0, // Move to right 5  horizontally
                5.0, // Move to bottom 5 Vertically
              ),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                '${title!}:',
                style: const TextStyle(
                  fontSize: 17,
                  color: Color.fromRGBO(143, 19, 168, 1),
                ),
              ),
              const SizedBox(height: 10),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

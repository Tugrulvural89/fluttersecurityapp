import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CopyableText extends StatelessWidget {
  final String text;

  const CopyableText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Text copied to clipboard!'),
              ),
            );
          },
        ),
      ],
    );
  }
}

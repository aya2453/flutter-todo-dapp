import 'package:flutter/material.dart';

class BottomSheetContent extends StatefulWidget {
  final String? defaultName;

  const BottomSheetContent({this.defaultName, Key? key}) : super(key: key);

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Wrap(
        children: [
          Column(children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                  hintText: '新しいタスク',
                  suffixIcon: IconButton(
                    onPressed: () {
                      Navigator.pop(context, _controller.text);
                    },
                    icon: const Icon(Icons.send),
                  )),
            ),
            const SizedBox(height: 8),
          ]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

void showTodoBottomSheet(
    {String? defaultName,
    required BuildContext context,
    required Function(String?) callback}) async {
  String? name = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) =>
          BottomSheetContent(defaultName: defaultName));
  callback(name);
}

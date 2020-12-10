import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final List items;
  final ValueChanged<String> onChange;

  const CustomDropdown({this.controller, this.label, this.items, this.onChange});

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String value;

  @override
  Widget build(BuildContext context) {
    value = widget.controller.text.isNotEmpty ? widget.controller.text : null;

    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(widget.label),
        ),
        value: value,
        icon: Icon(Icons.arrow_drop_down_outlined),
        iconSize: 16,
        elevation: 16,
        underline: Container(
          height: 1,
          color: Colors.grey[500],
        ),
        onChanged: (String newValue) {
          setState(() {
            value = newValue;
            widget.controller.text = newValue;
          });
          if (widget.onChange != null) widget.onChange(widget.controller.text);
        },
        items: widget.items,
      ),
    );
  }
}

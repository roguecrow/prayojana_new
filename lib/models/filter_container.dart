import 'package:flutter/material.dart';

class FilterContainer extends StatefulWidget {
  final String text;
  final Color initialColor;
  final VoidCallback onTap;

  const FilterContainer({super.key, 
    required this.text,
    required this.initialColor,
    required this.onTap,
  });

  @override
  FilterContainerState createState() => FilterContainerState();
}

class FilterContainerState extends State<FilterContainer> {
  late Color containerColor;
  late bool colorChanged;

  @override
  void initState() {
    super.initState();
    containerColor = widget.initialColor;
    colorChanged = false;
  }

  void _changeColor() {
    setState(() {
      if (colorChanged) {
        containerColor = widget.initialColor;
      } else {
        containerColor = Colors.blue; // Change to the desired color
      }
      colorChanged = !colorChanged;
    });
    widget.onTap(); // Call the onTap callback
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeColor,
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: containerColor,
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

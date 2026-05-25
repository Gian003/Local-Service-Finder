import 'package:flutter/material.dart';
class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<CustomSearchBar> createState() => CustomSearchBarState();
}

class CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    // ✅ Wrap with Material to fix TextField ancestor error
    return Material(
      color: Colors.transparent,
      child: buildSearchBar(),
    );
  }

  Widget buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: Colors.grey[400], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onSearch,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: Color.fromRGBO(66, 66, 66, 1),
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.grey[400],
                  fontSize: 15,
                ),
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ),
          // Clear button
          if (widget.controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                widget.controller.clear();
                widget.onClear();
              },
              icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}
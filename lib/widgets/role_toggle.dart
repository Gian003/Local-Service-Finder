import 'package:flutter/material.dart';
import 'package:lsf/global%20variable/colors.dart';

class RoleToggle extends StatelessWidget {
  const RoleToggle({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  final String selectedRole;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(12),
          right: Radius.circular(12),
        ),
      ),
      child: Row(
        children: ['customer', 'worker'].map((role) {
          final isSelected = selectedRole == role;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(role),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    role == 'customer' ? 'Customer' : 'Worker',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

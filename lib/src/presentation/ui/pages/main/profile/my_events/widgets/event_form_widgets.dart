import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/core/helpers/jenix_colors_app.dart';

class EventFormInfoCard extends StatelessWidget {
  final Widget child;
  const EventFormInfoCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2647),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: child,
    );
  }
}

class EventFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final String? validatorMsg;
  final TextInputType? keyboard;
  final bool enabled;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const EventFormTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.validatorMsg,
    this.keyboard,
    this.enabled = true,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboard ?? TextInputType.text,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      validator: validator ??
          (validatorMsg != null
              ? (v) => v == null || v.isEmpty ? validatorMsg : null
              : null),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon:
            icon != null ? Icon(icon, color: const Color(0xFFBE1723)) : null,
        filled: true,
        fillColor: const Color(0xFF0A2647),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBE1723), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class EventFormDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<T> items;
  final void Function(T?) onChanged;
  final String Function(T)? displayLabel;
  final bool enabled;

  const EventFormDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.displayLabel,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: enabled ? onChanged : null,
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF0A2647),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: enabled ? Colors.white70 : Colors.white30),
        filled: true,
        fillColor: enabled ? const Color(0xFF0A2647) : const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: enabled ? Colors.white10 : Colors.white10,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBE1723), width: 1.4),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  displayLabel != null ? displayLabel!(e) : e.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ))
          .toList(),
    );
  }
}

class EventFormDateRangePickerButton extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? finalDate;
  final VoidCallback? onTap;

  const EventFormDateRangePickerButton({
    super.key,
    required this.initialDate,
    required this.finalDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    final startDateStr =
        initialDate != null ? dateFormatter.format(initialDate!) : 'Seleccionar';
    final endDateStr =
        finalDate != null ? dateFormatter.format(finalDate!) : 'Seleccionar';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A2647),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onTap == null
                ? Colors.white10
                : const Color(0xFFBE1723).withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range,
                color: onTap == null ? Colors.white30 : const Color(0xFFBE1723),
                size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rango de Fechas',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$startDateStr - $endDateStr',
                    style: TextStyle(
                      color: onTap == null ? Colors.white30 : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventFormTimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback? onTap;

  const EventFormTimePickerButton({
    super.key,
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A2647),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onTap == null
                ? Colors.white10
                : const Color(0xFFBE1723).withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time,
                    color: onTap == null
                        ? Colors.white30
                        : const Color(0xFFBE1723),
                    size: 16),
                const SizedBox(width: 6),
                Text(
                  time != null ? time!.format(context) : '--:--',
                  style: TextStyle(
                    color: onTap == null ? Colors.white30 : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

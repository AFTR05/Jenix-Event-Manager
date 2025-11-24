import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeTimePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final TimeOfDay? initialStartTime;
  final DateTime? initialEndDate;
  final TimeOfDay? initialEndTime;
  final Function(DateTime startDate, TimeOfDay startTime, DateTime endDate, TimeOfDay endTime) onConfirm;

  const DateRangeTimePicker({
    super.key,
    this.initialStartDate,
    this.initialStartTime,
    this.initialEndDate,
    this.initialEndTime,
    required this.onConfirm,
  });

  @override
  State<DateRangeTimePicker> createState() => _DateRangeTimePickerState();
}

class _DateRangeTimePickerState extends State<DateRangeTimePicker> {
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ?? DateTime.now();
    _startTime = widget.initialStartTime ?? TimeOfDay.now();
    _endDate = widget.initialEndDate ?? DateTime.now().add(const Duration(hours: 1));
    _endTime = widget.initialEndTime ?? TimeOfDay.now().replacing(hour: (TimeOfDay.now().hour + 1) % 24);
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFBE1723),
            onPrimary: Colors.white,
            surface: Color(0xFF2C2C2C),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: const Color(0xFF1A1A1A),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() => _startDate = date);
      // Si la fecha de inicio es mayor a la de fin, igualarla
      if (_startDate.isAfter(_endDate)) {
        _endDate = _startDate.add(const Duration(hours: 1));
      }
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFBE1723),
            onPrimary: Colors.white,
            surface: Color(0xFF2C2C2C),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: const Color(0xFF1A1A1A),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFBE1723),
            onPrimary: Colors.white,
            surface: Color(0xFF2C2C2C),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) {
      setState(() => _startTime = time);
    }
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFBE1723),
            onPrimary: Colors.white,
            surface: Color(0xFF2C2C2C),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) {
      setState(() => _endTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final startTimeStr = _startTime.format(context);
    final endTimeStr = _endTime.format(context);

    return Dialog(
      backgroundColor: const Color(0xFF12263F).withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Seleccionar Rango de Fechas y Horas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // INICIO
            _buildSectionTitle('Fecha y Hora de Inicio'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeButton(
                    label: 'Fecha Inicio',
                    dateStr: dateFormat.format(_startDate),
                    icon: Icons.calendar_today,
                    onTap: _pickStartDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeButton(
                    label: 'Hora Inicio',
                    dateStr: startTimeStr,
                    icon: Icons.access_time,
                    onTap: _pickStartTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Separador visual
            Container(
              height: 2,
              color: Colors.white10,
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),

            const SizedBox(height: 20),

            // FIN
            _buildSectionTitle('Fecha y Hora de Fin'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeButton(
                    label: 'Fecha Fin',
                    dateStr: dateFormat.format(_endDate),
                    icon: Icons.calendar_today,
                    onTap: _pickEndDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeButton(
                    label: 'Hora Fin',
                    dateStr: endTimeStr,
                    icon: Icons.access_time,
                    onTap: _pickEndTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Resumen
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A2647),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBE1723).withOpacity(0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${dateFormat.format(_startDate)} $startTimeStr',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(_endDate)} $endTimeStr',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(_startDate, _startTime, _endDate, _endTime);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE1723),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDateTimeButton({
    required String label,
    required String dateStr,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A2647),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon, color: const Color(0xFFBE1723), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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

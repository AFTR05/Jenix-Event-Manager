import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/campus/campus_form_screen.dart';

final List<Campus> dummyCampusList = [
  Campus(id: '1', name: 'Campus Central', state: 'Abierto', isActive: true, createdAt: DateTime(2023, 6, 12)),
  Campus(id: '2', name: 'Campus Norte', state: 'En mantenimiento', isActive: true, createdAt: DateTime(2024, 2, 18)),
  Campus(id: '3', name: 'Campus Sur', state: 'Cerrado', isActive: false, createdAt: DateTime(2022, 9, 5)),
];

class CampusListScreen extends StatefulWidget {
  const CampusListScreen({super.key});

  @override
  State<CampusListScreen> createState() => _CampusListScreenState();
}

class _CampusListScreenState extends State<CampusListScreen> {
  final dateFormat = DateFormat('dd MMM yyyy');

  void _openForm({Campus? campus}) async {
    final result = await showDialog<Campus>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CampusFormDialog(campus: campus),
    );

    if (result != null) {
      setState(() {
        if (campus == null) {
          dummyCampusList.add(result);
        } else {
          final index = dummyCampusList.indexWhere((c) => c.id == campus.id);
          if (index != -1) dummyCampusList[index] = result;
        }
      });
    }
  }

  void _deleteCampus(Campus campus) {
    setState(() => dummyCampusList.removeWhere((c) => c.id == campus.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Campus "${campus.name}" eliminado'),
        backgroundColor: const Color(0xFFBE1723),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFFBE1723),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          /// Fondo con gradiente institucional
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A2647), Color(0xFF09131E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// Lista de campus
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: dummyCampusList.length,
              itemBuilder: (context, index) {
                final campus = dummyCampusList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12263F).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: campus.state == 'Abierto'
                          ? Colors.greenAccent.withOpacity(0.4)
                          : campus.state == 'Cerrado'
                              ? Colors.redAccent.withOpacity(0.4)
                              : Colors.amberAccent.withOpacity(0.4),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: Icon(Icons.apartment, color: Colors.white.withOpacity(0.8), size: 28),
                    ),
                    title: Text(
                      campus.name,
                      style: const TextStyle(
                        color: Color(0xFFE6EEF5),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Estado: ${campus.state}",
                              style: const TextStyle(color: Color(0xFF9DA9B9))),
                          Text("Creado: ${dateFormat.format(campus.createdAt)}",
                              style: const TextStyle(color: Color(0xFF9DA9B9))),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      color: const Color(0xFF12263F),
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openForm(campus: campus);
                        } else if (value == 'delete') {
                          _deleteCampus(campus);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.white70, size: 18),
                              SizedBox(width: 8),
                              Text("Editar", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Color(0xFFBE1723), size: 18),
                              SizedBox(width: 8),
                              Text("Eliminar", style: TextStyle(color: Color(0xFFBE1723))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

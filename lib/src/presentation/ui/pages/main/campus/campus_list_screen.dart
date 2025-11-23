import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/campus_status_enum.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/appbar/secondary_appbar_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/campus/campus_form_screen.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

// No hard-coded dummy campus list anymore. When offline or on error
// we prefer showing the cached campuses (if any) or an empty list.

class CampusListScreen extends ConsumerStatefulWidget {
  const CampusListScreen({super.key});

  @override
  ConsumerState<CampusListScreen> createState() => _CampusListScreenState();
}

class _CampusListScreenState extends ConsumerState<CampusListScreen> {
  final dateFormat = DateFormat('dd MMM yyyy');
  bool _isLoading = true;
  bool _isProcessing = false;
  List<CampusEntity> _campuses = [];

  @override
  void initState() {
    super.initState();
    _loadCampuses(showLoading: true);
  }

  Future<void> _loadCampuses({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    final controller = ref.read(campusControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';

    print('🔄 Llamando al endpoint de campus...');
    // Llamar directamente al endpoint, sin cache
    final res = await controller.getAllCampuses(token);

    if (mounted) {
      if (res.isRight) {
        print('✅ Recibidos ${res.right.length} campus del backend');
        print('📋 ANTES de actualizar UI: ${_campuses.length} campus');
        for (var i = 0; i < _campuses.length; i++) {
          print(
            '   [ANTES] ${_campuses[i].name} -> ${_campuses[i].state.toText()}',
          );
        }

        for (var campus in res.right) {
          print('   [NUEVO] ${campus.name} -> ${campus.state.toText()}');
        }

        // Forzar rebuild limpiando primero la lista
        setState(() {
          if (showLoading) _isLoading = false;
          _campuses = []; // Limpiar primero
        });
        // Luego actualizar con los nuevos datos
        setState(() {
          _campuses = List<CampusEntity>.from(res.right); // Crear nueva lista
        });

        print('✅ DESPUÉS de setState: ${_campuses.length} campus en UI');
        for (var i = 0; i < _campuses.length; i++) {
          print(
            '   [UI] ${_campuses[i].name} -> ${_campuses[i].state.toText()}',
          );
        }
      } else {
        print('❌ Error al cargar campuses: ${res.left}');
        setState(() {
          if (showLoading) _isLoading = false;
        });
      }
    }
  }

  void _setProcessing(bool processing) {
    if (mounted) {
      setState(() => _isProcessing = processing);
    }
  }

  String _displayName(CampusStatusEnum s) {
    switch (s) {
      case CampusStatusEnum.abierto:
        return 'Abierto';
      case CampusStatusEnum.mantenimiento:
        return 'En mantenimiento';
      case CampusStatusEnum.cerrado:
        return 'Cerrado';
      // All enum cases handled above.
    }
  }

  void _openForm({CampusEntity? campus}) async {
    final result = await showDialog<CampusEntity>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CampusFormDialog(campus: campus),
    );
    if (result == null) return;

    _setProcessing(true);
    final controller = ref.read(campusControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';

    try {
      if (campus == null) {
        // Create
        print('🆕 Creando campus: ${result.name}');
        final res = await controller.createCampus(
          result.name,
          result.state,
          token,
        );
        if (res.isRight) {
          print('✅ Campus creado: ${res.right.name} (ID: ${res.right.id})');
          // Pequeño delay para asegurar que el backend se actualice
          await Future.delayed(const Duration(milliseconds: 300));
          await _loadCampuses(); // Recargar TODA la lista desde el backend
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Campus creado exitosamente'),
                backgroundColor: Color(0xFF2E7D32),
              ),
            );
          }
        } else {
          print('❌ Error al crear campus: ${res.left}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al crear campus'),
                backgroundColor: Color(0xFFBE1723),
              ),
            );
          }
        }
      } else {
        // Update
        print('✏️ Actualizando campus: ${campus.id}');
        final res = await controller.updateCampus(
          campus.id,
          result.name,
          result.state,
          result.isActive,
          token,
        );
        if (res.isRight) {
          print('✅ Campus actualizado: ${campus.id}');
          // Pequeño delay para asegurar que el backend se actualice
          await Future.delayed(const Duration(milliseconds: 300));
          await _loadCampuses(); // Recargar TODA la lista desde el backend
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Campus actualizado exitosamente'),
                backgroundColor: Color(0xFF1976D2),
              ),
            );
          }
        } else {
          print('❌ Error al actualizar campus: ${res.left}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al actualizar campus'),
                backgroundColor: Color(0xFFBE1723),
              ),
            );
          }
        }
      }
    } finally {
      _setProcessing(false);
    }
  }

  void _deleteCampus(CampusEntity campus) async {
    // Delegate deletion to controller which will update its cache on success.
    _setProcessing(true);
    final controller = ref.read(campusControllerProvider);
    final user = ref.read(loginProviderProvider);
    final token = user?.accessToken ?? '';

    try {
      print('🗑️ Eliminando campus: ${campus.id}');
      final res = await controller.deleteCampus(campus.id, token);

      if (res.isRight && res.right == true) {
        print('✅ Campus eliminado: ${campus.id}');
        // Pequeño delay para asegurar que el backend se actualice
        await Future.delayed(const Duration(milliseconds: 300));
        await _loadCampuses(); // Recargar TODA la lista desde el backend
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Campus "${campus.name}" eliminado exitosamente'),
              backgroundColor: const Color(0xFFBE1723),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        print('❌ Error al eliminar campus: ${res.left}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar campus'),
              backgroundColor: Color(0xFFBE1723),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      _setProcessing(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),
      appBar: SecondaryAppbarWidget(title: 'Gestion de Sedes'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : () => _openForm(),
        backgroundColor: _isProcessing ? Colors.grey : const Color(0xFFBE1723),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _campuses.isEmpty
                ? const Center(
                    child: Text(
                      'No hay campus disponibles',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : _buildListView(_campuses),
          ),

          /// Overlay de carga durante operaciones (crear/actualizar/eliminar)
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFBE1723),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Procesando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView(List<CampusEntity> list) {
    return ListView.builder(
      key: ValueKey(
        'campus_list_${list.length}_${DateTime.now().millisecondsSinceEpoch}',
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final campus = list[index];
        return Container(
          key: ValueKey(
            'campus_${campus.id}_${campus.state.toText()}_${campus.name}',
          ),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF12263F).withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: campus.state == CampusStatusEnum.abierto
                  ? Colors.greenAccent.withOpacity(0.4)
                  : campus.state == CampusStatusEnum.cerrado
                  ? Colors.redAccent.withOpacity(0.4)
                  : Colors.amberAccent.withOpacity(0.4),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: Icon(
                Icons.apartment,
                color: Colors.white.withOpacity(0.8),
                size: 28,
              ),
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
                  Text(
                    "Estado: ${_displayName(campus.state)}",
                    style: const TextStyle(color: Color(0xFF9DA9B9)),
                  ),
                  Text(
                    "Creado: ${dateFormat.format(campus.createdAt)}",
                    style: const TextStyle(color: Color(0xFF9DA9B9)),
                  ),
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
                      Text(
                        "Eliminar",
                        style: TextStyle(color: Color(0xFFBE1723)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

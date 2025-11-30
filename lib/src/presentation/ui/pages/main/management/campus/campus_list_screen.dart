import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/campus_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/campus_status_enum.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/appbar/secondary_appbar_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/management/campus/campus_form_screen.dart';
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

  double _getResponsiveFontSize(double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.9;
    if (screenWidth < 600) return baseFontSize;
    if (screenWidth < 900) return baseFontSize * 1.15;
    return baseFontSize * 1.3;
  }

  double _getResponsiveDimension(double baseDimension) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseDimension * 0.9;
    if (screenWidth < 600) return baseDimension;
    if (screenWidth < 900) return baseDimension * 1.15;
    return baseDimension * 1.3;
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C1C2C) : Colors.white,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0A2647), const Color(0xFF09131E)]
                    : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// Lista de campus
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.white : const Color(0xFF1976D2),
                      ),
                    ),
                  )
                : _campuses.isEmpty
                ? Center(
                    child: Text(
                      'No hay campus disponibles',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: _getResponsiveFontSize(14),
                      ),
                    ),
                  )
                : _buildListView(_campuses),
          ),

          /// Overlay de carga durante operaciones (crear/actualizar/eliminar)
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFBE1723),
                      ),
                    ),
                    SizedBox(height: _getResponsiveDimension(16)),
                    Text(
                      'Procesando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getResponsiveFontSize(16),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          margin: EdgeInsets.only(bottom: _getResponsiveDimension(16)),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12263F).withOpacity(0.9) : Colors.white.withOpacity(0.9),
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
              backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              child: Icon(
                Icons.apartment,
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54,
                size: _getResponsiveDimension(28),
              ),
            ),
            title: Text(
              campus.name,
              style: TextStyle(
                color: isDark ? const Color(0xFFE6EEF5) : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: _getResponsiveFontSize(18),
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: _getResponsiveDimension(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Estado: ${_displayName(campus.state)}",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF9DA9B9) : Colors.black54,
                      fontSize: _getResponsiveFontSize(12),
                    ),
                  ),
                  Text(
                    "Creado: ${dateFormat.format(campus.createdAt)}",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF9DA9B9) : Colors.black54,
                      fontSize: _getResponsiveFontSize(12),
                    ),
                  ),
                ],
              ),
            ),
            trailing: PopupMenuButton<String>(
              color: isDark ? const Color(0xFF12263F) : Colors.white,
              icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.black54),
              onSelected: (value) {
                if (value == 'edit') {
                  _openForm(campus: campus);
                } else if (value == 'delete') {
                  _deleteCampus(campus);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: isDark ? Colors.white70 : Colors.black54, size: 18),
                      const SizedBox(width: 8),
                      Text("Editar", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Color(0xFFBE1723), size: 18),
                      const SizedBox(width: 8),
                      const Text(
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

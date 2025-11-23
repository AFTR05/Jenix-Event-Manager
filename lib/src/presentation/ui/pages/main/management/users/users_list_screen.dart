import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/role_enum.dart';
import 'package:jenix_event_manager/src/presentation/ui/custom_widgets/appbar/secondary_appbar_widget.dart';
import 'package:jenix_event_manager/src/presentation/ui/pages/main/management/users/users_form_screen.dart';
import 'package:jenix_event_manager/src/inject/riverpod_presentation.dart';
import 'package:jenix_event_manager/src/inject/states_providers/login_provider.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  final dateFormat = DateFormat('dd MMM yyyy');
  bool _isLoading = true;
  bool _isProcessing = false;
  List<UserEntity> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    _setProcessing(false);
    setState(() => _isLoading = true);

    final usersController = ref.read(usersControllerProvider);
    final userAuth = ref.read(loginProviderProvider);
    final token = userAuth?.accessToken ?? '';
    final currentUserId = userAuth?.id ?? '';
    final currentUserEmail = userAuth?.email ?? '';

    try {
      print('📤 Cargando lista de usuarios...');
      print('   Usuario autenticado: ID=$currentUserId, Email=$currentUserEmail');
      final res = await usersController.getAllUsers(
        page: 1,
        limit: 100,
        token: token,
      );

      if (res.isRight) {
        print('   Total usuarios del backend: ${res.right.length}');
        
        // Filtrar el usuario autenticado por ID o por email
        final filteredUsers = res.right
            .where((u) => u.id != currentUserId)
            .toList();
        
        print('✅ Usuarios cargados: ${filteredUsers.length} (excluido usuario autenticado)');
        setState(() {
          _users = filteredUsers;
          _isLoading = false;
        });
      } else {
        print('❌ Error al cargar usuarios: ${res.left}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Exception al cargar usuarios: $e');
      setState(() => _isLoading = false);
    }
  }

  void _setProcessing(bool processing) {
    if (mounted) {
      setState(() => _isProcessing = processing);
    }
  }

  void _openForm() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const UserFormDialog(),
    );

    if (result == true) {
      // Recargar lista de usuarios después de crear
      _loadUsers();
    }
  }

  void _editUser(UserEntity user) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => UserFormDialog(userToEdit: user),
    );

    if (result == true) {
      // Recargar lista de usuarios después de editar
      _loadUsers();
    }
  }

  void _deleteUser(UserEntity user) async {
    _setProcessing(true);
    final usersController = ref.read(usersControllerProvider);
    final userAuth = ref.read(loginProviderProvider);
    final token = userAuth?.accessToken ?? '';

    try {
      print('🗑️ Eliminando usuario: ${user.id}');
      final res = await usersController.deleteUser(
        userId: user.id,
        token: token,
      );

      if (res.isRight && res.right == true) {
        print('✅ Usuario eliminado: ${user.id}');
        await Future.delayed(const Duration(milliseconds: 300));
        // Recargar lista después de eliminar
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Usuario "${user.email}" eliminado exitosamente'),
            backgroundColor: const Color(0xFFBE1723),
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        print('❌ Error al eliminar usuario: ${res.left}');
        _setProcessing(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error al eliminar usuario'),
            backgroundColor: Color(0xFFBE1723),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } finally {
      if (mounted && _isProcessing) {
        _setProcessing(false);
      }
    }
  }

  void _promoteToOrganizer(UserEntity user) async {
    _setProcessing(true);
    final usersController = ref.read(usersControllerProvider);
    final userAuth = ref.read(loginProviderProvider);
    final token = userAuth?.accessToken ?? '';

    try {
      print('⬆️ Promoviendo usuario a organizador: ${user.email}');
      final res = await usersController.promoteToOrganizer(
        email: user.email,
        token: token,
      );

      if (res.isRight) {
        print('✅ Usuario promovido a organizador: ${user.email}');
        await Future.delayed(const Duration(milliseconds: 300));
        // Recargar lista después de promover
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Usuario "${user.email}" promovido a organizador'),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        print('❌ Error al promover usuario: ${res.left}');
        _setProcessing(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error al promover usuario'),
            backgroundColor: Color(0xFFBE1723),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } finally {
      if (mounted && _isProcessing) {
        _setProcessing(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C2C),
      appBar: SecondaryAppbarWidget(title: 'Gestion de Usuarios'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _openForm,
        backgroundColor: _isProcessing ? Colors.grey : const Color(0xFFBE1723),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Fondo institucional
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A2647), Color(0xFF09131E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Lista de usuarios
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay usuarios disponibles',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : _buildListView(_users),
          ),

          /// Overlay de carga durante operaciones
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE1723)),
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

  Widget _buildListView(List<UserEntity> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final user = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF12263F).withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white10,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: Icon(Icons.person, color: Colors.white.withOpacity(0.8), size: 28),
            ),
            title: Text(
              user.name,
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
                  Text("Correo: ${user.email}", style: const TextStyle(color: Color(0xFF9DA9B9))),
                  Text("Teléfono: ${user.phone}", style: const TextStyle(color: Color(0xFF9DA9B9))),
                  Text("Rol: ${user.role.displayName}", style: const TextStyle(color: Color(0xFF9DA9B9))),
                ],
              ),
            ),
            trailing: PopupMenuButton<String>(
              color: const Color(0xFF12263F),
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onSelected: (value) {
                if (value == 'edit') {
                  _editUser(user);
                } else if (value == 'promote') {
                  _promoteToOrganizer(user);
                } else if (value == 'delete') {
                  _deleteUser(user);
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
                PopupMenuItem(
                  value: user.role == RoleEnum.organizer ? null : 'promote',
                  enabled: user.role != RoleEnum.organizer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: user.role == RoleEnum.organizer ? Colors.grey : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.role == RoleEnum.organizer ? "Ya es organizador" : "Promover",
                        style: TextStyle(
                          color: user.role == RoleEnum.organizer ? Colors.grey : Colors.white,
                        ),
                      ),
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
    );
  }
}

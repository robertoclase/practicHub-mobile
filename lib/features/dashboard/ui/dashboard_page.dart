import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../seguimientos/ui/seguimientos_page.dart';
import '../../partes/ui/partes_page.dart';
import '../../empresas/ui/empresas_page.dart';

/// Página principal del dashboard
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          // Si no está autenticado, redirigir a login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: _buildBody(state),
          bottomNavigationBar: _buildBottomNav(state),
        );
      },
    );
  }

  Widget _buildBody(Authenticated state) {
    // Mostrar contenido según índice seleccionado y rol
    return _getPageForIndex(_selectedIndex, state.role);
  }

  Widget _getPageForIndex(int index, String role) {
    if (index == 0) {
      // Inicio - Pantalla de bienvenida
      return _buildHomePage(role);
    }

    if (role == 'alumno') {
      switch (index) {
        case 1:
          return const SeguimientosPage();
        case 2:
          return const PartesPage();
        case 3:
          return const EmpresasPage();
        default:
          return _buildHomePage(role);
      }
    } else if (role == 'profesor') {
      switch (index) {
        case 1:
          return const SeguimientosPage();
        case 2:
          return const PartesPage();
        case 3:
          return _buildPlaceholder('Crear Valoraciones', Icons.star);
        default:
          return _buildHomePage(role);
      }
    } else if (role == 'empresa') {
      switch (index) {
        case 1:
          return const SeguimientosPage();
        case 2:
          return const PartesPage();
        default:
          return _buildHomePage(role);
      }
    }

    return _buildHomePage(role);
  }

  Widget _buildHomePage(String role) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) return const SizedBox.shrink();

        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle(0, role)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Header con gradiente
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              _getRoleIcon(role),
                              size: 32,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola!',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white70,
                                      ),
                                ),
                                Text(
                                  state.user?.name ?? state.empresa?['nombre'] ?? 'Usuario',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRoleLabel(state.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Accesos rápidos
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accesos rápidos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickAccessGrid(role),
                    const SizedBox(height: 24),
                    Text(
                      'Información',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(role),
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

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Authenticated state) {
    final items = _getNavItems(state.role);

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey[600],
      items: items,
    );
  }

  String _getAppBarTitle(int index, String role) {
    if (index == 0) return 'PracticHub';

    if (role == 'alumno') {
      switch (index) {
        case 1:
          return 'Mis Prácticas';
        case 2:
          return 'Partes Diarios';
        case 3:
          return 'Empresas';
        default:
          return 'PracticHub';
      }
    } else if (role == 'profesor') {
      switch (index) {
        case 1:
          return 'Seguimientos';
        case 2:
          return 'Validar Partes';
        case 3:
          return 'Valoraciones';
        default:
          return 'PracticHub';
      }
    } else if (role == 'empresa') {
      switch (index) {
        case 1:
          return 'Alumnos';
        case 2:
          return 'Validar Partes';
        default:
          return 'PracticHub';
      }
    }

    return 'PracticHub';
  }

  List<BottomNavigationBarItem> _getNavItems(String role) {
    if (role == 'alumno') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business_center),
          label: 'Prácticas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Partes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Empresas',
        ),
      ];
    } else if (role == 'profesor') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Alumnos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_box),
          label: 'Validar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Valorar',
        ),
      ];
    } else if (role == 'empresa') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Alumnos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_box),
          label: 'Validar',
        ),
      ];
    }

    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Inicio',
      ),
    ];
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'alumno':
        return 'Alumno';
      case 'profesor':
        return 'Profesor';
      case 'empresa':
        return 'Empresa';
      case 'admin':
        return 'Administrador';
      default:
        return role;
    }
  }

  String _getWelcomeMessage(String role) {
    switch (role) {
      case 'alumno':
        return 'Gestiona tus prácticas empresariales, partes diarios y consulta tus valoraciones.';
      case 'profesor':
        return 'Supervisa a tus alumnos, valida partes diarios y realiza valoraciones.';
      case 'empresa':
        return 'Gestiona los alumnos en prácticas y valida sus partes diarios.';
      default:
        return 'Bienvenido a PracticHub';
    }
  }

  String _getFeaturesList(String role) {
    switch (role) {
      case 'alumno':
        return '• Ver mis prácticas\n• Crear partes diarios\n• Buscar empresas\n• Ver valoraciones';
      case 'profesor':
        return '• Ver seguimientos\n• Validar partes\n• Crear valoraciones\n• Gestionar alumnos';
      case 'empresa':
        return '• Ver alumnos\n• Validar partes diarios\n• Consultar seguimientos';
      default:
        return '';
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'alumno':
        return Icons.school;
      case 'profesor':
        return Icons.person;
      case 'empresa':
        return Icons.business;
      default:
        return Icons.person;
    }
  }

  Widget _buildQuickAccessGrid(String role) {
    final items = _getQuickAccessItems(role);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _QuickAccessCard(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          color: item['color'] as Color,
          onTap: () {
            setState(() {
              _selectedIndex = item['index'] as int;
            });
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getQuickAccessItems(String role) {
    if (role == 'alumno') {
      return [
        {
          'icon': Icons.business_center,
          'title': 'Mis Prácticas',
          'color': Colors.blue,
          'index': 1,
        },
        {
          'icon': Icons.description,
          'title': 'Partes Diarios',
          'color': Colors.green,
          'index': 2,
        },
        {
          'icon': Icons.business,
          'title': 'Empresas',
          'color': Colors.orange,
          'index': 3,
        },
      ];
    } else if (role == 'profesor') {
      return [
        {
          'icon': Icons.people,
          'title': 'Alumnos',
          'color': Colors.blue,
          'index': 1,
        },
        {
          'icon': Icons.check_box,
          'title': 'Validar Partes',
          'color': Colors.green,
          'index': 2,
        },
        {
          'icon': Icons.star,
          'title': 'Valoraciones',
          'color': Colors.amber,
          'index': 3,
        },
      ];
    } else if (role == 'empresa') {
      return [
        {
          'icon': Icons.school,
          'title': 'Alumnos',
          'color': Colors.blue,
          'index': 1,
        },
        {
          'icon': Icons.check_box,
          'title': 'Validar Partes',
          'color': Colors.green,
          'index': 2,
        },
      ];
    }
    return [];
  }

  Widget _buildInfoCard(String role) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Sobre PracticHub',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getWelcomeMessage(role),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Funcionalidades disponibles:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _getFeaturesList(role),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

/// Widget para tarjeta de acceso rápido
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

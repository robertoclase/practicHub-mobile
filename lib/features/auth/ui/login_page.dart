import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Página de login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _userType = 'user'; // 'user' o 'empresa'
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              userType: _userType,
            ),
          );
    }
  }

  /// Toast de error tipo notificación flotante con icono contextual
  void _showErrorToast(BuildContext context, String message) {
    final lower = message.toLowerCase();

    IconData icon;
    String title;
    if (lower.contains('correo') || lower.contains('no existe') || lower.contains('cuenta')) {
      icon = Icons.person_off_outlined;
      title = 'Usuario no encontrado';
    } else if (lower.contains('contraseña') || lower.contains('contrase')) {
      icon = Icons.lock_outline;
      title = 'Contraseña incorrecta';
    } else if (lower.contains('inactiv')) {
      icon = Icons.block_outlined;
      title = 'Cuenta inactiva';
    } else if (lower.contains('administrador') || lower.contains('admin')) {
      icon = Icons.admin_panel_settings_outlined;
      title = 'Acceso no permitido';
    } else if (lower.contains('servidor') || lower.contains('internet') || lower.contains('conexión')) {
      icon = Icons.wifi_off_outlined;
      title = 'Sin conexión';
    } else {
      icon = Icons.error_outline;
      title = 'Error de acceso';
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 5),
          content: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B1B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.errorColor.withOpacity(0.6), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.errorColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _showErrorToast(context, state.message);
          } else if (state is Authenticated) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      SvgPicture.asset(
                        'assets/images/logo_practichub.svg',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 16),

                      //Título
                      Text(
                        'PracticHub',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestión de Prácticas Empresariales',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Panel informativo de credenciales
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Credenciales de prueba:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildCredentialInfo('Alumno', 'juan.garcia@alumno.com'),
                            _buildCredentialInfo('Profesor', 'ana.martinez@iestech.es'),
                            _buildCredentialInfo('Empresa', 'contacto@techsolutions.com'),
                            const SizedBox(height: 4),
                            Text(
                              'Contraseña para todos: password',
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Selector de tipo de usuario
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildUserTypeButton(
                                'Alumno/Profesor',
                                'user',
                                Icons.school,
                              ),
                            ),
                            Expanded(
                              child: _buildUserTypeButton(
                                'Empresa',
                                'empresa',
                                Icons.business,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email
                      CustomTextField(
                        label: 'Email',
                        hint: 'tu@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                        validator: Validators.validateEmail,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      CustomTextField(
                        label: 'Contraseña',
                        hint: '•••••••',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: Validators.validatePassword,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),

                      // Botón de login
                      CustomButton(
                        text: 'Iniciar Sesión',
                        onPressed: isLoading ? null : _handleLogin,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Link a registro
                      if (_userType == 'user')
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.of(context).pushNamed('/register');
                                },
                          child: const Text('¿No tienes cuenta? Regístrate'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserTypeButton(String label, String type, IconData icon) {
    final isSelected = _userType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _userType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialInfo(String role, String email) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '$role: $email',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black87,
        ),
      ),
    );
  }
}

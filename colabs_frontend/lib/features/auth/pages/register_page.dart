import 'package:colabs_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:colabs_frontend/features/auth/bloc/auth_event.dart';
import 'package:colabs_frontend/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey          = GlobalKey<FormState>();
  final _nameCtrl         = TextEditingController();
  final _lastNameCtrl     = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          email: _emailCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          password: _passwordCtrl.text,
          phoneNumber: _phoneCtrl.text.trim()
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state){
        if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical:   AppSizes.paddingXL,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // Logo placeholder
                Container(
                  width:  80,
                  height: 80,
                  decoration: BoxDecoration(
                    color:        AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  ),
                  child: const Icon(
                    Icons.handshake_outlined,
                    color: AppColors.primary,
                    size:  40,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),

                // Título y subtítulo
                Text(
                  AppStrings.registerTitle,
                  style: const TextStyle(
                    color:      AppColors.primary,
                    fontSize:   AppSizes.fontXXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXS),
                Text(
                  AppStrings.registerSubtitle,
                  style: const TextStyle(
                    color:    AppColors.textSecondary,
                    fontSize: AppSizes.fontM,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),

                // Nombre y apellido en fila
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          hintText:   AppStrings.name,
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Requerido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameCtrl,
                        decoration: const InputDecoration(
                          hintText:   AppStrings.lastName,
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Requerido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingM),

                // Email
                TextFormField(
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText:   AppStrings.email,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa tu email';
                    if (!value.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingM),

                // Teléfono
                TextFormField(
                  controller:   _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText:   AppStrings.phoneNumber,
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa tu teléfono';
                    if (value.length < 9) return 'Teléfono inválido';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingM),

                // Contraseña
                TextFormField(
                  controller:  _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText:   AppStrings.password,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                    if (value.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingM),

                // Confirmar contraseña
                TextFormField(
                  controller:  _confirmPassCtrl,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText:   AppStrings.confirmPassword,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
                    if (value != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingXL),

                // Botón registrarse
                ElevatedButton(
                  onPressed: _onRegister,
                  child: const Text(
                    AppStrings.registerButton,
                    style: TextStyle(
                      color:      AppColors.white,
                      fontSize:   AppSizes.fontL,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),

                // Ir a login
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRouter.login,
                  ),
                  child: const Text(
                    AppStrings.alreadyHaveAccount,
                    style: TextStyle(
                      color:      AppColors.primary,
                      fontSize:   AppSizes.fontM,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),

                // Divisor continuar con
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.textSecondary.withOpacity(0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                      ),
                      child: const Text(
                        AppStrings.continueWith,
                        style: TextStyle(
                          color:    AppColors.textSecondary,
                          fontSize: AppSizes.fontM,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.textSecondary.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingL),

                // Botones sociales
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Image.asset(
                        'assets/icons/icon_logo.png',
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingL),
                    InkWell(
                      onTap: () {},
                      child: const Icon(
                        Icons.apple,
                        size:  35,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingXL),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }
}
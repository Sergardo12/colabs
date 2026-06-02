import 'package:colabs_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:colabs_frontend/features/auth/bloc/auth_event.dart';
import 'package:colabs_frontend/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
  if (_formKey.currentState!.validate()) {
    context.read<AuthBloc>().add(
      LoginRequested(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }
}

  @override
Widget build(BuildContext context) {
  return BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
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
                  AppStrings.loginTitle,
                  style: const TextStyle(
                    color:      AppColors.primary,
                    fontSize:   AppSizes.fontXXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXS),
                Text(
                  AppStrings.loginSubtitle,
                  style: const TextStyle(
                    color:    AppColors.textSecondary,
                    fontSize: AppSizes.fontM,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXXL),

                // Campo email
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

                // Campo contraseña
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
                const SizedBox(height: AppSizes.paddingXS),

                // ¿Olvidaste tu contraseña?
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      AppStrings.forgotPassword,
                      style: TextStyle(
                        color:    AppColors.primary,
                        fontSize: AppSizes.fontM,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),

                // Botón iniciar sesión
                ElevatedButton(
                  onPressed: _onLogin,
                  child: const Text(
                    AppStrings.loginButton,
                    style: TextStyle(
                      color:      AppColors.white,
                      fontSize:   AppSizes.fontL,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),

                // Ir a registro
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRouter.register,
                  ),
                  child: const Text(
                    AppStrings.createAccount,
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
                        'assets/icons/icon_logo_neutral_c.png',
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
    ),
  );
  }
}
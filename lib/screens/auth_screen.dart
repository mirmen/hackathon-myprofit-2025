import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';
import '../widgets/role_selection_dialog.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      if (_isLogin) {
        await authProvider.signIn(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await authProvider.signUp(
          _emailController.text,
          _passwordController.text,
        );
      }

      if (authProvider.currentUser != null) {
        final userProvider = context.read<UserProvider>();
        await userProvider.loadUserProfile();

        // Check user role and navigate accordingly
        final user = userProvider.currentUser;
        if (user != null) {
          if (user.role == 'admin') {
            // Show role selection dialog for admin users
            final selectedRole = await showDialog<String>(
              context: context,
              builder: (context) => RoleSelectionDialog(userName: user.name),
            );

            if (selectedRole == 'admin') {
              // Navigate to admin panel
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/admin',
                (route) => false,
              );
            } else {
              // Navigate to main screen (regular user mode)
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          } else {
            // Regular user - navigate to main screen
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        } else {
          // Fallback navigation
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: ResponsiveUtils.responsiveIconSize(context, 20),
            ),
            SizedBox(width: ResponsiveUtils.responsiveSize(context, 8)),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.montserrat(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveUtils.responsiveBorderRadius(context, 12),
        ),
        behavior: SnackBarBehavior.floating,
        margin: ResponsiveUtils.getResponsiveMargin(context, all: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: ResponsiveUtils.getResponsivePadding(
              context,
              horizontal: 24,
              vertical: 40,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildHeader(),
                      SizedBox(
                        height: ResponsiveUtils.responsivePadding(context, 48),
                      ),
                      _buildAuthForm(),
                      SizedBox(
                        height: ResponsiveUtils.responsivePadding(context, 32),
                      ),
                      _buildSubmitButton(),
                      SizedBox(
                        height: ResponsiveUtils.responsivePadding(context, 24),
                      ),
                      _buildToggleButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          // Removed GestureDetector
          padding: ResponsiveUtils.getResponsivePadding(context, all: 24),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.coffee, size: 60, color: AppColors.primary),
        ),
        SizedBox(height: ResponsiveUtils.responsivePadding(context, 24)),
        Text(
          'кофебук',
          style: GoogleFonts.montserrat(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 36),
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: ResponsiveUtils.responsivePadding(context, 8)),
        Text(
          _isLogin ? 'Добро пожаловать обратно!' : 'Создайте свой аккаунт',
          style: GoogleFonts.montserrat(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
            fontWeight: FontWeight.w400,
            color: AppColors.textLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    return Column(
      children: [
        if (!_isLogin) ...[
          _buildTextField(
            controller: _nameController,
            label: 'Имя',
            icon: Icons.person_outline,
            validator: (value) {
              if (!_isLogin && (value == null || value.isEmpty)) {
                return 'Введите имя';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
        ],
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите email';
            }
            if (!value.contains('@')) {
              return 'Введите корректный email';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        _buildTextField(
          controller: _passwordController,
          label: 'Пароль',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textLight,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите пароль';
            }
            if (value.length < 6) {
              return 'Пароль должен содержать минимум 6 символов';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: GoogleFonts.montserrat(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.textLight),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: ResponsiveUtils.getResponsivePadding(
            context,
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: GoogleFonts.montserrat(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isLogin ? 'ВОЙТИ' : 'СОЗДАТЬ АККАУНТ',
                style: GoogleFonts.montserrat(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _isLogin = !_isLogin;
            });
          },
          child: RichText(
            text: TextSpan(
              text: _isLogin ? 'Нет аккаунта? ' : 'Уже есть аккаунт? ',
              style: GoogleFonts.montserrat(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
              ),
              children: [
                TextSpan(
                  text: _isLogin ? 'Создать' : 'Войти',
                  style: GoogleFonts.montserrat(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

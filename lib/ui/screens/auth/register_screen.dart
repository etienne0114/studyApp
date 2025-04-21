// lib/ui/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_scheduler/services/auth_service.dart';
import 'package:study_scheduler/ui/screens/home/home_screen.dart';
import 'package:study_scheduler/ui/widgets/custom_button.dart';
import 'package:study_scheduler/ui/widgets/custom_textfield.dart';
import 'package:study_scheduler/constants/app_colors.dart';
import 'package:study_scheduler/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (success) {
        if (!mounted) return;
        // Navigate to home screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = authService.errorMessage ?? 'Failed to register';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App logo/icon
                const Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                
                // App name
                const Text(
                  'Join Study Scheduler',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  'Create your account to start planning',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 24),
                
                // Name field
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.required('Name is required'),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                
                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.compose([
                    Validators.required('Email is required'),
                    Validators.email('Enter a valid email address'),
                  ]),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                
                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey[600],
                    ),
                  ),
                  validator: Validators.compose([
                    Validators.required('Password is required'),
                    Validators.minLength(6, 'Password must be at least 6 characters'),
                  ]),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                
                // Confirm password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    child: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey[600],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 32),
                
                // Register button
                CustomButton(
                  text: 'Register',
                  onPressed: _isLoading ? null : _register,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
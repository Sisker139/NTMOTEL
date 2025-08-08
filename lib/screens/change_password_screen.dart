// lib/screens/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:ntmotel/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
        // Lỗi sẽ được hiển thị tự động qua Provider
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPasswordField(
                    controller: _oldPasswordController,
                    label: 'Mật khẩu cũ',
                    icon: Icons.lock_outline,
                    isObscure: !_oldPasswordVisible,
                    onToggleVisibility: () => setState(() => _oldPasswordVisible = !_oldPasswordVisible),
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'Mật khẩu mới',
                    icon: Icons.lock_outline,
                    isObscure: !_newPasswordVisible,
                    onToggleVisibility: () => setState(() => _newPasswordVisible = !_newPasswordVisible),
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Xác nhận mật khẩu',
                    icon: Icons.key_outlined,
                    isObscure: !_confirmPasswordVisible,
                    onToggleVisibility: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Mật khẩu xác nhận không khớp.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Hiển thị lỗi từ provider
                  Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        if(auth.errorMessage != null && !auth.isLoading) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(auth.errorMessage!, style: TextStyle(color: Colors.red)),
                          );
                        }
                        return SizedBox.shrink();
                      }
                  ),

                  // Nút xác nhận
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, child) => ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.lightBlueAccent))
                            : const Text('XÁC NHẬN'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập mật khẩu.';
        }
        if (value.length < 6) {
          return 'Mật khẩu phải có ít nhất 6 ký tự.';
        }
        return null;
      },
    );
  }
}
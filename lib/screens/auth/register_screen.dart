import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_view.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final nav = Navigator.of(context);
    try {
      await context.read<AuthService>().register(_name.text, _email.text, _password.text);
      nav.popUntil((r) => r.isFirst); // về gốc, app.dart hiển thị màn hình chính
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: 'Họ tên', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                  validator: (v) => Validators.required(v, 'Họ tên'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                  validator: Validators.password,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Xác nhận mật khẩu', prefixIcon: Icon(Icons.lock_reset), border: OutlineInputBorder()),
                  validator: Validators.confirmPassword(() => _password.text),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Tạo tài khoản'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

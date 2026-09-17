import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/app_strings.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _keepLoggedIn = true;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
      }

      // 保持登录逻辑保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('keep_logged_in', _keepLoggedIn);

    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isChineseNotifier,
      builder: (context, isChinese, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // 右上角胶囊风格语言切换按钮
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      isChineseNotifier.value = !isChineseNotifier.value;
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF7B9C).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            color: Color(0xFFFF7B9C),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isChinese ? 'EN' : '中文',
                            style: const TextStyle(
                              color: Color(0xFFFF7B9C),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_rounded, size: 80, color: Color(0xFFFF7B9C)),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.appTitle,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: isChinese ? '邮箱' : 'Email',
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: isChinese ? '密码' : 'Password',
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 保持登录 30 天勾选框
                  Row(
                    children: [
                      Checkbox(
                        value: _keepLoggedIn,
                        activeColor: const Color(0xFFFF7B9C),
                        onChanged: (val) => setState(() => _keepLoggedIn = val ?? true),
                      ),
                      Text(AppStrings.keepLoggedIn, style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7B9C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isLogin
                                  ? (isChinese ? '登录' : 'Sign In')
                                  : (isChinese ? '注册' : 'Sign Up'),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? (isChinese ? '没有账号？去注册' : "Don't have an account? Sign Up")
                          : (isChinese ? '已有账号？去登录' : 'Already have an account? Sign In'),
                      style: const TextStyle(color: Color(0xFFFF7B9C)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
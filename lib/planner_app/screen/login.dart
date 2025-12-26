import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planner/planner_app/screen/ForgotPassword.dart';
import 'package:planner/planner_app/screen/home.dart';
import 'package:planner/planner_app/screen/signup.dart';
import 'package:planner/service/auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอก Email และ Password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'ไม่พบบัญชีผู้ใช้นี้';
          break;
        case 'wrong-password':
          message = 'รหัสผ่านไม่ถูกต้อง';
          break;
        case 'invalid-email':
          message = 'รูปแบบอีเมลไม่ถูกต้อง';
          break;
        case 'missing-password':
          message = 'กรุณากรอกรหัสผ่าน';
          break;
        case 'invalid-credential':
          message = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
          break;
        default:
          message = 'เกิดข้อผิดพลาด (${e.code})';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        title: const Text(
          'Welcome for planing',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Login',
                style: TextStyle(color: Colors.black, fontSize: 40),
              ),
            ),
            const SizedBox(height: 32),

            // Email
            const Text('Email', style: TextStyle(color: Colors.black)),
            const SizedBox(height: 8),
            _roundedField(
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.black),
                  hintText: 'Enter your email',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Password
            const Text('Password', style: TextStyle(color: Colors.black)),
            const SizedBox(height: 8),
            _roundedField(
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  hintText: 'Enter your password',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Forgotpassword()),
                  );
                },
                child: const Text(
                  'Forget Password ?',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sign in button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[100],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 1,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in', style: TextStyle(fontSize: 20)),
              ),
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text('or',
                  style: TextStyle(color: Colors.black, fontSize: 24)),
            ),
            const SizedBox(height: 12),

            // Login with Google
            GestureDetector(
              onTap: () async {
                final credential = await AuthMethod().signInWithGoogle(context);
                final user = credential?.user;
                if (user != null && mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MyHomePage()),
                  );
                }
              },
              child: Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child:
                      Text('Login with Google', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),

            // Login with Apple (placeholder)

            const SizedBox(height: 8),

            const Center(
              child: Text(
                "Don't have an account",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Signup()),
                );
              },
              child: Center(
                child: Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[200],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundedField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planner/screens/home/login.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  String email = "";
  // ใช้ TextEditingController เพื่อดึงค่าอีเมล
  TextEditingController emailcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  // 1. ฟังก์ชัน Reset Password
  resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailcontroller.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Password Reset Email has been sent!",
              style: TextStyle(fontSize: 18.0))));

      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No user found for that email.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 70),

            // 📝 ส่วนหัวข้อ
            const Text(
              "Password Recovery",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your email to receive a password reset link.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // 🔑 ส่วนฟอร์มสำหรับใส่อีเมล
            Form(
              key: _formkey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 253, 189, 222)
                          .withOpacity(0.3), // สีพื้นหลังอ่อนๆ
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: emailcontroller,
                      decoration: const InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 154, 151, 152)),
                        prefixIcon:
                            Icon(Icons.mail_outline, color: Colors.grey),
                        border: InputBorder
                            .none, // ลบเส้นขอบเริ่มต้นของ TextFormField
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // เพิ่มการตรวจสอบรูปแบบอีเมลเบื้องต้น
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ➡️ ปุ่มสำหรับ Reset Password
                  GestureDetector(
                    onTap: () {
                      resetPassword();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            255, 170, 195, 238), // สีน้ำเงินสำหรับปุ่มหลัก
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 152, 187, 248)
                                .withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Send Reset Link",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ใช้ Spacer เพื่อดันเนื้อหาขึ้นไปด้านบน
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

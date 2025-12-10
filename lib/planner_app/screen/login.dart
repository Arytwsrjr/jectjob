import 'package:flutter/material.dart';
import 'package:planner/planner_app/screen/ForgotPassword.dart';
import 'package:planner/planner_app/screen/home.dart';
import 'package:planner/planner_app/screen/signup.dart';
import 'package:planner/service/auth.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        title: Text(
          'Welcome for planing',
          style: TextStyle(
              color: Colors.amber[50],
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
          ),
          Center(
              child: Text('Login',
                  style: TextStyle(color: Colors.black, fontSize: 40))),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: Text(
              'Email',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(30)),
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: Text(
              'Password',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(30)),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 30.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Forgotpassword()));
                  },
                  child: Text(
                    'Forget Password ?',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()));
            },
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(30)),
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Sign in',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'or',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ),
          GestureDetector(
            onTap: () {
              AuthMethod().signInWithGoogle(context);
            },
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(30)),
              margin: EdgeInsets.all(20),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  '/Users/_arytwsrjr/jecteeraoruk/planner/assets/image/logo_16509564.png',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Login with Google',
                  style: TextStyle(fontSize: 24),
                ),
              ]),
            ),
          ),

          /*onTap: () {
              AuthMethod().signInWithApple();
            },*/
          Center(
              child: Text(
            "Don't have an account",
            style: TextStyle(fontSize: 16),
          )),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Signup()));
            },
            child: Center(
                child: Text(
              "Sign up",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[200]),
            )),
          )
        ],
      ),
    );
  }
}

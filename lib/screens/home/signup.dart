import 'package:flutter/material.dart';
import 'package:planner/screens/home/login.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

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
              child: Text('Sign up',
                  style: TextStyle(color: Colors.black, fontSize: 40))),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: Text(
              'Name',
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
          SizedBox(
            height: 20,
          ),
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
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(30)),
            margin: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Sign up',
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
          ),
          Center(
              child: Text(
            "Already have an account",
            style: TextStyle(fontSize: 16),
          )),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login()));
            },
            child: Center(
                child: Text(
              "Signin",
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

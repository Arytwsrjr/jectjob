import 'package:flutter/material.dart';

class Datatime extends StatefulWidget {
  const Datatime({super.key});

  @override
  State<Datatime> createState() => _DatatimeState();
}

class _DatatimeState extends State<Datatime> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activity Time"),
        backgroundColor: const Color.fromARGB(255, 212, 249, 188),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: Text(
              'Take a shower and get dressed 🛁',
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 247, 219, 127).withOpacity(0.3),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: '.... minute',
                hintStyle:
                    TextStyle(color: const Color.fromARGB(255, 146, 145, 145)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: Text(
              'Skincare or makeup 💄',
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 247, 219, 127).withOpacity(0.3),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: '.... minute',
                hintStyle:
                    TextStyle(color: const Color.fromARGB(255, 146, 145, 145)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              'Eat food 🍱',
              style: TextStyle(fontSize: 17),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 247, 219, 127).withOpacity(0.3),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: '.... minute',
                hintStyle:
                    TextStyle(color: const Color.fromARGB(255, 146, 145, 145)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              'Prepare items 🎒',
              style: TextStyle(fontSize: 17),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 247, 219, 127).withOpacity(0.3),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: '.... minute',
                hintStyle:
                    TextStyle(color: const Color.fromARGB(255, 146, 145, 145)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              'Review lesson 📖',
              style: TextStyle(fontSize: 17),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 247, 219, 127).withOpacity(0.3),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: '.... minute',
                hintStyle:
                    TextStyle(color: const Color.fromARGB(255, 146, 145, 145)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 179, 218, 255),
                borderRadius: BorderRadius.circular(30)),
            margin: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Save',
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:planner/planner_app/screen/login.dart';
import 'package:planner/planner_app/widget/piechart.dart';
import 'package:planner/planner_app/widget/taskbar.dart';

class Sumerize extends StatelessWidget {
  const Sumerize({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 221, 141),
      appBar: _buildAppbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Text(
              'progress',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // กราฟวงกลม
          Center(
            child: SizedBox(
              height: 260,
              child: Piechart(),
            ),
          ),
          const SizedBox(height: 40),

          // แถบ progress bar
          const Text(
            'Task Completion Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          TaskProgressBar(),

          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false,
              );
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
                  'Logout',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      backgroundColor: Colors.amber,
      //const Color.fromARGB(255, 169, 203, 231),
      elevation: 0,
      title: Row(
        children: [
          Container(
            height: 60,
            width: 45,
            margin: EdgeInsets.only(bottom: 15, left: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                  '/Users/_arytwsrjr/jecteeraoruk/planner/assets/image/yuji.jpg'),
            ),
          ),
          SizedBox(
            width: 60,
          ),
          Text(
            'See Sumerize',
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
            ),
          ),
        ],
      ),
      //actions: [
      //Icon(
      //  Icons.more_horiz,
      // color: Colors.black,
      //  size: 40,
      // )
      // ],
    );
  }
}

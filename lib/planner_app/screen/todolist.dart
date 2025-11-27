import 'package:flutter/material.dart';

class Todolist extends StatelessWidget {
  const Todolist({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> todos = [
      {
        'title': 'golang assignment',
        'due': '15 March 2568 (11 days left)',
        'color': Colors.amber,
        'isDone': false,
      },
      {
        'title': 'Final Artificial Intelligence',
        'due': '19 March 2568 (15 days left)',
        'color': Colors.amber,
        'isDone': false,
      },
      {
        'title': 'mobileapp assignment',
        'due': 'Finished on March 13th',
        'color': Colors.grey.shade300,
        'isDone': true,
      },
      {
        'title': 'English homework',
        'due': 'Finished on March 3th',
        'color': Colors.grey.shade300,
        'isDone': true,
      },
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        elevation: 0,
        title: Text('To-do list'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          // SizedBox(
          // height: 50,
          // ),
          //Padding(
          //  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          // ),
          //Text(
          //  'Todo List',
          // style: TextStyle(fontSize: 30),
          //),
          //SizedBox(
          // height: 8,
          //),
          //Divider(
          //  thickness: 1,
          // ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: Colors.pinkAccent),
            child: Text(
              'March',
              style: TextStyle(color: Colors.black),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Su'),
              Text('Mo'),
              Text('Tu'),
              Text('Wed'),
              Text('Th'),
              Text('Fr'),
              Text('Sat')
            ],
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var day in ['16', '17', '18', '19', '20', '22', '21'])
                day == '19'
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7C97F),
                          shape: BoxShape.circle,
                        ),
                        child: Text(day,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      )
                    : Text(day),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                final bool isDone = todo['isDone'];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: todo['color'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: isDone
                        ? const Icon(Icons.check_circle, color: Colors.black)
                        : const Icon(Icons.circle_outlined,
                            color: Colors.white),
                    title: Text(
                      todo['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      isDone ? todo['due'] : "Due: ${todo['due']}",
                      style: TextStyle(
                        color: isDone ? Colors.black54 : Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                    trailing: const Icon(Icons.delete_outline),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

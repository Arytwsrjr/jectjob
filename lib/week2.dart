class Student {
  String name;
  double score;

  Student(this.name, this.score);

  void showInfo() {
    print('Name: $name');
    print('Score: $score');
  }

  String calculateGrade() {
    if (score >= 80) {
      return 'A';
    } else if (score >= 70) {
      return 'B';
    } else if (score >= 60) {
      return 'C';
    } else if (score >= 50) {
      return 'D';
    } else {
      return 'F';
    }
  }
}

Student createStudent({
  required String name,
  required double score,
  double bonus = 0,
}) {
  double totalScore = score + bonus;
  
  return Student(name, totalScore);
}

void main() {

  Student student1 = createStudent(name: "Alice", score: 75);
  Student student2 = createStudent(name: "Rise", score: 45, bonus: 10);

  student1.showInfo();
  print("Grade: ${student1.calculateGrade()}");

  student2.showInfo();
  print("Grade: ${student2.calculateGrade()}");
}
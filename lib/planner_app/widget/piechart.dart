import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class Piechart extends StatelessWidget {
  // ข้อมูลสำหรับ Pie Chart: Complete vs Incomplete
  final Map<String, double> dataMap = {
    "Complete": 40,
    "Incomplete": 60,
  };

  // สีสำหรับแต่ละส่วน
  final List<Color> colorList = [
    const Color(0xFF81C784), // สีเขียวสำหรับ Complete
    const Color(0xFFE57373), // สีแดงสำหรับ Incomplete
  ];

  Piechart({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      dataMap: dataMap,
      colorList: colorList,
      chartRadius: MediaQuery.of(context).size.width / 2,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      centerText: "PROGRESS",
      legendOptions: const LegendOptions(
        showLegendsInRow: true,
        legendPosition: LegendPosition.bottom,
        showLegends: true,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValueBackground: false,
        showChartValues: false,
        showChartValuesInPercentage: true,
        showChartValuesOutside: false,
        decimalPlaces: 0,
      ),
    );
  }
}

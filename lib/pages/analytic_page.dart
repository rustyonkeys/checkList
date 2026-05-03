// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// class AnalyticsPage extends StatefulWidget {
//   final bool isDarkMode;
//
//   const AnalyticsPage({super.key, this.isDarkMode = false});
//
//   @override
//   State<AnalyticsPage> createState() => _AnalyticsPageState();
// }
//
// class _AnalyticsPageState extends State<AnalyticsPage> {
//   int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year
//
//   @override
//   Widget build(BuildContext context) {
//     // Theme colors
//     final backgroundColor = widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[50];
//     final cardColor = widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
//     final textColor = widget.isDarkMode ? Colors.white : Colors.black;
//     final borderColor = widget.isDarkMode ? Colors.grey[700]! : Colors.grey.shade200;
//     final subtleTextColor = widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];
//
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: cardColor,
//         title: Text(
//           'Analytics',
//           style: TextStyle(
//             color: textColor,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: textColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 16),
//
//             // Period Selector
//             _buildPeriodSelector(cardColor, borderColor, textColor),
//
//             const SizedBox(height: 24),
//
//             // Stats Cards
//             _buildStatsCards(cardColor, borderColor, textColor, subtleTextColor),
//
//             const SizedBox(height: 24),
//
//             // Task Completion Heatmap
//             _buildTaskHeatmap(),
//
//             const SizedBox(height: 16),
//
//             // Completion Rate Chart
//             _buildChartCard(
//               title: 'Completion Rate',
//               child: _buildLineChart(borderColor, subtleTextColor, textColor),
//               cardColor: cardColor,
//               borderColor: borderColor,
//               textColor: textColor,
//             ),
//
//             const SizedBox(height: 16),
//
//             // Task Distribution
//             _buildChartCard(
//               title: 'Task Distribution',
//               child: _buildPieChart(textColor),
//               cardColor: cardColor,
//               borderColor: borderColor,
//               textColor: textColor,
//             ),
//
//             const SizedBox(height: 16),
//
//             // Priority Breakdown
//             _buildChartCard(
//               title: 'Priority Breakdown',
//               child: _buildBarChart(borderColor, subtleTextColor),
//               cardColor: cardColor,
//               borderColor: borderColor,
//               textColor: textColor,
//             ),
//
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPeriodSelector(Color cardColor, Color borderColor, Color textColor) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 24),
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: borderColor),
//       ),
//       child: Row(
//         children: [
//           _periodButton('Week', 0, textColor),
//           _periodButton('Month', 1, textColor),
//           _periodButton('Year', 2, textColor),
//         ],
//       ),
//     );
//   }
//
//   Widget _periodButton(String label, int index, Color textColor) {
//     final isSelected = _selectedPeriod == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _selectedPeriod = index),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? (widget.isDarkMode ? Colors.white : Colors.black)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: isSelected
//                   ? (widget.isDarkMode ? Colors.black : Colors.white)
//                   : textColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatsCards(
//       Color cardColor,
//       Color borderColor,
//       Color textColor,
//       Color? subtleTextColor,
//       ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildStatCard(
//               title: 'Completed',
//               value: '48',
//               subtitle: '+12% from last week',
//               color: Colors.green,
//               icon: Icons.check_circle,
//               cardColor: cardColor,
//               borderColor: borderColor,
//               textColor: textColor,
//               subtleTextColor: subtleTextColor,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildStatCard(
//               title: 'Pending',
//               value: '12',
//               subtitle: '3 due today',
//               color: Colors.orange,
//               icon: Icons.pending,
//               cardColor: cardColor,
//               borderColor: borderColor,
//               textColor: textColor,
//               subtleTextColor: subtleTextColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required String subtitle,
//     required Color color,
//     required IconData icon,
//     required Color cardColor,
//     required Color borderColor,
//     required Color textColor,
//     required Color? subtleTextColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: borderColor),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: subtleTextColor,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Icon(icon, size: 20, color: color),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               height: 1,
//               color: textColor,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 12,
//               color: subtleTextColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTaskHeatmap() {
//     final Map<DateTime, int> completionData = _getSampleCompletionData();
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: TaskCompletionHeatmap(
//         completionData: completionData,
//         selectedPeriod: _selectedPeriod == 0 ? 'Week' :
//         _selectedPeriod == 1 ? 'Month' : 'Year',
//         isDarkMode: widget.isDarkMode,
//       ),
//     );
//   }
//
//   Map<DateTime, int> _getSampleCompletionData() {
//     final Map<DateTime, int> data = {};
//     final now = DateTime.now();
//
//     for (int i = 0; i < 84; i++) {
//       final date = DateTime(
//         now.year,
//         now.month,
//         now.day,
//       ).subtract(Duration(days: i));
//
//       if (i % 3 == 0) {
//         data[date] = (i % 9);
//       }
//     }
//
//     return data;
//   }
//
//   Widget _buildChartCard({
//     required String title,
//     required Widget child,
//     required Color cardColor,
//     required Color borderColor,
//     required Color textColor,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 24),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: borderColor),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: textColor,
//             ),
//           ),
//           const SizedBox(height: 20),
//           child,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLineChart(Color borderColor, Color? subtleTextColor, Color textColor) {
//     return SizedBox(
//       height: 200,
//       child: LineChart(
//         LineChartData(
//           gridData: FlGridData(
//             show: true,
//             drawVerticalLine: false,
//             horizontalInterval: 20,
//             getDrawingHorizontalLine: (value) {
//               return FlLine(
//                 color: borderColor,
//                 strokeWidth: 1,
//               );
//             },
//           ),
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 40,
//                 getTitlesWidget: (value, meta) {
//                   return Text(
//                     '${value.toInt()}%',
//                     style: TextStyle(
//                       color: subtleTextColor,
//                       fontSize: 12,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//                   if (value.toInt() >= 0 && value.toInt() < days.length) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 8),
//                       child: Text(
//                         days[value.toInt()],
//                         style: TextStyle(
//                           color: subtleTextColor,
//                           fontSize: 12,
//                         ),
//                       ),
//                     );
//                   }
//                   return const Text('');
//                 },
//               ),
//             ),
//             rightTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             topTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//           ),
//           borderData: FlBorderData(show: false),
//           lineBarsData: [
//             LineChartBarData(
//               spots: const [
//                 FlSpot(0, 65),
//                 FlSpot(1, 75),
//                 FlSpot(2, 70),
//                 FlSpot(3, 85),
//                 FlSpot(4, 80),
//                 FlSpot(5, 90),
//                 FlSpot(6, 88),
//               ],
//               isCurved: true,
//               color: widget.isDarkMode ? Colors.white : Colors.black,
//               barWidth: 3,
//               dotData: FlDotData(
//                 show: true,
//                 getDotPainter: (spot, percent, barData, index) {
//                   return FlDotCirclePainter(
//                     radius: 4,
//                     color: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
//                     strokeWidth: 2,
//                     strokeColor: widget.isDarkMode ? Colors.white : Colors.black,
//                   );
//                 },
//               ),
//               belowBarData: BarAreaData(
//                 show: true,
//                 color: widget.isDarkMode
//                     ? Colors.white.withOpacity(0.1)
//                     : Colors.black.withOpacity(0.05),
//               ),
//             ),
//           ],
//           minY: 0,
//           maxY: 100,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPieChart(Color textColor) {
//     return SizedBox(
//       height: 220,
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: PieChart(
//               PieChartData(
//                 sectionsSpace: 2,
//                 centerSpaceRadius: 50,
//                 sections: [
//                   PieChartSectionData(
//                     value: 40,
//                     title: '40%',
//                     color: Colors.blue,
//                     radius: 60,
//                     titleStyle: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   PieChartSectionData(
//                     value: 30,
//                     title: '30%',
//                     color: Colors.purple,
//                     radius: 60,
//                     titleStyle: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   PieChartSectionData(
//                     value: 20,
//                     title: '20%',
//                     color: Colors.teal,
//                     radius: 60,
//                     titleStyle: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   PieChartSectionData(
//                     value: 10,
//                     title: '10%',
//                     color: Colors.orange,
//                     radius: 60,
//                     titleStyle: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildLegendItem('Work', Colors.blue, textColor),
//                 _buildLegendItem('Personal', Colors.purple, textColor),
//                 _buildLegendItem('Health', Colors.teal, textColor),
//                 _buildLegendItem('Shopping', Colors.orange, textColor),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLegendItem(String label, Color color, Color textColor) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Container(
//             width: 12,
//             height: 12,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: textColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBarChart(Color borderColor, Color? subtleTextColor) {
//     return SizedBox(
//       height: 200,
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.spaceAround,
//           maxY: 30,
//           barTouchData: BarTouchData(enabled: false),
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 40,
//                 getTitlesWidget: (value, meta) {
//                   return Text(
//                     value.toInt().toString(),
//                     style: TextStyle(
//                       color: subtleTextColor,
//                       fontSize: 12,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   const priorities = ['High', 'Medium', 'Low'];
//                   if (value.toInt() >= 0 && value.toInt() < priorities.length) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 8),
//                       child: Text(
//                         priorities[value.toInt()],
//                         style: TextStyle(
//                           color: subtleTextColor,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     );
//                   }
//                   return const Text('');
//                 },
//               ),
//             ),
//             rightTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             topTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//           ),
//           gridData: FlGridData(
//             show: true,
//             drawVerticalLine: false,
//             horizontalInterval: 10,
//             getDrawingHorizontalLine: (value) {
//               return FlLine(
//                 color: borderColor,
//                 strokeWidth: 1,
//               );
//             },
//           ),
//           borderData: FlBorderData(show: false),
//           barGroups: [
//             BarChartGroupData(
//               x: 0,
//               barRods: [
//                 BarChartRodData(
//                   toY: 25,
//                   color: Colors.red.shade600,
//                   width: 40,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(6),
//                   ),
//                 ),
//               ],
//             ),
//             BarChartGroupData(
//               x: 1,
//               barRods: [
//                 BarChartRodData(
//                   toY: 20,
//                   color: Colors.orange.shade600,
//                   width: 40,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(6),
//                   ),
//                 ),
//               ],
//             ),
//             BarChartGroupData(
//               x: 2,
//               barRods: [
//                 BarChartRodData(
//                   toY: 15,
//                   color: Colors.teal.shade600,
//                   width: 40,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(6),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================================
// // TASK COMPLETION HEATMAP WITH DARK MODE
// // ============================================================================
//
// class TaskCompletionHeatmap extends StatelessWidget {
//   final Map<DateTime, int> completionData;
//   final String selectedPeriod;
//   final bool isDarkMode;
//
//   const TaskCompletionHeatmap({
//     super.key,
//     required this.completionData,
//     this.selectedPeriod = 'Month',
//     this.isDarkMode = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isDarkMode
//               ? [
//             Colors.deepPurple.shade700,
//             Colors.deepPurple.shade500,
//           ]
//               : [
//             Colors.orange.shade800,
//             Colors.orange.shade600,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Tasks Completed',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 selectedPeriod,
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.7),
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           _buildStats(),
//           const SizedBox(height: 20),
//           _buildHeatmapGrid(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStats() {
//     final total = completionData.values.fold(0, (sum, val) => sum + val);
//     final days = completionData.length;
//     final percentage = days > 0 ? ((total / days) * 10).toStringAsFixed(0) : '0';
//
//     return Row(
//       children: [
//         Text(
//           total.toString(),
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 36,
//             fontWeight: FontWeight.bold,
//             height: 1,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           '$percentage%',
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.8),
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildHeatmapGrid() {
//     List<List<_DayData>> weeks;
//
//     if (selectedPeriod == 'Week') {
//       weeks = _generateWeekData();
//     } else if (selectedPeriod == 'Month') {
//       weeks = _generateMonthData();
//     } else {
//       weeks = _generateYearData();
//     }
//
//     return Column(
//       children: weeks.asMap().entries.map((entry) {
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 8),
//           child: Row(
//             children: entry.value.map((day) {
//               return Expanded(
//                 child: Container(
//                   height: 36,
//                   margin: const EdgeInsets.only(right: 8),
//                   decoration: BoxDecoration(
//                     color: _getHeatmapColor(day.taskCount),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: day.taskCount > 0
//                       ? Center(
//                     child: Text(
//                       day.taskCount.toString(),
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: day.taskCount >= 5
//                             ? Colors.white
//                             : Colors.black87,
//                       ),
//                     ),
//                   )
//                       : null,
//                 ),
//               );
//             }).toList(),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   List<List<_DayData>> _generateWeekData() {
//     final now = DateTime.now();
//     final days = List.generate(7, (i) {
//       final date = now.subtract(Duration(days: 6 - i));
//       final dateKey = DateTime(date.year, date.month, date.day);
//       return _DayData(
//         date: dateKey,
//         taskCount: completionData[dateKey] ?? 0,
//       );
//     });
//     return [days];
//   }
//
//   List<List<_DayData>> _generateMonthData() {
//     final now = DateTime.now();
//     final weeks = <List<_DayData>>[];
//
//     for (int week = 3; week >= 0; week--) {
//       final weekDays = <_DayData>[];
//       for (int day = 0; day < 7; day++) {
//         final date = now.subtract(Duration(days: (week * 7) + (6 - day)));
//         final dateKey = DateTime(date.year, date.month, date.day);
//         weekDays.add(_DayData(
//           date: dateKey,
//           taskCount: completionData[dateKey] ?? 0,
//         ));
//       }
//       weeks.add(weekDays);
//     }
//
//     return weeks;
//   }
//
//   List<List<_DayData>> _generateYearData() {
//     final now = DateTime.now();
//     final weeks = <List<_DayData>>[];
//
//     for (int week = 11; week >= 0; week--) {
//       final weekDays = <_DayData>[];
//       for (int day = 0; day < 7; day++) {
//         final date = now.subtract(Duration(days: (week * 7) + (6 - day)));
//         final dateKey = DateTime(date.year, date.month, date.day);
//         weekDays.add(_DayData(
//           date: dateKey,
//           taskCount: completionData[dateKey] ?? 0,
//         ));
//       }
//       weeks.add(weekDays);
//     }
//
//     return weeks;
//   }
//
//   Color _getHeatmapColor(int taskCount) {
//     if (taskCount == 0) {
//       return Colors.white.withOpacity(0.15);
//     } else if (taskCount <= 2) {
//       return Colors.white.withOpacity(0.3);
//     } else if (taskCount <= 4) {
//       return Colors.white.withOpacity(0.5);
//     } else if (taskCount <= 6) {
//       return Colors.white.withOpacity(0.7);
//     } else {
//       return Colors.white.withOpacity(0.9);
//     }
//   }
// }
//
// class _DayData {
//   final DateTime date;
//   final int taskCount;
//
//   _DayData({required this.date, required this.taskCount});
// }

// lib/pages/analytic page.dart
//
// Pass the real tasks list from HomePage.
// All charts and numbers are computed live — zero dummy data.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:checklist/util/task.dart';

// ── Category color map (matches AddTaskPage lists) ─────────────────────────
const Map<String, Color> kCategoryColors = {
  'Work': Color(0xFF2196F3),
  'Personal': Color(0xFF9C27B0),
  'Health': Color(0xFF009688),
  'Shopping': Color(0xFFFF9800),
  'Study': Color(0xFFE91E63),
};

// ── Priority colors ────────────────────────────────────────────────────────
const Map<Priority, Color> kPriorityColors = {
  Priority.high: Color(0xFFE53935),
  Priority.medium: Color(0xFFFF9800),
  Priority.low: Color(0xFF009688),
};

const Map<Priority, String> kPriorityLabels = {
  Priority.high: 'High',
  Priority.medium: 'Medium',
  Priority.low: 'Low',
};

// ═══════════════════════════════════════════════════════════════════════════
// ANALYTICS PAGE
// ═══════════════════════════════════════════════════════════════════════════

class AnalyticsPage extends StatefulWidget {
  final bool isDarkMode;
  final List<Task> tasks; // ← real task list from HomePage

  const AnalyticsPage({
    super.key,
    this.isDarkMode = false,
    required this.tasks,
  });

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedPeriod = 0; // 0=Week 1=Month 2=Year

  // ── Date helpers ────────────────────────────────────────────────────────

  DateTime get _now => DateTime.now();
  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _periodStart {
    final today = _dayOnly(_now);
    switch (_selectedPeriod) {
      case 1:
        return today.subtract(const Duration(days: 29));
      case 2:
        return today.subtract(const Duration(days: 364));
      default:
        return today.subtract(const Duration(days: 6));
    }
  }

  // ── Computed properties from real tasks ─────────────────────────────────

  /// Tasks completed within the selected period
  List<Task> get _completedInPeriod =>
      widget.tasks.where((t) {
        if (!t.isDone || t.completedAt == null) return false;
        final day = _dayOnly(t.completedAt!);
        return !day.isBefore(_periodStart) && !day.isAfter(_dayOnly(_now));
      }).toList();

  /// Tasks completed in the PREVIOUS period (for % change calculation)
  List<Task> get _completedPrevPeriod {
    final periodLen = _dayOnly(_now).difference(_periodStart);
    final prevEnd = _periodStart.subtract(const Duration(days: 1));
    final prevStart = prevEnd.subtract(periodLen);
    return widget.tasks.where((t) {
      if (!t.isDone || t.completedAt == null) return false;
      final day = _dayOnly(t.completedAt!);
      return !day.isBefore(prevStart) && !day.isAfter(prevEnd);
    }).toList();
  }

  int get _completedCount => _completedInPeriod.length;

  int get _pendingCount => widget.tasks.where((t) => !t.isDone).length;

  int get _dueTodayCount =>
      widget.tasks
          .where((t) => !t.isDone && t.dueDate == _dayOnly(_now))
          .length;

  String get _completedSubtitle {
    final prev = _completedPrevPeriod.length;
    if (prev == 0) return 'No data from last period';
    final diff = _completedCount - prev;
    final pct = ((diff / prev) * 100).round();
    final sign = pct >= 0 ? '+' : '';
    final label =
        _selectedPeriod == 0
            ? 'week'
            : _selectedPeriod == 1
            ? 'month'
            : 'year';
    return '$sign$pct% from last $label';
  }

  String get _pendingSubtitle =>
      _dueTodayCount > 0 ? '$_dueTodayCount due today' : 'None due today';

  /// Heatmap: date → count of tasks completed that day
  Map<DateTime, int> get _heatmapData {
    final map = <DateTime, int>{};
    for (final t in _completedInPeriod) {
      final day = _dayOnly(t.completedAt!);
      map[day] = (map[day] ?? 0) + 1;
    }
    return map;
  }

  /// Completion rate per weekday (0=Mon…6=Sun) as percentage
  /// = completed / (completed + pending due that day) * 100
  List<_RatePoint> get _completionRatePoints {
    // Build a map: weekday → {done, total}
    final Map<int, _DayStats> stats = {};
    for (final t in widget.tasks) {
      // Only consider tasks due within this period
      final due = t.dueDate;
      if (due.isBefore(_periodStart) || due.isAfter(_dayOnly(_now))) continue;
      final dow = (due.weekday - 1) % 7; // Mon=0 … Sun=6
      stats[dow] ??= _DayStats();
      stats[dow]!.total++;
      if (t.isDone) stats[dow]!.done++;
    }
    return List.generate(7, (i) {
      final s = stats[i];
      if (s == null || s.total == 0) return _RatePoint(i, 0);
      return _RatePoint(i, (s.done / s.total) * 100);
    });
  }

  /// Task distribution by category (only completed tasks in period)
  List<_DistItem> get _taskDistribution {
    final map = <String, int>{};
    for (final t in _completedInPeriod) {
      final cat = t.list ?? 'Other';
      map[cat] = (map[cat] ?? 0) + 1;
    }
    final total = map.values.fold(0, (a, b) => a + b);
    if (total == 0) return [];
    return map.entries
        .map(
          (e) => _DistItem(
            label: e.key,
            percentage: (e.value / total) * 100,
            color: kCategoryColors[e.key] ?? Colors.grey,
          ),
        )
        .toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
  }

  /// Priority breakdown: count of all tasks per priority in period
  List<_PriorityItem> get _priorityBreakdown {
    final map = <Priority, int>{};
    for (final t in widget.tasks) {
      if (t.dueDate.isBefore(_periodStart)) continue;
      map[t.priority] = (map[t.priority] ?? 0) + 1;
    }
    return [Priority.high, Priority.medium, Priority.low]
        .where((p) => map.containsKey(p))
        .map((p) => _PriorityItem(p, map[p]!.toDouble()))
        .toList();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[50]!;
    final card = widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final text = widget.isDarkMode ? Colors.white : Colors.black;
    final border = widget.isDarkMode ? Colors.grey[700]! : Colors.grey.shade200;
    final subtle = widget.isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: card,
        title: Text(
          'Analytics',
          style: TextStyle(
            color: text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Period selector ──────────────────────────────────────────
            _buildPeriodSelector(card, border, text),

            const SizedBox(height: 24),

            // ── Stats cards ──────────────────────────────────────────────
            _buildStatsCards(card, border, text, subtle),

            const SizedBox(height: 24),

            // ── Heatmap ──────────────────────────────────────────────────
            _buildHeatmap(),

            const SizedBox(height: 16),

            // ── Completion Rate ──────────────────────────────────────────
            _buildChartCard(
              title: 'Completion Rate',
              card: card,
              border: border,
              text: text,
              child: _buildLineChart(border, subtle),
            ),

            const SizedBox(height: 16),

            // ── Task Distribution ────────────────────────────────────────
            if (_taskDistribution.isNotEmpty)
              _buildChartCard(
                title: 'Task Distribution',
                card: card,
                border: border,
                text: text,
                child: _buildPieChart(text),
              ),

            if (_taskDistribution.isEmpty)
              _buildChartCard(
                title: 'Task Distribution',
                card: card,
                border: border,
                text: text,
                child: _emptyState(
                  'Complete tasks with a category\nto see distribution',
                  subtle,
                ),
              ),

            const SizedBox(height: 16),

            // ── Priority Breakdown ───────────────────────────────────────
            if (_priorityBreakdown.isNotEmpty)
              _buildChartCard(
                title: 'Priority Breakdown',
                card: card,
                border: border,
                text: text,
                child: _buildBarChart(border, subtle),
              ),

            if (_priorityBreakdown.isEmpty)
              _buildChartCard(
                title: 'Priority Breakdown',
                card: card,
                border: border,
                text: text,
                child: _emptyState(
                  'Add tasks to see priority breakdown',
                  subtle,
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Period selector ──────────────────────────────────────────────────────

  Widget _buildPeriodSelector(Color card, Color border, Color text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _periodBtn('Week', 0, text),
          _periodBtn('Month', 1, text),
          _periodBtn('Year', 2, text),
        ],
      ),
    );
  }

  Widget _periodBtn(String label, int idx, Color text) {
    final sel = _selectedPeriod == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                sel
                    ? (widget.isDarkMode ? Colors.white : Colors.black)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  sel
                      ? (widget.isDarkMode ? Colors.black : Colors.white)
                      : text,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── Stats cards ──────────────────────────────────────────────────────────

  Widget _buildStatsCards(Color card, Color border, Color text, Color subtle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              title: 'Completed',
              value: _completedCount.toString(),
              subtitle: _completedSubtitle,
              color: Colors.green,
              icon: Icons.check_circle,
              card: card,
              border: border,
              text: text,
              subtle: subtle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              title: 'Pending',
              value: _pendingCount.toString(),
              subtitle: _pendingSubtitle,
              color: Colors.orange,
              icon: Icons.pending,
              card: card,
              border: border,
              text: text,
              subtle: subtle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    required Color card,
    required Color border,
    required Color text,
    required Color subtle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: subtle,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1,
              color: text,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: subtle)),
        ],
      ),
    );
  }

  // ── Heatmap ──────────────────────────────────────────────────────────────

  Widget _buildHeatmap() {
    final label =
        _selectedPeriod == 0
            ? 'Week'
            : _selectedPeriod == 1
            ? 'Month'
            : 'Year';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TaskCompletionHeatmap(
        completionData: _heatmapData,
        selectedPeriod: label,
        isDarkMode: widget.isDarkMode,
      ),
    );
  }

  // ── Chart card wrapper ───────────────────────────────────────────────────

  Widget _buildChartCard({
    required String title,
    required Widget child,
    required Color card,
    required Color border,
    required Color text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _emptyState(String msg, Color subtle) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: subtle, fontSize: 14, height: 1.6),
        ),
      ),
    );
  }

  // ── Line chart (completion rate) ─────────────────────────────────────────

  Widget _buildLineChart(Color border, Color subtle) {
    final points = _completionRatePoints;
    final hasData = points.any((p) => p.rate > 0);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final lineColor = widget.isDarkMode ? Colors.white : Colors.black;

    return SizedBox(
      height: 200,
      child:
          hasData
              ? LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine:
                        (_) => FlLine(color: border, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget:
                            (v, _) => Text(
                              '${v.toInt()}%',
                              style: TextStyle(color: subtle, fontSize: 12),
                            ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i >= 0 && i < 7) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[i],
                                style: TextStyle(color: subtle, fontSize: 12),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          points
                              .map((p) => FlSpot(p.dayIndex.toDouble(), p.rate))
                              .toList(),
                      isCurved: true,
                      color: lineColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter:
                            (_, __, ___, ____) => FlDotCirclePainter(
                              radius: 4,
                              color:
                                  widget.isDarkMode
                                      ? const Color(0xFF2A2A2A)
                                      : Colors.white,
                              strokeWidth: 2,
                              strokeColor: lineColor,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withAlpha(18),
                      ),
                    ),
                  ],
                ),
              )
              : Center(
                child: Text(
                  'Complete tasks to see your rate',
                  style: TextStyle(color: subtle, fontSize: 14),
                ),
              ),
    );
  }

  // ── Pie chart (task distribution) ────────────────────────────────────────

  Widget _buildPieChart(Color text) {
    final items = _taskDistribution;

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections:
                    items
                        .map(
                          (item) => PieChartSectionData(
                            value: item.percentage,
                            title: '${item.percentage.toInt()}%',
                            color: item.color,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: text,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bar chart (priority breakdown) ──────────────────────────────────────

  Widget _buildBarChart(Color border, Color subtle) {
    final items = _priorityBreakdown;
    final maxY =
        items.map((e) => e.count).fold(0.0, (a, b) => a > b ? a : b) * 1.4;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY == 0 ? 10 : maxY,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget:
                    (v, _) => Text(
                      v.toInt().toString(),
                      style: TextStyle(color: subtle, fontSize: 12),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i >= 0 && i < items.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        kPriorityLabels[items[i].priority]!,
                        style: TextStyle(
                          color: subtle,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine:
                (_) => FlLine(color: border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups:
              items
                  .asMap()
                  .entries
                  .map(
                    (e) => BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.count,
                          color: kPriorityColors[e.value.priority]!,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HEATMAP WIDGET (unchanged UI)
// ═══════════════════════════════════════════════════════════════════════════

class TaskCompletionHeatmap extends StatelessWidget {
  final Map<DateTime, int> completionData;
  final String selectedPeriod;
  final bool isDarkMode;

  const TaskCompletionHeatmap({
    super.key,
    required this.completionData,
    this.selectedPeriod = 'Month',
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = completionData.values.fold(0, (s, v) => s + v);
    final days = completionData.length;
    final avg = days > 0 ? (total / days).toStringAsFixed(1) : '0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDarkMode
                  ? [Colors.deepPurple.shade700, Colors.deepPurple.shade500]
                  : [Colors.orange.shade800, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tasks Completed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                selectedPeriod,
                style: TextStyle(
                  color: const Color.fromRGBO(255, 255, 255, 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                total.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'avg $avg/day',
                  style: TextStyle(
                    color: const Color.fromRGBO(255, 255, 255, 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGrid(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final weeks =
        selectedPeriod == 'Week'
            ? _weekData()
            : selectedPeriod == 'Month'
            ? _monthData()
            : _yearData();

    return Column(
      children:
          weeks
              .map(
                (week) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children:
                        week
                            .map(
                              (day) => Expanded(
                                child: Container(
                                  height: 36,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: _cellColor(day.count),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child:
                                      day.count > 0
                                          ? Center(
                                            child: Text(
                                              day.count.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    day.count >= 5
                                                        ? Colors.white
                                                        : Colors.black87,
                                              ),
                                            ),
                                          )
                                          : null,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              )
              .toList(),
    );
  }

  List<List<_Cell>> _weekData() {
    final now = DateTime.now();
    return [
      List.generate(7, (i) {
        final d = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: 6 - i));
        return _Cell(completionData[d] ?? 0);
      }),
    ];
  }

  List<List<_Cell>> _monthData() {
    final now = DateTime.now();
    return List.generate(
      4,
      (w) => List.generate(7, (d) {
        final date = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: ((3 - w) * 7) + (6 - d)));
        return _Cell(completionData[date] ?? 0);
      }),
    );
  }

  List<List<_Cell>> _yearData() {
    final now = DateTime.now();
    return List.generate(
      12,
      (w) => List.generate(7, (d) {
        final date = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: ((11 - w) * 7) + (6 - d)));
        return _Cell(completionData[date] ?? 0);
      }),
    );
  }

  Color _cellColor(int n) {
    if (n == 0) return Colors.white.withAlpha(38);
    if (n <= 2) return Colors.white.withAlpha(77);
    if (n <= 4) return Colors.white.withAlpha(128);
    if (n <= 6) return Colors.white.withAlpha(179);
    return Colors.white.withAlpha(230);
  }
}

// ── Internal helper types ──────────────────────────────────────────────────

class _Cell {
  final int count;
  _Cell(this.count);
}

class _RatePoint {
  final int dayIndex;
  final double rate;
  _RatePoint(this.dayIndex, this.rate);
}

class _DayStats {
  int done = 0;
  int total = 0;
}

class _DistItem {
  final String label;
  final double percentage;
  final Color color;
  _DistItem({
    required this.label,
    required this.percentage,
    required this.color,
  });
}

class _PriorityItem {
  final Priority priority;
  final double count;
  _PriorityItem(this.priority, this.count);
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  final bool isDarkMode;

  const AnalyticsPage({super.key, this.isDarkMode = false});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final backgroundColor = widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[50];
    final cardColor = widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final borderColor = widget.isDarkMode ? Colors.grey[700]! : Colors.grey.shade200;
    final subtleTextColor = widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        title: Text(
          'Analytics',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Period Selector
            _buildPeriodSelector(cardColor, borderColor, textColor),

            const SizedBox(height: 24),

            // Stats Cards
            _buildStatsCards(cardColor, borderColor, textColor, subtleTextColor),

            const SizedBox(height: 24),

            // Task Completion Heatmap
            _buildTaskHeatmap(),

            const SizedBox(height: 16),

            // Completion Rate Chart
            _buildChartCard(
              title: 'Completion Rate',
              child: _buildLineChart(borderColor, subtleTextColor, textColor),
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: textColor,
            ),

            const SizedBox(height: 16),

            // Task Distribution
            _buildChartCard(
              title: 'Task Distribution',
              child: _buildPieChart(textColor),
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: textColor,
            ),

            const SizedBox(height: 16),

            // Priority Breakdown
            _buildChartCard(
              title: 'Priority Breakdown',
              child: _buildBarChart(borderColor, subtleTextColor),
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: textColor,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(Color cardColor, Color borderColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _periodButton('Week', 0, textColor),
          _periodButton('Month', 1, textColor),
          _periodButton('Year', 2, textColor),
        ],
      ),
    );
  }

  Widget _periodButton(String label, int index, Color textColor) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (widget.isDarkMode ? Colors.white : Colors.black)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? (widget.isDarkMode ? Colors.black : Colors.white)
                  : textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color? subtleTextColor,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Completed',
              value: '48',
              subtitle: '+12% from last week',
              color: Colors.green,
              icon: Icons.check_circle,
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: textColor,
              subtleTextColor: subtleTextColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Pending',
              value: '12',
              subtitle: '3 due today',
              color: Colors.orange,
              icon: Icons.pending,
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: textColor,
              subtleTextColor: subtleTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color? subtleTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
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
                  color: subtleTextColor,
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
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: subtleTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskHeatmap() {
    final Map<DateTime, int> completionData = _getSampleCompletionData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TaskCompletionHeatmap(
        completionData: completionData,
        selectedPeriod: _selectedPeriod == 0 ? 'Week' :
        _selectedPeriod == 1 ? 'Month' : 'Year',
        isDarkMode: widget.isDarkMode,
      ),
    );
  }

  Map<DateTime, int> _getSampleCompletionData() {
    final Map<DateTime, int> data = {};
    final now = DateTime.now();

    for (int i = 0; i < 84; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));

      if (i % 3 == 0) {
        data[date] = (i % 9);
      }
    }

    return data;
  }

  Widget _buildChartCard({
    required String title,
    required Widget child,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildLineChart(Color borderColor, Color? subtleTextColor, Color textColor) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: borderColor,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: subtleTextColor,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        days[value.toInt()],
                        style: TextStyle(
                          color: subtleTextColor,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
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
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 65),
                FlSpot(1, 75),
                FlSpot(2, 70),
                FlSpot(3, 85),
                FlSpot(4, 80),
                FlSpot(5, 90),
                FlSpot(6, 88),
              ],
              isCurved: true,
              color: widget.isDarkMode ? Colors.white : Colors.black,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                    strokeWidth: 2,
                    strokeColor: widget.isDarkMode ? Colors.white : Colors.black,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: widget.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
          ],
          minY: 0,
          maxY: 100,
        ),
      ),
    );
  }

  Widget _buildPieChart(Color textColor) {
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
                sections: [
                  PieChartSectionData(
                    value: 40,
                    title: '40%',
                    color: Colors.blue,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 30,
                    title: '30%',
                    color: Colors.purple,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: Colors.teal,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 10,
                    title: '10%',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Work', Colors.blue, textColor),
                _buildLegendItem('Personal', Colors.purple, textColor),
                _buildLegendItem('Health', Colors.teal, textColor),
                _buildLegendItem('Shopping', Colors.orange, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Color borderColor, Color? subtleTextColor) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 30,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: subtleTextColor,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const priorities = ['High', 'Medium', 'Low'];
                  if (value.toInt() >= 0 && value.toInt() < priorities.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        priorities[value.toInt()],
                        style: TextStyle(
                          color: subtleTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
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
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: borderColor,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 25,
                  color: Colors.red.shade600,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 20,
                  color: Colors.orange.shade600,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 15,
                  color: Colors.teal.shade600,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TASK COMPLETION HEATMAP WITH DARK MODE
// ============================================================================

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
            Colors.deepPurple.shade700,
            Colors.deepPurple.shade500,
          ]
              : [
            Colors.orange.shade800,
            Colors.orange.shade600,
          ],
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
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStats(),
          const SizedBox(height: 20),
          _buildHeatmapGrid(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final total = completionData.values.fold(0, (sum, val) => sum + val);
    final days = completionData.length;
    final percentage = days > 0 ? ((total / days) * 10).toStringAsFixed(0) : '0';

    return Row(
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
        Text(
          '$percentage%',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapGrid() {
    List<List<_DayData>> weeks;

    if (selectedPeriod == 'Week') {
      weeks = _generateWeekData();
    } else if (selectedPeriod == 'Month') {
      weeks = _generateMonthData();
    } else {
      weeks = _generateYearData();
    }

    return Column(
      children: weeks.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: entry.value.map((day) {
              return Expanded(
                child: Container(
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: _getHeatmapColor(day.taskCount),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: day.taskCount > 0
                      ? Center(
                    child: Text(
                      day.taskCount.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: day.taskCount >= 5
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  )
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  List<List<_DayData>> _generateWeekData() {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final dateKey = DateTime(date.year, date.month, date.day);
      return _DayData(
        date: dateKey,
        taskCount: completionData[dateKey] ?? 0,
      );
    });
    return [days];
  }

  List<List<_DayData>> _generateMonthData() {
    final now = DateTime.now();
    final weeks = <List<_DayData>>[];

    for (int week = 3; week >= 0; week--) {
      final weekDays = <_DayData>[];
      for (int day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: (week * 7) + (6 - day)));
        final dateKey = DateTime(date.year, date.month, date.day);
        weekDays.add(_DayData(
          date: dateKey,
          taskCount: completionData[dateKey] ?? 0,
        ));
      }
      weeks.add(weekDays);
    }

    return weeks;
  }

  List<List<_DayData>> _generateYearData() {
    final now = DateTime.now();
    final weeks = <List<_DayData>>[];

    for (int week = 11; week >= 0; week--) {
      final weekDays = <_DayData>[];
      for (int day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: (week * 7) + (6 - day)));
        final dateKey = DateTime(date.year, date.month, date.day);
        weekDays.add(_DayData(
          date: dateKey,
          taskCount: completionData[dateKey] ?? 0,
        ));
      }
      weeks.add(weekDays);
    }

    return weeks;
  }

  Color _getHeatmapColor(int taskCount) {
    if (taskCount == 0) {
      return Colors.white.withOpacity(0.15);
    } else if (taskCount <= 2) {
      return Colors.white.withOpacity(0.3);
    } else if (taskCount <= 4) {
      return Colors.white.withOpacity(0.5);
    } else if (taskCount <= 6) {
      return Colors.white.withOpacity(0.7);
    } else {
      return Colors.white.withOpacity(0.9);
    }
  }
}

class _DayData {
  final DateTime date;
  final int taskCount;

  _DayData({required this.date, required this.taskCount});
}
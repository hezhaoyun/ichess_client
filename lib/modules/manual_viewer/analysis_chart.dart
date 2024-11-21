import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalysisChart extends StatefulWidget {
  final List<double> evaluations;
  final int currentMoveIndex;
  final Function(int) onPositionChanged;

  const AnalysisChart({
    super.key,
    required this.evaluations,
    required this.currentMoveIndex,
    required this.onPositionChanged,
  });

  @override
  State<AnalysisChart> createState() => _AnalysisChartState();
}

class _AnalysisChartState extends State<AnalysisChart> {
  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: widget.evaluations
                      .asMap()
                      .entries
                      .map(
                        (e) => FlSpot(e.key.toDouble(), e.value),
                      )
                      .toList(),
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                  if (event is FlTapUpEvent) {
                    final x = response?.lineBarSpots?.first.x.toInt();
                    if (x != null) widget.onPositionChanged(x);
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (value) => Theme.of(context).colorScheme.surface,
                ),
              ),
              extraLinesData: ExtraLinesData(
                verticalLines: [
                  VerticalLine(
                    x: widget.currentMoveIndex.toDouble(),
                    color: Colors.red,
                    strokeWidth: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

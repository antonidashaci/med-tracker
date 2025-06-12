import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine_history.dart';

class AdvancedChartCard extends StatefulWidget {
  final List<MedicineHistory> history;
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final List<String> chartPeriods;

  const AdvancedChartCard({
    super.key,
    required this.history,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.chartPeriods,
  });

  @override
  State<AdvancedChartCard> createState() => _AdvancedChartCardState();
}

class _AdvancedChartCardState extends State<AdvancedChartCard> {
  String _selectedChartType = 'Uyumluluk';
  final List<String> _chartTypes = ['Uyumluluk', 'Günlük Alım', 'Zaman Analizi'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.tertiaryText.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                CupertinoIcons.chart_bar_alt_fill,
                size: 20,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Detaylı Analiz',
                style: AppTheme.headline3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showChartTypePicker(),
                child: Text(
                  _selectedChartType,
                  style: AppTheme.body2.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showPeriodPicker(),
                child: Text(
                  widget.selectedPeriod,
                  style: AppTheme.body2.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart
          Container(
            height: 200,
            child: _buildSelectedChart(),
          ),

          const SizedBox(height: 16),

          // Statistics
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildSelectedChart() {
    switch (_selectedChartType) {
      case 'Uyumluluk':
        return _buildComplianceChart();
      case 'Günlük Alım':
        return _buildDailyIntakeChart();
      case 'Zaman Analizi':
        return _buildTimeAnalysisChart();
      default:
        return _buildComplianceChart();
    }
  }

  Widget _buildComplianceChart() {
    final data = _getComplianceData();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.tertiaryText.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.tertiaryText.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      data[value.toInt()]['date'],
                      style: AppTheme.caption.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()}%',
                    style: AppTheme.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppColors.tertiaryText.withOpacity(0.2),
          ),
        ),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value['compliance'].toDouble());
            }).toList(),
            isCurved: true,
            color: AppColors.primaryBlue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primaryBlue,
                  strokeWidth: 2,
                  strokeColor: AppColors.secondaryBackground,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryBlue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyIntakeChart() {
    final data = _getDailyIntakeData();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.fold<double>(0, (max, item) => 
          item['taken'] + item['missed'] > max ? item['taken'] + item['missed'] : max
        ) + 1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppColors.primaryText,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} alım',
                AppTheme.body2.copyWith(color: AppColors.secondaryBackground),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      data[value.toInt()]['date'],
                      style: AppTheme.caption.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: AppTheme.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppColors.tertiaryText.withOpacity(0.2),
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item['taken'].toDouble(),
                color: AppColors.success,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: item['missed'].toDouble(),
                color: AppColors.error,
                width: 16,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeAnalysisChart() {
    final data = _getTimeAnalysisData();
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.map((item) {
          return PieChartSectionData(
            color: item['color'],
            value: item['value'].toDouble(),
            title: '${item['percentage']}%',
            radius: 50,
            titleStyle: AppTheme.caption.copyWith(
              color: AppColors.secondaryBackground,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatistics() {
    final stats = _getStatistics();
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Ortalama Uyumluluk',
                '${stats['avgCompliance']}%',
                CupertinoIcons.chart_bar,
                AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                'En İyi Gün',
                stats['bestDay'],
                CupertinoIcons.trophy,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'En Kötü Gün',
                stats['worstDay'],
                CupertinoIcons.exclamationmark_triangle,
                AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                'Toplam Alım',
                stats['totalIntake'].toString(),
                CupertinoIcons.pill,
                AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headline3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getComplianceData() {
    final filteredHistory = _getFilteredHistory();
    final data = <Map<String, dynamic>>[];
    
    // Son 7 gün için günlük uyumluluk hesapla
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayHistory = filteredHistory.where((h) {
        final historyDate = DateTime(h.takenAt.year, h.takenAt.month, h.takenAt.day);
        return historyDate.isAtSameMomentAs(date);
      }).toList();
      
      final compliance = dayHistory.isEmpty ? 0 : 
        ((dayHistory.where((h) => h.wasOnTime).length / dayHistory.length) * 100).round();
      
      data.add({
        'date': '${date.day}/${date.month}',
        'compliance': compliance,
      });
    }
    
    return data;
  }

  List<Map<String, dynamic>> _getDailyIntakeData() {
    final filteredHistory = _getFilteredHistory();
    final data = <Map<String, dynamic>>[];
    
    // Son 7 gün için günlük alım verileri
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayHistory = filteredHistory.where((h) {
        final historyDate = DateTime(h.takenAt.year, h.takenAt.month, h.takenAt.day);
        return historyDate.isAtSameMomentAs(date);
      }).toList();
      
      data.add({
        'date': '${date.day}/${date.month}',
        'taken': dayHistory.where((h) => h.wasOnTime).length,
        'missed': dayHistory.where((h) => !h.wasOnTime).length,
      });
    }
    
    return data;
  }

  List<Map<String, dynamic>> _getTimeAnalysisData() {
    final filteredHistory = _getFilteredHistory();
    final timeSlots = <String, int>{};
    
    for (final history in filteredHistory) {
      final hour = history.takenAt.hour;
      String timeSlot;
      
      if (hour < 6) timeSlot = 'Gece';
      else if (hour < 12) timeSlot = 'Sabah';
      else if (hour < 18) timeSlot = 'Öğlen';
      else timeSlot = 'Akşam';
      
      timeSlots[timeSlot] = (timeSlots[timeSlot] ?? 0) + 1;
    }
    
    final total = timeSlots.values.fold(0, (sum, count) => sum + count);
    final colors = [AppColors.primaryBlue, AppColors.success, AppColors.warning, AppColors.error];
    
    return timeSlots.entries.map((entry) {
      final percentage = total > 0 ? ((entry.value / total) * 100).round() : 0;
      final colorIndex = timeSlots.keys.toList().indexOf(entry.key);
      
      return {
        'label': entry.key,
        'value': entry.value,
        'percentage': percentage,
        'color': colors[colorIndex % colors.length],
      };
    }).toList();
  }

  Map<String, dynamic> _getStatistics() {
    final filteredHistory = _getFilteredHistory();
    
    if (filteredHistory.isEmpty) {
      return {
        'avgCompliance': 0,
        'bestDay': 'Yok',
        'worstDay': 'Yok',
        'totalIntake': 0,
      };
    }
    
    // Ortalama uyumluluk
    final totalCompliance = filteredHistory.where((h) => h.wasOnTime).length;
    final avgCompliance = ((totalCompliance / filteredHistory.length) * 100).round();
    
    // En iyi ve en kötü günler
    final dailyStats = <DateTime, double>{};
    for (final history in filteredHistory) {
      final date = DateTime(history.takenAt.year, history.takenAt.month, history.takenAt.day);
      final dayHistory = filteredHistory.where((h) {
        final hDate = DateTime(h.takenAt.year, h.takenAt.month, h.takenAt.day);
        return hDate.isAtSameMomentAs(date);
      }).toList();
      
      final compliance = dayHistory.isEmpty ? 0.0 : 
        dayHistory.where((h) => h.wasOnTime).length / dayHistory.length;
      
      dailyStats[date] = compliance;
    }
    
    final sortedDays = dailyStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final bestDay = sortedDays.isNotEmpty ? 
      '${sortedDays.first.key.day}/${sortedDays.first.key.month}' : 'Yok';
    final worstDay = sortedDays.isNotEmpty ? 
      '${sortedDays.last.key.day}/${sortedDays.last.key.month}' : 'Yok';
    
    return {
      'avgCompliance': avgCompliance,
      'bestDay': bestDay,
      'worstDay': worstDay,
      'totalIntake': filteredHistory.length,
    };
  }

  List<MedicineHistory> _getFilteredHistory() {
    final now = DateTime.now();
    
    switch (widget.selectedPeriod) {
      case 'Son 7 gün':
        final weekAgo = now.subtract(const Duration(days: 7));
        return widget.history.where((h) => h.takenAt.isAfter(weekAgo)).toList();
      case 'Son 30 gün':
        final monthAgo = now.subtract(const Duration(days: 30));
        return widget.history.where((h) => h.takenAt.isAfter(monthAgo)).toList();
      case 'Son 3 ay':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return widget.history.where((h) => h.takenAt.isAfter(threeMonthsAgo)).toList();
      default:
        return widget.history;
    }
  }

  void _showChartTypePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 200,
        color: AppColors.secondaryBackground,
        child: Column(
          children: [
            Container(
              height: 40,
              color: AppColors.tertiaryBackground,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('İptal'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Tamam'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedChartType = _chartTypes[index];
                  });
                },
                children: _chartTypes.map((type) => Center(
                  child: Text(type),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 200,
        color: AppColors.secondaryBackground,
        child: Column(
          children: [
            Container(
              height: 40,
              color: AppColors.tertiaryBackground,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('İptal'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Tamam'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  widget.onPeriodChanged(widget.chartPeriods[index]);
                },
                children: widget.chartPeriods.map((period) => Center(
                  child: Text(period),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
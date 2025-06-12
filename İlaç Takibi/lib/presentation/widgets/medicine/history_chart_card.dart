import 'package:flutter/cupertino.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine_history.dart';

class HistoryChartCard extends StatelessWidget {
  final List<MedicineHistory> history;
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final List<String> chartPeriods;

  const HistoryChartCard({
    super.key,
    required this.history,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.chartPeriods,
  });

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _getFilteredHistory();
    final chartData = _generateChartData(filteredHistory);

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
          Row(
            children: [
              const Icon(
                CupertinoIcons.chart_bar,
                size: 20,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'İlaç Alma Geçmişi',
                style: AppTheme.headline3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showPeriodPicker(context),
                child: Text(
                  selectedPeriod,
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
          if (chartData.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.tertiaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Henüz veri yok',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            )
          else
            Container(
              height: 120,
              child: _buildSimpleChart(chartData),
            ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Alındı', AppColors.success),
              const SizedBox(width: 24),
              _buildLegendItem('Kaçırıldı', AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  List<MedicineHistory> _getFilteredHistory() {
    final now = DateTime.now();
    
    switch (selectedPeriod) {
      case 'Son 7 gün':
        final weekAgo = now.subtract(const Duration(days: 7));
        return history.where((h) => h.takenAt.isAfter(weekAgo)).toList();
      case 'Son 30 gün':
        final monthAgo = now.subtract(const Duration(days: 30));
        return history.where((h) => h.takenAt.isAfter(monthAgo)).toList();
      case 'Son 3 ay':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return history.where((h) => h.takenAt.isAfter(threeMonthsAgo)).toList();
      default:
        return history;
    }
  }

  List<Map<String, dynamic>> _generateChartData(List<MedicineHistory> filteredHistory) {
    final data = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    int daysToShow;
    switch (selectedPeriod) {
      case 'Son 7 gün':
        daysToShow = 7;
        break;
      case 'Son 30 gün':
        daysToShow = 30;
        break;
      case 'Son 3 ay':
        daysToShow = 90;
        break;
      default:
        daysToShow = 7;
    }

    for (int i = daysToShow - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayHistory = filteredHistory.where((h) {
        final historyDate = DateTime(h.takenAt.year, h.takenAt.month, h.takenAt.day);
        return historyDate.isAtSameMomentAs(date);
      }).toList();

      data.add({
        'date': date,
        'taken': dayHistory.where((h) => h.wasOnTime).length,
        'missed': dayHistory.where((h) => !h.wasOnTime).length,
        'total': dayHistory.length,
      });
    }

    return data;
  }

  Widget _buildSimpleChart(List<Map<String, dynamic>> chartData) {
    final maxValue = chartData.fold<int>(0, (max, item) {
      final total = (item['taken'] as int) + (item['missed'] as int);
      return total > max ? total : max;
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: chartData.map((data) {
        final taken = data['taken'] as int;
        final missed = data['missed'] as int;
        final total = taken + missed;
        
        final maxHeight = 100.0;
        final takenHeight = maxValue > 0 ? (taken / maxValue) * maxHeight : 0.0;
        final missedHeight = maxValue > 0 ? (missed / maxValue) * maxHeight : 0.0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                if (total > 0) ...[
                  Container(
                    width: 8,
                    height: takenHeight,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  if (missed > 0) ...[
                    const SizedBox(height: 2),
                    Container(
                      width: 8,
                      height: missedHeight,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ] else ...[
                  Container(
                    width: 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryText,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatDateLabel(data['date'] as DateTime),
                  style: AppTheme.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) {
      return 'Bugün';
    } else if (dateOnly.isAtSameMomentAs(yesterday)) {
      return 'Dün';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showPeriodPicker(BuildContext context) {
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
                  onPeriodChanged(chartPeriods[index]);
                },
                children: chartPeriods.map((period) => Center(
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
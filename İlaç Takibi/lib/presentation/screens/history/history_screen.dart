import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/medicine_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/history/history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedPeriod = 'Son 7 gün';
  final List<String> _periods = [
    'Bugün',
    'Son 7 gün',
    'Son 30 gün',
    'Son 3 ay',
    'Tüm zamanlar',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().loadMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Geçmiş'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showPeriodPicker,
          child: const Icon(CupertinoIcons.calendar),
        ),
      ),
      child: SafeArea(
        child: Consumer<MedicineProvider>(
          builder: (context, medicineProvider, child) {
            if (medicineProvider.isLoading) {
              return const LoadingWidget();
            }

            final history = _getFilteredHistory(medicineProvider);
            final statistics = _getHistoryStatistics(history);

            return CustomScrollView(
              slivers: [
                // Statistics
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İstatistikler',
                          style: AppTheme.headline2,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Toplam',
                                statistics['total'].toString(),
                                CupertinoIcons.pill,
                                AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Zamanında',
                                statistics['onTime'].toString(),
                                CupertinoIcons.checkmark_circle,
                                AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Gecikmeli',
                                statistics['late'].toString(),
                                CupertinoIcons.exclamationmark_circle,
                                AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Uyumluluk',
                                '${statistics['compliance']}%',
                                CupertinoIcons.chart_bar,
                                AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Period selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.calendar,
                            size: 16,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dönem: $_selectedPeriod',
                            style: AppTheme.body2.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),

                // History list
                if (history.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.clock,
                            size: 64,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz ilaç alma geçmişi yok',
                            style: AppTheme.headline2.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'İlaç aldığınızda burada görünecek',
                            style: AppTheme.body2.copyWith(
                              color: AppColors.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final historyItem = history[index];
                        final medicine = medicineProvider.getMedicineById(historyItem.medicineId);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          child: HistoryItem(
                            history: historyItem,
                            medicine: medicine,
                          ),
                        );
                      },
                      childCount: history.length,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.headline2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.body2.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredHistory(MedicineProvider provider) {
    final allHistory = provider.getTodayHistory();
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'Bugün':
        return allHistory;
      case 'Son 7 gün':
        final weekAgo = now.subtract(const Duration(days: 7));
        return allHistory.where((h) => h.takenAt.isAfter(weekAgo)).toList();
      case 'Son 30 gün':
        final monthAgo = now.subtract(const Duration(days: 30));
        return allHistory.where((h) => h.takenAt.isAfter(monthAgo)).toList();
      case 'Son 3 ay':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return allHistory.where((h) => h.takenAt.isAfter(threeMonthsAgo)).toList();
      case 'Tüm zamanlar':
        return allHistory;
      default:
        return allHistory;
    }
  }

  Map<String, int> _getHistoryStatistics(List<dynamic> history) {
    final total = history.length;
    final onTime = history.where((h) => h.wasOnTime).length;
    final late = total - onTime;
    final compliance = total > 0 ? ((onTime / total) * 100).round() : 0;

    return {
      'total': total,
      'onTime': onTime,
      'late': late,
      'compliance': compliance,
    };
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
                  setState(() {
                    _selectedPeriod = _periods[index];
                  });
                },
                children: _periods.map((period) => Center(
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
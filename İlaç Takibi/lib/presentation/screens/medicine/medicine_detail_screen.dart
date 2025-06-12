import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine.dart';
import '../../../data/models/medicine_history.dart';
import '../../providers/medicine_provider.dart';
import '../../widgets/medicine/medicine_info_card.dart';
import '../../widgets/medicine/reminder_list_card.dart';
import '../../widgets/medicine/history_chart_card.dart';
import '../../widgets/medicine/history_list_card.dart';
import '../../widgets/medicine/advanced_chart_card.dart';
import '../../../routes/app_routes.dart';
import 'qr_generator_screen.dart';
import 'stock_update_screen.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailScreen({
    super.key,
    required this.medicine,
  });

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  String _selectedChartPeriod = 'Son 7 gün';
  final List<String> _chartPeriods = [
    'Son 7 gün',
    'Son 30 gün',
    'Son 3 ay',
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.medicine.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.medicine.stockCount != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _openStockUpdate(),
                child: const Icon(CupertinoIcons.cube_box),
              ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _openQRGenerator(),
              child: const Icon(CupertinoIcons.qrcode),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.editMedicine,
                arguments: widget.medicine,
              ),
              child: const Icon(CupertinoIcons.pencil),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Consumer<MedicineProvider>(
          builder: (context, medicineProvider, child) {
            final history = medicineProvider.getMedicineHistory(widget.medicine.id);
            final statistics = _getMedicineStatistics(history);

            return CustomScrollView(
              slivers: [
                // İlaç Bilgileri
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MedicineInfoCard(
                      medicine: widget.medicine,
                      statistics: statistics,
                      onToggleActive: () => medicineProvider.toggleMedicineActive(widget.medicine.id),
                      onMarkTaken: () => _markMedicineTaken(widget.medicine),
                    ),
                  ),
                ),

                // Stok ve Etkileşim Bilgileri
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildStockAndInteractionInfo(),
                  ),
                ),

                // Hatırlatıcılar
                if (widget.medicine.reminders.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ReminderListCard(
                        reminders: widget.medicine.reminders,
                        onReminderToggle: (reminderId, isActive) {
                          // TODO: Update reminder active status
                        },
                      ),
                    ),
                  ),

                // Grafik
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: HistoryChartCard(
                      history: history,
                      selectedPeriod: _selectedChartPeriod,
                      onPeriodChanged: (period) {
                        setState(() {
                          _selectedChartPeriod = period;
                        });
                      },
                      chartPeriods: _chartPeriods,
                    ),
                  ),
                ),

                // Gelişmiş Grafik
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AdvancedChartCard(
                      history: history,
                      selectedPeriod: _selectedChartPeriod,
                      onPeriodChanged: (period) {
                        setState(() {
                          _selectedChartPeriod = period;
                        });
                      },
                      chartPeriods: _chartPeriods,
                    ),
                  ),
                ),

                // Geçmiş Listesi
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: HistoryListCard(
                      history: history,
                      onHistoryItemTap: (historyItem) {
                        // TODO: Show history item details
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Map<String, dynamic> _getMedicineStatistics(List<MedicineHistory> history) {
    final total = history.length;
    final onTime = history.where((h) => h.wasOnTime).length;
    final late = total - onTime;
    final compliance = total > 0 ? ((onTime / total) * 100).round() : 0;

    // Calculate streak
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    final sortedHistory = List<MedicineHistory>.from(history)
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));

    for (int i = 0; i < sortedHistory.length; i++) {
      if (i == 0) {
        tempStreak = 1;
        currentStreak = 1;
      } else {
        final currentDate = DateTime(
          sortedHistory[i].takenAt.year,
          sortedHistory[i].takenAt.month,
          sortedHistory[i].takenAt.day,
        );
        final previousDate = DateTime(
          sortedHistory[i - 1].takenAt.year,
          sortedHistory[i - 1].takenAt.month,
          sortedHistory[i - 1].takenAt.day,
        );
        
        final difference = previousDate.difference(currentDate).inDays;
        
        if (difference == 1) {
          tempStreak++;
          if (i == 0) currentStreak = tempStreak;
        } else {
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 1;
        }
      }
    }
    
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    return {
      'total': total,
      'onTime': onTime,
      'late': late,
      'compliance': compliance,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  void _markMedicineTaken(Medicine medicine) {
    // Check for interactions before marking as taken
    final medicineProvider = context.read<MedicineProvider>();
    final interactions = medicineProvider.checkInteractions(medicine);
    
    if (interactions.isNotEmpty) {
      _showInteractionWarning(interactions, () => _showMarkTakenDialog(medicine));
    } else {
      _showMarkTakenDialog(medicine);
    }
  }

  void _showInteractionWarning(List<Medicine> interactions, VoidCallback onContinue) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('İlaç Etkileşimi'),
        content: Column(
          children: [
            const Text('Bu ilaç aşağıdaki ilaçlarla etkileşime girebilir:'),
            const SizedBox(height: 12),
            ...interactions.map((med) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• ${med.name}', style: AppTheme.body2),
            )),
            const SizedBox(height: 12),
            const Text('İlaç alımına devam etmek istediğinizden emin misiniz?'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Devam Et'),
            onPressed: () {
              Navigator.of(context).pop();
              onContinue();
            },
          ),
        ],
      ),
    );
  }

  void _showMarkTakenDialog(Medicine medicine) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('İlaç Alındı'),
        content: Column(
          children: [
            Text('${medicine.name} alındı olarak işaretlendi.'),
            const SizedBox(height: 16),
            CupertinoTextField(
              placeholder: 'Not ekleyin (opsiyonel)',
              maxLines: 3,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.tertiaryText),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Kaydet'),
            onPressed: () async {
              // TODO: Get notes from text field
              await context.read<MedicineProvider>().markMedicineTaken(
                medicine.id,
                notes: 'Test not',
              );
              Navigator.of(context).pop();
              setState(() {}); // Refresh UI
            },
          ),
        ],
      ),
    );
  }

  void _openStockUpdate() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => StockUpdateScreen(medicine: widget.medicine),
      ),
    );
  }

  void _openQRGenerator() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => QRGeneratorScreen(medicine: widget.medicine),
      ),
    );
  }

  Widget _buildStockAndInteractionInfo() {
    final stock = widget.medicine.stockCount;
    final threshold = widget.medicine.stockThreshold;
    final interactionIds = widget.medicine.interactionIds ?? [];
    final allMedicines = context.read<MedicineProvider>().medicines;
    final interactions = allMedicines.where((m) => interactionIds.contains(m.id)).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stock != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: stock <= (threshold ?? 0) 
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: stock <= (threshold ?? 0) 
                    ? AppColors.error.withOpacity(0.3)
                    : AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  stock <= (threshold ?? 0) 
                      ? CupertinoIcons.exclamationmark_triangle
                      : CupertinoIcons.cube_box,
                  size: 18,
                  color: stock <= (threshold ?? 0) 
                      ? AppColors.error
                      : AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stok: $stock adet',
                  style: AppTheme.body1.copyWith(
                    color: stock <= (threshold ?? 0) 
                        ? AppColors.error
                        : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (threshold != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Uyarı eşiği: $threshold',
                    style: AppTheme.body2.copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ],
            ),
          ),
        if (interactions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Etkileşimli İlaçlar:',
                      style: AppTheme.body1.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: interactions.map((m) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m.name,
                      style: AppTheme.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
} 
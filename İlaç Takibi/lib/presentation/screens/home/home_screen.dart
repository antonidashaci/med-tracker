import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine.dart';
import '../../providers/medicine_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/home/statistics_card.dart';
import '../../widgets/home/medicine_card.dart';
import '../settings/settings_screen.dart';
import '../../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().loadMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: 'Geçmiş',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return _buildHomeTab();
          case 1:
            return _buildHistoryTab();
          case 2:
            return const SettingsScreen();
          default:
            return _buildHomeTab();
        }
      },
    );
  }

  Widget _buildHomeTab() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('İlaç Takibi'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addMedicine),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Consumer<MedicineProvider>(
          builder: (context, medicineProvider, child) {
            if (medicineProvider.isLoading) {
              return const LoadingWidget();
            }

            final medicines = medicineProvider.medicines;
            final activeMedicines = medicines.where((m) => m.isActive).toList();
            final todayMedicines = _getTodayMedicines(activeMedicines);
            final lowStockMedicines = medicineProvider.getLowStockMedicines();

            return CustomScrollView(
              slivers: [
                // İstatistikler
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bugün',
                          style: AppTheme.headline1,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: StatisticsCard(
                                title: 'Toplam İlaç',
                                value: activeMedicines.length.toString(),
                                icon: CupertinoIcons.pill,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatisticsCard(
                                title: 'Bugün Alınacak',
                                value: todayMedicines.length.toString(),
                                icon: CupertinoIcons.time,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatisticsCard(
                                title: 'Alınan',
                                value: _getTakenTodayCount(activeMedicines).toString(),
                                icon: CupertinoIcons.checkmark_circle,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatisticsCard(
                                title: 'Kaçırılan',
                                value: _getMissedTodayCount(activeMedicines).toString(),
                                icon: CupertinoIcons.exclamationmark_circle,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Stok Uyarıları
                if (lowStockMedicines.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildStockAlertCard(lowStockMedicines),
                    ),
                  ),

                // İlaçlar
                if (activeMedicines.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.pill,
                            size: 64,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz ilaç eklenmemiş',
                            style: AppTheme.headline2.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'İlk ilacınızı eklemek için + butonuna tıklayın',
                            style: AppTheme.body2.copyWith(
                              color: AppColors.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          CupertinoButton.filled(
                            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addMedicine),
                            child: const Text('İlaç Ekle'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final medicine = activeMedicines[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          child: MedicineCard(
                            medicine: medicine,
                            onEdit: (medicine) => Navigator.of(context).pushNamed(
                              AppRoutes.editMedicine,
                              arguments: medicine,
                            ),
                            onDelete: (medicineId) => _showDeleteConfirmation(medicine),
                            onMarkAsTaken: (medicineId, dosage) => _markMedicineTaken(medicine),
                          ),
                        );
                      },
                      childCount: activeMedicines.length,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Geçmiş'),
      ),
      child: SafeArea(
        child: Consumer<MedicineProvider>(
          builder: (context, medicineProvider, child) {
            if (medicineProvider.isLoading) {
              return const LoadingWidget();
            }

            final history = medicineProvider.getTodayHistory();
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
                          child: _buildHistoryItem(historyItem, medicine),
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

  Widget _buildHistoryItem(dynamic historyItem, Medicine? medicine) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      historyItem.medicineName,
                      style: AppTheme.headline3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${historyItem.dosage} • ${_formatDateTime(historyItem.takenAt)}',
                      style: AppTheme.body2.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: historyItem.wasOnTime 
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      historyItem.wasOnTime 
                          ? CupertinoIcons.checkmark_circle
                          : CupertinoIcons.exclamationmark_circle,
                      size: 14,
                      color: historyItem.wasOnTime 
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      historyItem.wasOnTime ? 'Zamanında' : 'Gecikmeli',
                      style: AppTheme.caption.copyWith(
                        color: historyItem.wasOnTime 
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateString;
    if (date.isAtSameMomentAs(today)) {
      dateString = 'Bugün';
    } else if (date.isAtSameMomentAs(yesterday)) {
      dateString = 'Dün';
    } else {
      dateString = '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
    }
    
    final timeString = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateString $timeString';
  }

  List<Medicine> _getTodayMedicines(List<Medicine> medicines) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return medicines.where((medicine) {
      return medicine.reminders.any((reminder) {
        if (!reminder.isActive) return false;
        
        // Bugün hatırlatıcı aktif mi?
        final weekday = now.weekday;
        if (!reminder.days.contains(weekday)) return false;
        
        // İlaç aktif mi?
        if (!medicine.isActive) return false;
        
        // Tarih aralığında mı?
        if (today.isBefore(medicine.startDate)) return false;
        if (medicine.endDate != null && today.isAfter(medicine.endDate!)) return false;
        
        return true;
      });
    }).toList();
  }

  int _getTakenTodayCount(List<Medicine> medicines) {
    final medicineProvider = context.read<MedicineProvider>();
    final todayHistory = medicineProvider.getTodayHistory();
    return todayHistory.length;
  }

  int _getMissedTodayCount(List<Medicine> medicines) {
    final medicineProvider = context.read<MedicineProvider>();
    final statistics = medicineProvider.getStatistics();
    return statistics['missedToday'] ?? 0;
  }

  void _markMedicineTaken(Medicine medicine) {
    final medicineProvider = context.read<MedicineProvider>();
    medicineProvider.markMedicineTaken(medicine.id);
  }

  Widget _buildStockAlertCard(List<Medicine> lowStockMedicines) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Stok Uyarısı',
                style: AppTheme.headline3.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${lowStockMedicines.length} ilacın stok seviyesi düşük:',
            style: AppTheme.body2.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          ...lowStockMedicines.map((medicine) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  '• ${medicine.name}',
                  style: AppTheme.body1,
                ),
                const Spacer(),
                Text(
                  '${medicine.stockCount} adet',
                  style: AppTheme.body2.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Medicine medicine) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('İlaç Sil'),
        content: Text('${medicine.name} ilacını silmek istediğinize emin misiniz?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Sil'),
            onPressed: () => _deleteMedicine(medicine),
          ),
        ],
      ),
    );
  }

  void _deleteMedicine(Medicine medicine) {
    final medicineProvider = context.read<MedicineProvider>();
    medicineProvider.deleteMedicine(medicine.id);
    Navigator.of(context).pop();
  }
} 
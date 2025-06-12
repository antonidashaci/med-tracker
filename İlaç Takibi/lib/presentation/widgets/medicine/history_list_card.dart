import 'package:flutter/cupertino.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine_history.dart';

class HistoryListCard extends StatelessWidget {
  final List<MedicineHistory> history;
  final Function(MedicineHistory) onHistoryItemTap;

  const HistoryListCard({
    super.key,
    required this.history,
    required this.onHistoryItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final sortedHistory = List<MedicineHistory>.from(history)
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));

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
                CupertinoIcons.list_bullet,
                size: 20,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Geçmiş',
                style: AppTheme.headline3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${history.length} kayıt',
                style: AppTheme.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (sortedHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.tertiaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text,
                      size: 32,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Henüz geçmiş kaydı yok',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...sortedHistory.take(10).map((historyItem) => 
              _buildHistoryItem(historyItem),
            ),

          if (sortedHistory.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: CupertinoButton(
                  onPressed: () {
                    // TODO: Navigate to full history screen
                  },
                  child: Text(
                    'Tümünü Görüntüle (${sortedHistory.length})',
                    style: AppTheme.body2.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(MedicineHistory historyItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => onHistoryItemTap(historyItem),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.tertiaryBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: historyItem.wasOnTime 
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.error.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: historyItem.wasOnTime 
                      ? AppColors.success
                      : AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatDateTime(historyItem.takenAt),
                          style: AppTheme.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: historyItem.wasOnTime 
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            historyItem.wasOnTime ? 'Zamanında' : 'Gecikmeli',
                            style: AppTheme.caption.copyWith(
                              color: historyItem.wasOnTime 
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (historyItem.notes != null && historyItem.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        historyItem.notes!,
                        style: AppTheme.body2.copyWith(
                          color: AppColors.secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String datePrefix;
    if (dateOnly.isAtSameMomentAs(today)) {
      datePrefix = 'Bugün';
    } else if (dateOnly.isAtSameMomentAs(yesterday)) {
      datePrefix = 'Dün';
    } else {
      datePrefix = '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}';
    }

    final timeString = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$datePrefix $timeString';
  }
} 
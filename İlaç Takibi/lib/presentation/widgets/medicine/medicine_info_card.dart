import 'package:flutter/cupertino.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine.dart';

class MedicineInfoCard extends StatelessWidget {
  final Medicine medicine;
  final Map<String, dynamic> statistics;
  final VoidCallback onToggleActive;
  final VoidCallback onMarkTaken;

  const MedicineInfoCard({
    super.key,
    required this.medicine,
    required this.statistics,
    required this.onToggleActive,
    required this.onMarkTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.tertiaryText.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: AppTheme.headline1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${medicine.dosage} ${medicine.dosageUnit} • ${medicine.frequency}',
                      style: AppTheme.body1.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: medicine.isActive,
                onChanged: (_) => onToggleActive(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category and dates
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  medicine.category,
                  style: AppTheme.body2.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (medicine.endDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: medicine.isExpired 
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    medicine.isExpired ? 'Süresi Dolmuş' : 'Aktif',
                    style: AppTheme.body2.copyWith(
                      color: medicine.isExpired 
                          ? AppColors.error
                          : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Date range
          Row(
            children: [
              Expanded(
                child: _buildDateInfo(
                  'Başlangıç',
                  _formatDate(medicine.startDate),
                  CupertinoIcons.calendar,
                ),
              ),
              if (medicine.endDate != null)
                Expanded(
                  child: _buildDateInfo(
                    'Bitiş',
                    _formatDate(medicine.endDate!),
                    CupertinoIcons.calendar_badge_minus,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Statistics
          Text(
            'İstatistikler',
            style: AppTheme.headline3.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Toplam',
                  statistics['total'].toString(),
                  CupertinoIcons.pill,
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Uyumluluk',
                  '${statistics['compliance']}%',
                  CupertinoIcons.chart_bar,
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
                  'Mevcut Seri',
                  statistics['currentStreak'].toString(),
                  CupertinoIcons.flame,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'En Uzun Seri',
                  statistics['longestStreak'].toString(),
                  CupertinoIcons.trophy,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: CupertinoButton.filled(
                  onPressed: onMarkTaken,
                  child: const Text(
                    'Alındı',
                    style: TextStyle(
                      color: AppColors.secondaryBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: AppColors.tertiaryBackground,
                onPressed: () {
                  // TODO: Show medicine details
                },
                child: const Icon(
                  CupertinoIcons.info_circle,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),

          // Notes
          if (medicine.notes != null && medicine.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tertiaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.text_bubble,
                    size: 16,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      medicine.notes!,
                      style: AppTheme.body2.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String date, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColors.secondaryText,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.caption.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: AppTheme.body1.copyWith(
            fontWeight: FontWeight.w500,
          ),
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
          Icon(
            icon,
            size: 20,
            color: color,
          ),
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
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
} 
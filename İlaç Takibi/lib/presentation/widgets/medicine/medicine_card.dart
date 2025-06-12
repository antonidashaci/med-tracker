import 'package:flutter/cupertino.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine.dart';
import '../../../routes/app_routes.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final Function(Medicine) onEdit;
  final Function(String) onDelete;
  final Function(String, String) onMarkAsTaken;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkAsTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.medicineDetail,
              arguments: medicine,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: AppTheme.headline3,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusText(),
                            style: AppTheme.caption.copyWith(
                              color: AppColors.secondaryBackground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => onEdit(medicine),
                        child: const Icon(
                          CupertinoIcons.pencil,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => onDelete(medicine.id),
                        child: const Icon(
                          CupertinoIcons.delete,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: AppColors.secondaryText,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Doz', medicine.fullDosage),
                const SizedBox(height: 8),
                _buildInfoRow('Sıklık', medicine.frequency),
                const SizedBox(height: 8),
                _buildInfoRow('Kategori', medicine.category),
                const SizedBox(height: 8),
                _buildInfoRow('Başlangıç', _formatDate(medicine.startDate)),
                if (medicine.endDate != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Bitiş', _formatDate(medicine.endDate!)),
                ],
                if (medicine.notes != null && medicine.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Notlar', medicine.notes!),
                ],
                if (medicine.reminders.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Hatırlatıcılar',
                    style: AppTheme.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: medicine.reminders
                        .where((r) => r.isActive)
                        .map((reminder) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${reminder.timeString} ${reminder.shortDayNames.join(', ')}',
                                style: AppTheme.caption.copyWith(
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (medicine.isActive)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.tertiaryBackground,
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => onMarkAsTaken(medicine.id, medicine.dosage),
                  child: const Text(
                    'Alındı Olarak İşaretle',
                    style: TextStyle(
                      color: AppColors.secondaryBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: AppTheme.body2.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.body1,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (medicine.isExpired) return AppColors.expiredMedicine;
    if (medicine.isActive) return AppColors.activeMedicine;
    return AppColors.inactiveMedicine;
  }

  String _getStatusText() {
    if (medicine.isExpired) return 'Süresi Dolmuş';
    if (medicine.isActive) return 'Aktif';
    return 'Pasif';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
} 
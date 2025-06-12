import 'package:flutter/cupertino.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onMarkTaken;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActive,
    required this.onMarkTaken,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: AppTheme.headline3.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medicine.dosage} ${medicine.dosageUnit} • ${medicine.frequency}',
                        style: AppTheme.body2.copyWith(
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
            const SizedBox(height: 12),
            
            // Category and time info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    medicine.category,
                    style: AppTheme.caption.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                if (medicine.reminders.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.time,
                        size: 14,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getNextReminderTime(),
                        style: AppTheme.caption.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: onMarkTaken,
                    child: const Text(
                      'Alındı',
                      style: TextStyle(
                        color: AppColors.secondaryBackground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  color: AppColors.tertiaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  onPressed: onEdit,
                  child: const Icon(
                    CupertinoIcons.pencil,
                    size: 16,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getNextReminderTime() {
    if (medicine.reminders.isEmpty) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = now.weekday;
    
    // Bugün için aktif hatırlatıcıları bul
    final todayReminders = medicine.reminders.where((reminder) {
      return reminder.isActive && reminder.days.contains(weekday);
    }).toList();
    
    if (todayReminders.isEmpty) return 'Bugün yok';
    
    // En yakın hatırlatıcıyı bul
    todayReminders.sort((a, b) {
      final timeA = DateTime(today.year, today.month, today.day, a.time.hour, a.time.minute);
      final timeB = DateTime(today.year, today.month, today.day, b.time.hour, b.time.minute);
      return timeA.compareTo(timeB);
    });
    
    final nextReminder = todayReminders.first;
    final reminderTime = DateTime(today.year, today.month, today.day, nextReminder.time.hour, nextReminder.time.minute);
    
    if (reminderTime.isBefore(now)) {
      return 'Geçti';
    }
    
    final difference = reminderTime.difference(now);
    if (difference.inHours > 0) {
      return '${difference.inHours}s ${difference.inMinutes % 60}d';
    } else {
      return '${difference.inMinutes}d';
    }
  }
} 
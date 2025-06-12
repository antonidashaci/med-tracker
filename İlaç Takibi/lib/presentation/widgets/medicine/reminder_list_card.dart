import 'package:flutter/cupertino.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/reminder.dart';

class ReminderListCard extends StatelessWidget {
  final List<Reminder> reminders;
  final Function(String, bool) onReminderToggle;

  const ReminderListCard({
    super.key,
    required this.reminders,
    required this.onReminderToggle,
  });

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
          Row(
            children: [
              const Icon(
                CupertinoIcons.clock,
                size: 20,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Hatırlatıcılar',
                style: AppTheme.headline3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${reminders.where((r) => r.isActive).length}/${reminders.length}',
                style: AppTheme.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...reminders.map((reminder) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildReminderItem(reminder),
          )),
        ],
      ),
    );
  }

  Widget _buildReminderItem(Reminder reminder) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: reminder.isActive 
              ? AppColors.primaryBlue.withOpacity(0.3)
              : AppColors.tertiaryText.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.time,
                      size: 14,
                      color: reminder.isActive 
                          ? AppColors.primaryBlue
                          : AppColors.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      reminder.timeString,
                      style: AppTheme.body1.copyWith(
                        color: reminder.isActive 
                            ? AppColors.primaryText
                            : AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.daysString,
                  style: AppTheme.body2.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: reminder.isActive,
            onChanged: (value) => onReminderToggle(reminder.id, value),
          ),
        ],
      ),
    );
  }
} 
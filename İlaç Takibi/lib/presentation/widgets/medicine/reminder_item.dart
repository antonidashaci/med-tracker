import 'package:flutter/cupertino.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/reminder.dart';

class ReminderItem extends StatefulWidget {
  final Reminder reminder;
  final Function(Reminder) onUpdate;
  final Function(String) onDelete;

  const ReminderItem({
    super.key,
    required this.reminder,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ReminderItem> createState() => _ReminderItemState();
}

class _ReminderItemState extends State<ReminderItem> {
  late Reminder _reminder;

  @override
  void initState() {
    super.initState();
    _reminder = widget.reminder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hatırlatıcı',
                  style: AppTheme.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CupertinoSwitch(
                value: _reminder.isActive,
                onChanged: (value) {
                  setState(() {
                    _reminder = _reminder.copyWith(isActive: value);
                  });
                  widget.onUpdate(_reminder);
                },
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => widget.onDelete(_reminder.id),
                child: const Icon(
                  CupertinoIcons.delete,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Time
          Row(
            children: [
              const Icon(
                CupertinoIcons.time,
                size: 16,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: 8),
              Text(
                'Saat:',
                style: AppTheme.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _selectTime,
                child: Text(
                  _reminder.timeString,
                  style: AppTheme.body1.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Days
          Row(
            children: [
              const Icon(
                CupertinoIcons.calendar,
                size: 16,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: 8),
              Text(
                'Günler:',
                style: AppTheme.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  children: _buildDayChips(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDayChips() {
    const dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    
    return List.generate(7, (index) {
      final dayNumber = index + 1;
      final isSelected = _reminder.days.contains(dayNumber);
      
      return GestureDetector(
        onTap: () {
          setState(() {
            final newDays = List<int>.from(_reminder.days);
            if (isSelected) {
              newDays.remove(dayNumber);
            } else {
              newDays.add(dayNumber);
            }
            newDays.sort();
            _reminder = _reminder.copyWith(days: newDays);
          });
          widget.onUpdate(_reminder);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.tertiaryText,
            ),
          ),
          child: Text(
            dayNames[index],
            style: AppTheme.caption.copyWith(
              color: isSelected ? AppColors.secondaryBackground : AppColors.secondaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  void _selectTime() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
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
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                  2024,
                  1,
                  1,
                  _reminder.time.hour,
                  _reminder.time.minute,
                ),
                onDateTimeChanged: (dateTime) {
                  setState(() {
                    _reminder = _reminder.copyWith(
                      time: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
                    );
                  });
                  widget.onUpdate(_reminder);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
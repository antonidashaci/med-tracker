import 'package:flutter/cupertino.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

class StatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugünkü Durum',
            style: AppTheme.headline3,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Aktif İlaç',
                statistics['activeMedicines'].toString(),
                CupertinoIcons.pill,
                AppColors.primaryBlue,
              ),
              _buildStatItem(
                'Bugün Alınan',
                statistics['takenToday'].toString(),
                CupertinoIcons.checkmark_circle,
                AppColors.success,
              ),
              _buildStatItem(
                'Uyum Oranı',
                '${statistics['adherenceRate']}%',
                CupertinoIcons.chart_bar,
                AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.headline2.copyWith(
            color: color,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 
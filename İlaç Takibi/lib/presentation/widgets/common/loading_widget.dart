import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(),
          SizedBox(height: 16),
          Text(
            'Yükleniyor...',
            style: AppTheme.body1,
          ),
        ],
      ),
    );
  }
} 
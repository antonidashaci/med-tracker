import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine.dart';

class QRGeneratorScreen extends StatelessWidget {
  final Medicine medicine;

  const QRGeneratorScreen({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = _generateQRData();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('QR Kod Oluştur'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.xmark),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // İlaç Bilgileri
              Container(
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
                    Text(
                      medicine.name,
                      style: AppTheme.headline2.copyWith(
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
                    const SizedBox(height: 4),
                    Text(
                      'Kategori: ${medicine.category}',
                      style: AppTheme.body2.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // QR Kod
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.tertiaryText.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: AppColors.secondaryBackground,
                      foregroundColor: AppColors.primaryText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'QR Kod',
                      style: AppTheme.headline3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu QR kodu başka bir cihazda tarayarak\nilaç bilgilerini hızlıca ekleyebilirsiniz',
                      style: AppTheme.body2.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Paylaş Butonu
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppColors.primaryBlue,
                  onPressed: () => _shareQRCode(context, qrData),
                  child: const Text(
                    'QR Kodu Paylaş',
                    style: TextStyle(
                      color: AppColors.secondaryBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppColors.success,
                  onPressed: () => _saveQRCode(context, qrData),
                  child: const Text(
                    'QR Kodu Kaydet',
                    style: TextStyle(
                      color: AppColors.secondaryBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateQRData() {
    // QR kod formatı: MEDICINE|name|dosage|dosageUnit|frequency|category
    return 'MEDICINE|${medicine.name}|${medicine.dosage}|${medicine.dosageUnit}|${medicine.frequency}|${medicine.category}';
  }

  void _shareQRCode(BuildContext context, String qrData) {
    // TODO: Implement sharing functionality
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Paylaş'),
        content: const Text('QR kod paylaşma özelliği yakında eklenecek.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _saveQRCode(BuildContext context, String qrData) {
    // TODO: Implement save functionality
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Kaydet'),
        content: const Text('QR kod kaydetme özelliği yakında eklenecek.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
} 
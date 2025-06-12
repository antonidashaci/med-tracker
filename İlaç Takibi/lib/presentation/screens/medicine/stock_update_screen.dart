import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine.dart';
import '../../providers/medicine_provider.dart';

class StockUpdateScreen extends StatefulWidget {
  final Medicine medicine;

  const StockUpdateScreen({
    super.key,
    required this.medicine,
  });

  @override
  State<StockUpdateScreen> createState() => _StockUpdateScreenState();
}

class _StockUpdateScreenState extends State<StockUpdateScreen> {
  final _stockController = TextEditingController();
  final _thresholdController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _stockController.text = widget.medicine.stockCount?.toString() ?? '';
    _thresholdController.text = widget.medicine.stockThreshold?.toString() ?? '';
  }

  @override
  void dispose() {
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Stok Güncelle'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _updateStock,
          child: _isLoading 
              ? const CupertinoActivityIndicator()
              : const Text('Kaydet'),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      widget.medicine.name,
                      style: AppTheme.headline2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.medicine.dosage} ${widget.medicine.dosageUnit} • ${widget.medicine.frequency}',
                      style: AppTheme.body1.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stok Bilgileri
              Text(
                'Stok Bilgileri',
                style: AppTheme.headline3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Mevcut Stok
              _buildInputField(
                label: 'Mevcut Stok',
                controller: _stockController,
                placeholder: 'Adet',
                keyboardType: TextInputType.number,
                icon: CupertinoIcons.cube_box,
              ),
              const SizedBox(height: 16),

              // Uyarı Eşiği
              _buildInputField(
                label: 'Uyarı Eşiği',
                controller: _thresholdController,
                placeholder: 'Adet',
                keyboardType: TextInputType.number,
                icon: CupertinoIcons.exclamationmark_triangle,
              ),
              const SizedBox(height: 24),

              // Stok Durumu
              _buildStockStatus(),
              const SizedBox(height: 24),

              // Hızlı Güncelleme Butonları
              Text(
                'Hızlı Güncelleme',
                style: AppTheme.headline3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      color: AppColors.success,
                      onPressed: () => _quickUpdate(1),
                      child: const Text('+1'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      color: AppColors.warning,
                      onPressed: () => _quickUpdate(-1),
                      child: const Text('-1'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      color: AppColors.error,
                      onPressed: () => _quickUpdate(-5),
                      child: const Text('-5'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      color: AppColors.info,
                      onPressed: () => _quickUpdate(5),
                      child: const Text('+5'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      color: AppColors.primaryBlue,
                      onPressed: () => _quickUpdate(10),
                      child: const Text('+10'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required TextInputType keyboardType,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.body1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.tertiaryText),
            borderRadius: BorderRadius.circular(8),
          ),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockStatus() {
    final currentStock = int.tryParse(_stockController.text) ?? 0;
    final threshold = int.tryParse(_thresholdController.text) ?? 0;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (currentStock <= 0) {
      statusColor = AppColors.error;
      statusText = 'Stok Tükendi';
      statusIcon = CupertinoIcons.xmark_circle;
    } else if (currentStock <= threshold) {
      statusColor = AppColors.warning;
      statusText = 'Stok Azaldı';
      statusIcon = CupertinoIcons.exclamationmark_triangle;
    } else {
      statusColor = AppColors.success;
      statusText = 'Stok Yeterli';
      statusIcon = CupertinoIcons.checkmark_circle;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: AppTheme.headline3.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Mevcut: $currentStock adet',
                  style: AppTheme.body2.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _quickUpdate(int change) {
    final currentStock = int.tryParse(_stockController.text) ?? 0;
    final newStock = currentStock + change;
    if (newStock >= 0) {
      setState(() {
        _stockController.text = newStock.toString();
      });
    }
  }

  Future<void> _updateStock() async {
    final newStock = int.tryParse(_stockController.text);
    final newThreshold = int.tryParse(_thresholdController.text);

    if (newStock == null || newStock < 0) {
      _showErrorDialog('Geçerli bir stok adedi girin');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<MedicineProvider>().updateStockCount(
        widget.medicine.id,
        newStock,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
      } else if (mounted) {
        _showErrorDialog('Stok güncellenirken hata oluştu');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Hata'),
        content: Text(message),
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
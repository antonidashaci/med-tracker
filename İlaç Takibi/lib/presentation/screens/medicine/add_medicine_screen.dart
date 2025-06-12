import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/medicine.dart';
import '../../../data/models/reminder.dart';
import '../../providers/medicine_provider.dart';
import '../../widgets/medicine/reminder_item.dart';
import 'qr_scanner_screen.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine; // null = yeni ilaç, not null = düzenleme

  const AddMedicineScreen({
    super.key,
    this.medicine,
  });

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Form values
  String _selectedCategory = AppConstants.medicineCategories.first;
  String _selectedFrequency = AppConstants.frequencyOptions.first;
  String _selectedDosageUnit = AppConstants.dosageUnits.first;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;
  List<Reminder> _reminders = [];
  int? _stockCount;
  int? _stockThreshold;
  List<String> _interactionIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _loadMedicineData();
    }
  }

  void _loadMedicineData() {
    final medicine = widget.medicine!;
    _nameController.text = medicine.name;
    _dosageController.text = medicine.dosage;
    _notesController.text = medicine.notes ?? '';
    _selectedCategory = medicine.category;
    _selectedFrequency = medicine.frequency;
    _selectedDosageUnit = medicine.dosageUnit;
    _startDate = medicine.startDate;
    _endDate = medicine.endDate;
    _isActive = medicine.isActive;
    _reminders = List.from(medicine.reminders);
    _stockCount = medicine.stockCount;
    _stockThreshold = medicine.stockThreshold;
    _interactionIds = List.from(medicine.interactionIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.medicine == null ? 'Yeni İlaç' : 'İlaç Düzenle'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveMedicine,
          child: const Text('Kaydet'),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QR Kod Tarama Butonu (sadece yeni ilaç eklerken)
                      if (widget.medicine == null) ...[
                        Container(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: AppColors.primaryBlue,
                            onPressed: _openQRScanner,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.qrcode_viewfinder,
                                  color: AppColors.secondaryBackground,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'QR Kod ile Tara',
                                  style: TextStyle(
                                    color: AppColors.secondaryBackground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // İlaç Adı
                      _buildSectionTitle('İlaç Adı'),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _nameController,
                        placeholder: 'İlaç adını girin',
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.tertiaryText),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'İlaç adı gereklidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Doz ve Birim
                      _buildSectionTitle('Doz'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CupertinoTextField(
                              controller: _dosageController,
                              placeholder: '1',
                              keyboardType: TextInputType.number,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.tertiaryText),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Doz gereklidir';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildPickerButton(
                              _selectedDosageUnit,
                              AppConstants.dosageUnits,
                              (value) => setState(() => _selectedDosageUnit = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Kategori
                      _buildSectionTitle('Kategori'),
                      const SizedBox(height: 8),
                      _buildPickerButton(
                        _selectedCategory,
                        AppConstants.medicineCategories,
                        (value) => setState(() => _selectedCategory = value),
                      ),
                      const SizedBox(height: 20),

                      // Sıklık
                      _buildSectionTitle('Sıklık'),
                      const SizedBox(height: 8),
                      _buildPickerButton(
                        _selectedFrequency,
                        AppConstants.frequencyOptions,
                        (value) => setState(() => _selectedFrequency = value),
                      ),
                      const SizedBox(height: 20),

                      // Tarihler
                      _buildSectionTitle('Tarihler'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateButton(
                              'Başlangıç',
                              _startDate,
                              (date) => setState(() => _startDate = date),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDateButton(
                              'Bitiş (Opsiyonel)',
                              _endDate,
                              (date) => setState(() => _endDate = date),
                              isOptional: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Notlar
                      _buildSectionTitle('Notlar (Opsiyonel)'),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _notesController,
                        placeholder: 'İlaç hakkında notlar...',
                        maxLines: 3,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.tertiaryText),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Aktif/Pasif
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Aktif',
                            style: AppTheme.body1,
                          ),
                          CupertinoSwitch(
                            value: _isActive,
                            onChanged: (value) => setState(() => _isActive = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stok Takibi
                      _buildSectionTitle('Stok Takibi'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              placeholder: 'Stok adedi',
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() => _stockCount = int.tryParse(val)),
                              controller: TextEditingController(text: _stockCount?.toString() ?? ''),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CupertinoTextField(
                              placeholder: 'Uyarı eşiği',
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() => _stockThreshold = int.tryParse(val)),
                              controller: TextEditingController(text: _stockThreshold?.toString() ?? ''),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Etkileşimli İlaçlar
                      _buildSectionTitle('Etkileşimli İlaçlar'),
                      const SizedBox(height: 8),
                      _buildInteractionPicker(),
                      const SizedBox(height: 20),

                      // Hatırlatıcılar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Hatırlatıcılar'),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _addReminder,
                            child: const Icon(
                              CupertinoIcons.add_circled,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      if (_reminders.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Henüz hatırlatıcı eklenmedi',
                            style: AppTheme.body2.copyWith(
                              color: AppColors.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ..._reminders.map((reminder) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ReminderItem(
                            reminder: reminder,
                            onUpdate: (updatedReminder) {
                              setState(() {
                                final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
                                if (index != -1) {
                                  _reminders[index] = updatedReminder;
                                }
                              });
                            },
                            onDelete: (reminderId) {
                              setState(() {
                                _reminders.removeWhere((r) => r.id == reminderId);
                              });
                            },
                          ),
                        )),
                      
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.body1.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildPickerButton(
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: AppColors.secondaryBackground,
      borderRadius: BorderRadius.circular(8),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => Container(
            height: 200,
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
                  child: CupertinoPicker(
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      onChanged(options[index]);
                    },
                    children: options.map((option) => Center(
                      child: Text(option),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            currentValue,
            style: AppTheme.body1,
          ),
          const Icon(
            CupertinoIcons.chevron_down,
            size: 16,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
    String label,
    DateTime? date,
    Function(DateTime) onChanged, {
    bool isOptional = false,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: AppColors.secondaryBackground,
      borderRadius: BorderRadius.circular(8),
      onPressed: () {
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
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: date ?? DateTime.now(),
                    onDateTimeChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date != null ? _formatDate(date) : label,
            style: AppTheme.body1.copyWith(
              color: date != null ? AppColors.primaryText : AppColors.secondaryText,
            ),
          ),
          const Icon(
            CupertinoIcons.calendar,
            size: 16,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }

  void _addReminder() {
    final newReminder = Reminder(
      time: const TimeOfDay(hour: 8, minute: 0),
      days: [1, 2, 3, 4, 5, 6, 7], // Tüm günler
    );
    
    setState(() {
      _reminders.add(newReminder);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final medicineProvider = context.read<MedicineProvider>();
    
    final medicine = Medicine(
      id: widget.medicine?.id,
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _selectedFrequency,
      category: _selectedCategory,
      startDate: _startDate,
      endDate: _endDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isActive: _isActive,
      reminders: _reminders,
      dosageUnit: _selectedDosageUnit,
      stockCount: _stockCount,
      stockThreshold: _stockThreshold,
      interactionIds: _interactionIds,
    );

    // Check for interactions
    final interactions = medicineProvider.checkInteractions(medicine);
    if (interactions.isNotEmpty) {
      final shouldContinue = await _showInteractionWarning(interactions);
      if (!shouldContinue) {
        return;
      }
    }

    bool success;
    if (widget.medicine == null) {
      success = await medicineProvider.addMedicine(medicine);
    } else {
      success = await medicineProvider.updateMedicine(medicine);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Hata'),
          content: const Text('İlaç kaydedilirken bir hata oluştu.'),
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

  Future<bool> _showInteractionWarning(List<Medicine> interactions) async {
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('İlaç Etkileşimi Uyarısı'),
        content: Column(
          children: [
            const Text('Bu ilaç aşağıdaki ilaçlarla etkileşime girebilir:'),
            const SizedBox(height: 12),
            ...interactions.map((med) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• ${med.name}', style: AppTheme.body2),
            )),
            const SizedBox(height: 12),
            const Text('Devam etmek istediğinizden emin misiniz?'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: const Text('Devam Et'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;
  }

  void _openQRScanner() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => QRScannerScreen(
          onQRCodeScanned: _handleQRCodeScanned,
        ),
      ),
    );
  }

  void _handleQRCodeScanned(String qrCode) {
    try {
      // QR kod formatı: MEDICINE|name|dosage|dosageUnit|frequency|category
      final parts = qrCode.split('|');
      if (parts.length >= 6 && parts[0] == 'MEDICINE') {
        setState(() {
          _nameController.text = parts[1];
          _dosageController.text = parts[2];
          _selectedDosageUnit = parts[3];
          _selectedFrequency = parts[4];
          _selectedCategory = parts[5];
        });
        
        // Başarı mesajı göster
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Başarılı'),
            content: const Text('İlaç bilgileri QR koddan yüklendi.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Tamam'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        _showErrorDialog('Geçersiz QR kod formatı');
      }
    } catch (e) {
      _showErrorDialog('QR kod işlenirken hata oluştu: $e');
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

  Widget _buildInteractionPicker() {
    // Tüm ilaçları getir, kendisini hariç tut
    final allMedicines = context.read<MedicineProvider>().medicines.where((m) => m.id != widget.medicine?.id).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allMedicines.map((med) {
            final selected = _interactionIds.contains(med.id);
            return FilterChip(
              label: Text(med.name),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _interactionIds.add(med.id);
                  } else {
                    _interactionIds.remove(med.id);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (_interactionIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Etkileşimli ilaç seçilmedi',
              style: AppTheme.caption.copyWith(color: AppColors.secondaryText),
            ),
          ),
      ],
    );
  }
} 
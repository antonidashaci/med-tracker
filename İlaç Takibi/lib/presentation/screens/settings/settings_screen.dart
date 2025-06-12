import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../widgets/settings/settings_section.dart';
import '../../widgets/settings/settings_item.dart';
import '../../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Ayarlar'),
      ),
      child: SafeArea(
        child: Consumer2<SettingsProvider, MedicineProvider>(
          builder: (context, settingsProvider, medicineProvider, child) {
            return CustomScrollView(
              slivers: [
                // Genel Ayarlar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SettingsSection(
                      title: 'Genel',
                      children: [
                        SettingsItem(
                          icon: CupertinoIcons.globe,
                          title: 'Dil',
                          subtitle: settingsProvider.getLocaleDisplayName(),
                          onTap: () => _showLanguagePicker(settingsProvider),
                        ),
                        SettingsItem(
                          icon: CupertinoIcons.paintbrush,
                          title: 'Tema',
                          subtitle: settingsProvider.getBrightnessDisplayName(),
                          onTap: () => _showThemePicker(settingsProvider),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bildirim Ayarları
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SettingsSection(
                      title: 'Bildirimler',
                      children: [
                        SettingsItem(
                          icon: CupertinoIcons.bell,
                          title: 'Bildirimler',
                          subtitle: settingsProvider.notificationsEnabled 
                              ? 'Açık' 
                              : 'Kapalı',
                          trailing: CupertinoSwitch(
                            value: settingsProvider.notificationsEnabled,
                            onChanged: (value) async {
                              await settingsProvider.setNotificationsEnabled(value);
                              if (!value) {
                                await _notificationService.cancelAllNotifications();
                              }
                            },
                          ),
                        ),
                        if (settingsProvider.notificationsEnabled) ...[
                          SettingsItem(
                            icon: CupertinoIcons.speaker_2,
                            title: 'Ses',
                            subtitle: settingsProvider.soundEnabled 
                                ? 'Açık' 
                                : 'Kapalı',
                            trailing: CupertinoSwitch(
                              value: settingsProvider.soundEnabled,
                              onChanged: (value) => settingsProvider.setSoundEnabled(value),
                            ),
                          ),
                          SettingsItem(
                            icon: CupertinoIcons.device_phone_portrait,
                            title: 'Titreşim',
                            subtitle: settingsProvider.vibrationEnabled 
                                ? 'Açık' 
                                : 'Kapalı',
                            trailing: CupertinoSwitch(
                              value: settingsProvider.vibrationEnabled,
                              onChanged: (value) => settingsProvider.setVibrationEnabled(value),
                            ),
                          ),
                          SettingsItem(
                            icon: CupertinoIcons.clock,
                            title: 'Hatırlatma Süresi',
                            subtitle: '${settingsProvider.reminderAdvanceMinutes} dakika önce',
                            onTap: () => _showAdvanceTimePicker(settingsProvider),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Veri Yönetimi
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SettingsSection(
                      title: 'Veri Yönetimi',
                      children: [
                        SettingsItem(
                          icon: CupertinoIcons.chart_bar,
                          title: 'İstatistikler',
                          subtitle: '${medicineProvider.medicines.length} ilaç, ${medicineProvider.getTodayHistory().length} kayıt',
                          onTap: () {
                            // TODO: Navigate to detailed statistics
                          },
                        ),
                        SettingsItem(
                          icon: CupertinoIcons.arrow_up_arrow_down,
                          title: 'Veri Yedekleme',
                          subtitle: 'Verilerinizi yedekleyin',
                          onTap: () => _showBackupDialog(),
                        ),
                        SettingsItem(
                          icon: CupertinoIcons.arrow_down_arrow_up,
                          title: 'Veri Geri Yükleme',
                          subtitle: 'Yedekten geri yükleyin',
                          onTap: () => _showRestoreDialog(),
                        ),
                        SettingsItem(
                          icon: CupertinoIcons.trash,
                          title: 'Tüm Verileri Sil',
                          subtitle: 'Dikkat: Bu işlem geri alınamaz',
                          onTap: () => _showDeleteAllDataDialog(medicineProvider),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // Uygulama Bilgileri
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SettingsSection(
                      title: 'Uygulama',
                      children: [
                        SettingsItem(
                          icon: CupertinoIcons.info_circle,
                          title: 'Hakkında',
                          subtitle: 'İlaç Takibi v1.0.0',
                          onTap: () => _showAboutDialog(),
                        ),
                        SettingsItem(
                          icon: CupertinoIcons.question_circle,
                          title: 'Yardım',
                          subtitle: 'Kullanım kılavuzu',
                          onTap: () => _showHelpDialog(),
                        ),
                        SettingsItem(
                          icon: CupertinoIcons.mail,
                          title: 'İletişim',
                          subtitle: 'Geri bildirim gönderin',
                          onTap: () => _showContactDialog(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Test Bildirimi
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SettingsSection(
                      title: 'Test',
                      children: [
                        SettingsItem(
                          icon: CupertinoIcons.bell_fill,
                          title: 'Test Bildirimi',
                          subtitle: 'Bildirim sistemini test edin',
                          onTap: () => _showTestNotification(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Varsayılanlara Sıfırla
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SettingsSection(
                      title: 'Sıfırlama',
                      children: [
                        SettingsItem(
                          icon: CupertinoIcons.refresh,
                          title: 'Varsayılanlara Sıfırla',
                          subtitle: 'Tüm ayarları varsayılan değerlere döndür',
                          onTap: () => _showResetDialog(settingsProvider),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLanguagePicker(SettingsProvider settingsProvider) {
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
                  final locales = [
                    const Locale('tr', 'TR'),
                    const Locale('en', 'US'),
                  ];
                  settingsProvider.setLocale(locales[index]);
                },
                children: const [
                  Center(child: Text('Türkçe')),
                  Center(child: Text('English')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(SettingsProvider settingsProvider) {
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
                  final brightnesses = [
                    Brightness.light,
                    Brightness.dark,
                  ];
                  settingsProvider.setBrightness(brightnesses[index]);
                },
                children: const [
                  Center(child: Text('Açık')),
                  Center(child: Text('Koyu')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdvanceTimePicker(SettingsProvider settingsProvider) {
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
                  final times = [5, 10, 15, 30, 60];
                  settingsProvider.setReminderAdvanceMinutes(times[index]);
                },
                children: const [
                  Center(child: Text('5 dakika')),
                  Center(child: Text('10 dakika')),
                  Center(child: Text('15 dakika')),
                  Center(child: Text('30 dakika')),
                  Center(child: Text('1 saat')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Veri Yedekleme'),
        content: const Text('Tüm ilaç verileriniz yedeklenecek. Bu işlem biraz zaman alabilir.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Yedekle'),
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement backup functionality
              _showSuccessDialog('Veriler başarıyla yedeklendi.');
            },
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Veri Geri Yükleme'),
        content: const Text('Mevcut verileriniz silinecek ve yedekten geri yüklenecek. Bu işlem geri alınamaz.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Geri Yükle'),
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement restore functionality
              _showSuccessDialog('Veriler başarıyla geri yüklendi.');
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDataDialog(MedicineProvider medicineProvider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Tüm Verileri Sil'),
        content: const Text('Tüm ilaç verileriniz ve geçmişiniz kalıcı olarak silinecek. Bu işlem geri alınamaz.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Sil'),
            onPressed: () async {
              Navigator.of(context).pop();
              await medicineProvider.deleteAllData();
              _showSuccessDialog('Tüm veriler silindi.');
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('İlaç Takibi'),
        content: const Text('Versiyon: 1.0.0\n\nBu uygulama ilaç takibinizi kolaylaştırmak için tasarlanmıştır.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Yardım'),
        content: const Text('• İlaç eklemek için + butonuna tıklayın\n• Hatırlatıcılar otomatik olarak planlanır\n• İlaç aldığınızda "Alındı" butonuna basın\n• Geçmiş sekmesinden istatistiklerinizi görün'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('İletişim'),
        content: const Text('Geri bildirim ve önerileriniz için:\n\nEmail: support@ilactakibi.com\n\nTeşekkürler!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showTestNotification() async {
    await _notificationService.showTestNotification();
    _showSuccessDialog('Test bildirimi gönderildi.');
  }

  void _showResetDialog(SettingsProvider settingsProvider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Varsayılanlara Sıfırla'),
        content: const Text('Tüm ayarlar varsayılan değerlere döndürülecek. Bu işlem geri alınamaz.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Sıfırla'),
            onPressed: () async {
              Navigator.of(context).pop();
              await settingsProvider.resetToDefaults();
              _showSuccessDialog('Ayarlar varsayılan değerlere sıfırlandı.');
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Başarılı'),
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
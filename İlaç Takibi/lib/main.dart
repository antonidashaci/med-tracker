import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'data/models/medicine.dart';
import 'data/models/reminder.dart';
import 'data/models/medicine_history.dart';
import 'data/models/time_of_day_adapter.dart';
import 'presentation/providers/medicine_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive initialization
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(MedicineAdapter());
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(MedicineHistoryAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  
  // Open boxes
  await Hive.openBox<Medicine>('medicines');
  await Hive.openBox<MedicineHistory>('medicine_history');
  await Hive.openBox('settings');
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return CupertinoApp(
            title: 'İlaç Takibi',
            debugShowCheckedModeBanner: false,
            theme: CupertinoThemeData(
              primaryColor: CupertinoColors.systemBlue,
              brightness: settingsProvider.brightness,
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
            ],
            locale: settingsProvider.locale,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: AppRoutes.home,
          );
        },
      ),
    );
  }
} 
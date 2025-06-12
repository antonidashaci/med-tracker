import 'package:flutter/cupertino.dart';
import '../data/models/medicine.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/medicine/add_medicine_screen.dart';
import '../presentation/screens/medicine/medicine_detail_screen.dart';
import '../presentation/screens/history/history_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addMedicine = '/add-medicine';
  static const String editMedicine = '/edit-medicine';
  static const String medicineDetail = '/medicine-detail';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return CupertinoPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      
      case addMedicine:
        return CupertinoPageRoute(
          builder: (_) => const AddMedicineScreen(),
          settings: settings,
        );
      
      case editMedicine:
        final medicine = settings.arguments as Medicine;
        return CupertinoPageRoute(
          builder: (_) => AddMedicineScreen(medicine: medicine),
          settings: settings,
        );
      
      case medicineDetail:
        final medicine = settings.arguments as Medicine;
        return CupertinoPageRoute(
          builder: (_) => MedicineDetailScreen(medicine: medicine),
          settings: settings,
        );
      
      case history:
        return CupertinoPageRoute(
          builder: (_) => const HistoryScreen(),
          settings: settings,
        );
      
      case settings:
        return CupertinoPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      
      default:
        return CupertinoPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Sayfa Bulunamadı'),
          settings: settings,
        );
    }
  }
}

// Geçici placeholder widget
class PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: const Center(
        child: Text('Bu sayfa yakında eklenecek'),
      ),
    );
  }
} 
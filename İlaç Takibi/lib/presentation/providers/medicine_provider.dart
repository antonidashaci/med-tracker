import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/medicine.dart';
import '../../data/models/medicine_history.dart';
import '../../services/notification_service.dart';

class MedicineProvider extends ChangeNotifier {
  final Box<Medicine> _medicinesBox = Hive.box<Medicine>('medicines');
  final Box<MedicineHistory> _historyBox = Hive.box<MedicineHistory>('medicine_history');
  final NotificationService _notificationService = NotificationService();
  
  List<Medicine> _medicines = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Medicine> get medicines => _medicines;
  List<Medicine> get activeMedicines => _medicines.where((m) => m.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load medicines from Hive
  Future<void> loadMedicines() async {
    _setLoading(true);
    try {
      _medicines = _medicinesBox.values.toList();
      _medicines.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _error = null;
    } catch (e) {
      _error = 'İlaçlar yüklenirken hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Add new medicine
  Future<bool> addMedicine(Medicine medicine) async {
    try {
      await _medicinesBox.put(medicine.id, medicine);
      await loadMedicines();
      
      // Schedule notifications for all reminders
      if (medicine.isActive) {
        for (final reminder in medicine.reminders) {
          await _notificationService.scheduleMedicineReminder(medicine, reminder);
        }
      }
      
      return true;
    } catch (e) {
      _error = 'İlaç eklenirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  // Update existing medicine
  Future<bool> updateMedicine(Medicine medicine) async {
    try {
      final updatedMedicine = medicine.copyWith(
        updatedAt: DateTime.now(),
      );
      
      // Cancel old notifications
      final oldMedicine = _medicinesBox.get(medicine.id);
      if (oldMedicine != null) {
        await _notificationService.cancelAllMedicineReminders(oldMedicine);
      }
      
      await _medicinesBox.put(medicine.id, updatedMedicine);
      await loadMedicines();
      
      // Schedule new notifications
      if (updatedMedicine.isActive) {
        for (final reminder in updatedMedicine.reminders) {
          await _notificationService.scheduleMedicineReminder(updatedMedicine, reminder);
        }
      }
      
      return true;
    } catch (e) {
      _error = 'İlaç güncellenirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete medicine
  Future<bool> deleteMedicine(String id) async {
    try {
      final medicine = _medicinesBox.get(id);
      if (medicine != null) {
        await _notificationService.cancelAllMedicineReminders(medicine);
      }
      
      await _medicinesBox.delete(id);
      await loadMedicines();
      return true;
    } catch (e) {
      _error = 'İlaç silinirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete all data
  Future<bool> deleteAllData() async {
    try {
      // Cancel all notifications
      await _notificationService.cancelAllNotifications();
      
      // Clear all medicines
      await _medicinesBox.clear();
      
      // Clear all history
      await _historyBox.clear();
      
      // Reload medicines
      await loadMedicines();
      
      return true;
    } catch (e) {
      _error = 'Veriler silinirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  // Toggle medicine active status
  Future<bool> toggleMedicineActive(String id) async {
    try {
      final medicine = _medicinesBox.get(id);
      if (medicine != null) {
        final updatedMedicine = medicine.copyWith(
          isActive: !medicine.isActive,
          updatedAt: DateTime.now(),
        );
        
        await _medicinesBox.put(id, updatedMedicine);
        await loadMedicines();
        
        // Handle notifications
        if (updatedMedicine.isActive) {
          // Schedule notifications
          for (final reminder in updatedMedicine.reminders) {
            await _notificationService.scheduleMedicineReminder(updatedMedicine, reminder);
          }
        } else {
          // Cancel notifications
          await _notificationService.cancelAllMedicineReminders(updatedMedicine);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _error = 'İlaç durumu güncellenirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  // Mark medicine as taken
  Future<bool> markMedicineTaken(String medicineId, {String? notes}) async {
    try {
      final medicine = _medicinesBox.get(medicineId);
      if (medicine == null) return false;

      final history = MedicineHistory(
        medicineId: medicineId,
        medicineName: medicine.name,
        dosage: medicine.dosage,
        notes: notes,
      );

      await _historyBox.put(history.id, history);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'İlaç alındı olarak işaretlenirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  // Get medicine by ID
  Medicine? getMedicineById(String id) {
    return _medicinesBox.get(id);
  }

  // Get medicine history
  List<MedicineHistory> getMedicineHistory(String medicineId) {
    return _historyBox.values
        .where((history) => history.medicineId == medicineId)
        .toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }

  // Get today's history
  List<MedicineHistory> getTodayHistory() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _historyBox.values
        .where((history) => 
            history.takenAt.isAfter(startOfDay) && 
            history.takenAt.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }

  // Get statistics
  Map<String, int> getStatistics() {
    final activeCount = activeMedicines.length;
    final totalCount = _medicines.length;
    final todayHistory = getTodayHistory();
    final takenToday = todayHistory.length;
    
    // Calculate missed medicines for today
    int missedToday = 0;
    for (final medicine in activeMedicines) {
      final todayReminders = medicine.reminders.where((reminder) {
        if (!reminder.isActive) return false;
        final now = DateTime.now();
        final weekday = now.weekday;
        return reminder.days.contains(weekday);
      }).toList();
      
      missedToday += todayReminders.length;
    }
    missedToday -= takenToday;

    return {
      'total': totalCount,
      'active': activeCount,
      'takenToday': takenToday,
      'missedToday': missedToday > 0 ? missedToday : 0,
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Check stock levels and send notifications
  Future<void> checkStockLevels() async {
    for (final medicine in _medicines) {
      if (medicine.stockCount != null && medicine.stockThreshold != null) {
        if (medicine.stockCount! <= medicine.stockThreshold!) {
          await _notificationService.showStockAlert(medicine);
        }
      }
    }
  }

  // Check for drug interactions
  List<Medicine> checkInteractions(Medicine medicine) {
    final interactionIds = medicine.interactionIds ?? [];
    return _medicines.where((m) => interactionIds.contains(m.id)).toList();
  }

  // Get medicines with low stock
  List<Medicine> getLowStockMedicines() {
    return _medicines.where((medicine) {
      if (medicine.stockCount != null && medicine.stockThreshold != null) {
        return medicine.stockCount! <= medicine.stockThreshold!;
      }
      return false;
    }).toList();
  }

  // Update stock count
  Future<bool> updateStockCount(String medicineId, int newCount) async {
    try {
      final medicine = _medicinesBox.get(medicineId);
      if (medicine != null) {
        final updatedMedicine = medicine.copyWith(
          stockCount: newCount,
          updatedAt: DateTime.now(),
        );
        
        await _medicinesBox.put(medicineId, updatedMedicine);
        await loadMedicines();
        
        // Check if stock is low after update
        if (updatedMedicine.stockThreshold != null && 
            newCount <= updatedMedicine.stockThreshold!) {
          await _notificationService.showStockAlert(updatedMedicine);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Stok güncellenirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }
} 
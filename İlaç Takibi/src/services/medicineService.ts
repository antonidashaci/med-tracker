import { Medicine, MedicineHistory } from '../types';
import { storage } from '../utils/storage';
import { notificationService } from '../utils/notifications';

export const medicineService = {
  // Tüm ilaçları getir
  async getAllMedicines(): Promise<Medicine[]> {
    return await storage.getMedicines();
  },

  // Aktif ilaçları getir
  async getActiveMedicines(): Promise<Medicine[]> {
    const medicines = await storage.getMedicines();
    return medicines.filter(medicine => medicine.isActive);
  },

  // İlaç ekle
  async addMedicine(medicineData: Omit<Medicine, 'id' | 'createdAt' | 'updatedAt'>): Promise<Medicine> {
    const medicines = await storage.getMedicines();
    
    const newMedicine: Medicine = {
      ...medicineData,
      id: Date.now().toString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    medicines.push(newMedicine);
    await storage.saveMedicines(medicines);

    // Hatırlatıcıları ayarla
    for (const reminder of newMedicine.reminders) {
      if (reminder.isActive) {
        await notificationService.scheduleMedicineReminder(
          newMedicine.id,
          newMedicine.name,
          reminder.time,
          reminder.days
        );
      }
    }

    return newMedicine;
  },

  // İlaç güncelle
  async updateMedicine(id: string, updates: Partial<Medicine>): Promise<Medicine | null> {
    const medicines = await storage.getMedicines();
    const index = medicines.findIndex(medicine => medicine.id === id);
    
    if (index === -1) return null;

    medicines[index] = {
      ...medicines[index],
      ...updates,
      updatedAt: new Date().toISOString(),
    };

    await storage.saveMedicines(medicines);
    return medicines[index];
  },

  // İlaç sil
  async deleteMedicine(id: string): Promise<boolean> {
    const medicines = await storage.getMedicines();
    const filteredMedicines = medicines.filter(medicine => medicine.id !== id);
    
    if (filteredMedicines.length === medicines.length) {
      return false;
    }

    await storage.saveMedicines(filteredMedicines);
    
    // İlgili bildirimleri iptal et
    const notifications = await notificationService.getScheduledNotifications();
    for (const notification of notifications) {
      if (notification.content.data?.medicineId === id) {
        await notificationService.cancelNotification(notification.identifier);
      }
    }

    return true;
  },

  // İlaç alındı olarak işaretle
  async markMedicineAsTaken(medicineId: string, dosage: string, notes?: string): Promise<void> {
    const history = await storage.getHistory();
    const medicines = await storage.getMedicines();
    const medicine = medicines.find(m => m.id === medicineId);
    
    if (!medicine) return;

    const historyEntry: MedicineHistory = {
      id: Date.now().toString(),
      medicineId,
      medicineName: medicine.name,
      takenAt: new Date().toISOString(),
      dosage,
      notes,
    };

    history.push(historyEntry);
    await storage.saveHistory(history);

    // Son alınma zamanını güncelle
    await this.updateMedicine(medicineId, {
      reminders: medicine.reminders.map(reminder => ({
        ...reminder,
        lastTaken: new Date().toISOString(),
      })),
    });
  },

  // İlaç geçmişini getir
  async getMedicineHistory(medicineId?: string): Promise<MedicineHistory[]> {
    const history = await storage.getHistory();
    
    if (medicineId) {
      return history.filter(entry => entry.medicineId === medicineId);
    }
    
    return history.sort((a, b) => new Date(b.takenAt).getTime() - new Date(a.takenAt).getTime());
  },

  // İstatistikleri getir
  async getStatistics(): Promise<{
    totalMedicines: number;
    activeMedicines: number;
    totalTakenToday: number;
    adherenceRate: number;
  }> {
    const medicines = await storage.getMedicines();
    const activeMedicines = medicines.filter(m => m.isActive);
    const history = await storage.getHistory();
    
    const today = new Date().toDateString();
    const takenToday = history.filter(entry => 
      new Date(entry.takenAt).toDateString() === today
    ).length;

    // Basit uyum oranı hesaplama (son 7 gün)
    const lastWeek = new Date();
    lastWeek.setDate(lastWeek.getDate() - 7);
    
    const recentHistory = history.filter(entry => 
      new Date(entry.takenAt) > lastWeek
    );
    
    const adherenceRate = activeMedicines.length > 0 
      ? Math.round((recentHistory.length / (activeMedicines.length * 7)) * 100)
      : 0;

    return {
      totalMedicines: medicines.length,
      activeMedicines: activeMedicines.length,
      totalTakenToday: takenToday,
      adherenceRate: Math.min(adherenceRate, 100),
    };
  },
}; 
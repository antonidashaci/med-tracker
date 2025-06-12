import AsyncStorage from '@react-native-async-storage/async-storage';
import { Medicine, MedicineHistory } from '../types';

const STORAGE_KEYS = {
  MEDICINES: 'medicines',
  HISTORY: 'medicine_history',
  SETTINGS: 'app_settings',
};

export const storage = {
  // İlaç verilerini kaydet
  async saveMedicines(medicines: Medicine[]): Promise<void> {
    try {
      await AsyncStorage.setItem(STORAGE_KEYS.MEDICINES, JSON.stringify(medicines));
    } catch (error) {
      console.error('İlaçlar kaydedilemedi:', error);
      throw error;
    }
  },

  // İlaç verilerini getir
  async getMedicines(): Promise<Medicine[]> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.MEDICINES);
      return data ? JSON.parse(data) : [];
    } catch (error) {
      console.error('İlaçlar getirilemedi:', error);
      return [];
    }
  },

  // İlaç geçmişini kaydet
  async saveHistory(history: MedicineHistory[]): Promise<void> {
    try {
      await AsyncStorage.setItem(STORAGE_KEYS.HISTORY, JSON.stringify(history));
    } catch (error) {
      console.error('Geçmiş kaydedilemedi:', error);
      throw error;
    }
  },

  // İlaç geçmişini getir
  async getHistory(): Promise<MedicineHistory[]> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.HISTORY);
      return data ? JSON.parse(data) : [];
    } catch (error) {
      console.error('Geçmiş getirilemedi:', error);
      return [];
    }
  },

  // Ayarları kaydet
  async saveSettings(settings: any): Promise<void> {
    try {
      await AsyncStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(settings));
    } catch (error) {
      console.error('Ayarlar kaydedilemedi:', error);
      throw error;
    }
  },

  // Ayarları getir
  async getSettings(): Promise<any> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEYS.SETTINGS);
      return data ? JSON.parse(data) : {};
    } catch (error) {
      console.error('Ayarlar getirilemedi:', error);
      return {};
    }
  },

  // Tüm verileri temizle
  async clearAll(): Promise<void> {
    try {
      await AsyncStorage.multiRemove(Object.values(STORAGE_KEYS));
    } catch (error) {
      console.error('Veriler temizlenemedi:', error);
      throw error;
    }
  },
}; 
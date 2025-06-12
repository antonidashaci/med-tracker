import { useState, useEffect, useCallback } from 'react';
import { Medicine, MedicineHistory } from '../types';
import { medicineService } from '../services/medicineService';

export const useMedicines = () => {
  const [medicines, setMedicines] = useState<Medicine[]>([]);
  const [activeMedicines, setActiveMedicines] = useState<Medicine[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // İlaçları yükle
  const loadMedicines = useCallback(async () => {
    try {
      setLoading(true);
      const allMedicines = await medicineService.getAllMedicines();
      const active = await medicineService.getActiveMedicines();
      
      setMedicines(allMedicines);
      setActiveMedicines(active);
      setError(null);
    } catch (err) {
      setError('İlaçlar yüklenirken hata oluştu');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, []);

  // İlaç ekle
  const addMedicine = useCallback(async (medicineData: Omit<Medicine, 'id' | 'createdAt' | 'updatedAt'>) => {
    try {
      const newMedicine = await medicineService.addMedicine(medicineData);
      setMedicines(prev => [...prev, newMedicine]);
      if (newMedicine.isActive) {
        setActiveMedicines(prev => [...prev, newMedicine]);
      }
      return newMedicine;
    } catch (err) {
      setError('İlaç eklenirken hata oluştu');
      throw err;
    }
  }, []);

  // İlaç güncelle
  const updateMedicine = useCallback(async (id: string, updates: Partial<Medicine>) => {
    try {
      const updatedMedicine = await medicineService.updateMedicine(id, updates);
      if (updatedMedicine) {
        setMedicines(prev => 
          prev.map(medicine => 
            medicine.id === id ? updatedMedicine : medicine
          )
        );
        
        setActiveMedicines(prev => {
          if (updatedMedicine.isActive) {
            return prev.some(m => m.id === id) 
              ? prev.map(medicine => medicine.id === id ? updatedMedicine : medicine)
              : [...prev, updatedMedicine];
          } else {
            return prev.filter(medicine => medicine.id !== id);
          }
        });
      }
      return updatedMedicine;
    } catch (err) {
      setError('İlaç güncellenirken hata oluştu');
      throw err;
    }
  }, []);

  // İlaç sil
  const deleteMedicine = useCallback(async (id: string) => {
    try {
      const success = await medicineService.deleteMedicine(id);
      if (success) {
        setMedicines(prev => prev.filter(medicine => medicine.id !== id));
        setActiveMedicines(prev => prev.filter(medicine => medicine.id !== id));
      }
      return success;
    } catch (err) {
      setError('İlaç silinirken hata oluştu');
      throw err;
    }
  }, []);

  // İlaç alındı olarak işaretle
  const markAsTaken = useCallback(async (medicineId: string, dosage: string, notes?: string) => {
    try {
      await medicineService.markMedicineAsTaken(medicineId, dosage, notes);
    } catch (err) {
      setError('İlaç işaretlenirken hata oluştu');
      throw err;
    }
  }, []);

  useEffect(() => {
    loadMedicines();
  }, [loadMedicines]);

  return {
    medicines,
    activeMedicines,
    loading,
    error,
    loadMedicines,
    addMedicine,
    updateMedicine,
    deleteMedicine,
    markAsTaken,
  };
}; 
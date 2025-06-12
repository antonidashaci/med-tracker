export interface Medicine {
  id: string;
  name: string;
  dosage: string;
  frequency: string;
  startDate: string;
  endDate?: string;
  notes?: string;
  isActive: boolean;
  reminders: Reminder[];
  createdAt: string;
  updatedAt: string;
}

export interface Reminder {
  id: string;
  time: string;
  days: string[];
  isActive: boolean;
  lastTaken?: string;
}

export interface MedicineHistory {
  id: string;
  medicineId: string;
  medicineName: string;
  takenAt: string;
  dosage: string;
  notes?: string;
}

export interface NotificationData {
  id: string;
  title: string;
  body: string;
  data?: any;
  trigger?: any;
} 
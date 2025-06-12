import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import { Platform } from 'react-native';
import { NotificationData } from '../types';

// Bildirim ayarlarını yapılandır
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: false,
  }),
});

export const notificationService = {
  // Bildirim izinlerini iste
  async requestPermissions(): Promise<boolean> {
    if (!Device.isDevice) {
      return false;
    }

    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;

    if (existingStatus !== 'granted') {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }

    if (finalStatus !== 'granted') {
      return false;
    }

    if (Platform.OS === 'android') {
      await Notifications.setNotificationChannelAsync('default', {
        name: 'default',
        importance: Notifications.AndroidImportance.MAX,
        vibrationPattern: [0, 250, 250, 250],
        lightColor: '#FF231F7C',
      });
    }

    return true;
  },

  // İlaç hatırlatıcısı oluştur
  async scheduleMedicineReminder(
    medicineId: string,
    medicineName: string,
    time: string,
    days: string[]
  ): Promise<string> {
    const hasPermission = await this.requestPermissions();
    if (!hasPermission) {
      throw new Error('Bildirim izni verilmedi');
    }

    const [hour, minute] = time.split(':').map(Number);
    
    const trigger = {
      hour,
      minute,
      repeats: true,
    };

    const identifier = await Notifications.scheduleNotificationAsync({
      content: {
        title: 'İlaç Hatırlatıcısı',
        body: `${medicineName} ilacınızı alma zamanı geldi!`,
        data: { medicineId, type: 'medicine_reminder' },
      },
      trigger,
    });

    return identifier;
  },

  // Bildirimi iptal et
  async cancelNotification(identifier: string): Promise<void> {
    await Notifications.cancelScheduledNotificationAsync(identifier);
  },

  // Tüm bildirimleri iptal et
  async cancelAllNotifications(): Promise<void> {
    await Notifications.cancelAllScheduledNotificationsAsync();
  },

  // Bildirimleri getir
  async getScheduledNotifications(): Promise<Notifications.NotificationRequest[]> {
    return await Notifications.getAllScheduledNotificationsAsync();
  },

  // Bildirim dinleyicisi ekle
  addNotificationListener(callback: (notification: Notifications.Notification) => void): Notifications.Subscription {
    return Notifications.addNotificationReceivedListener(callback);
  },

  // Bildirim yanıt dinleyicisi ekle
  addNotificationResponseListener(
    callback: (response: Notifications.NotificationResponse) => void
  ): Notifications.Subscription {
    return Notifications.addNotificationResponseReceivedListener(callback);
  },
}; 
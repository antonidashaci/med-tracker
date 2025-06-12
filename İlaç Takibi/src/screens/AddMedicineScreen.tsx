import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import {
  TextInput,
  Button,
  Title,
  Card,
  Switch,
  Text,
  Chip,
  IconButton,
  Snackbar,
} from 'react-native-paper';
import { useMedicines } from '../hooks/useMedicines';
import { Medicine, Reminder } from '../types';
import { LanguageSwitcher } from '../components/LanguageSwitcher';
import { useTranslation } from 'react-i18next';

interface AddMedicineScreenProps {
  navigation: any;
  route: any;
}

export const AddMedicineScreen: React.FC<AddMedicineScreenProps> = ({
  navigation,
  route,
}) => {
  const { addMedicine, updateMedicine } = useMedicines();
  const editingMedicine = route.params?.medicine;
  const { t } = useTranslation();

  const [formData, setFormData] = useState({
    name: '',
    dosage: '',
    frequency: '',
    startDate: new Date().toISOString().split('T')[0],
    endDate: '',
    notes: '',
    isActive: true,
  });

  const [reminders, setReminders] = useState<Reminder[]>([]);
  const [loading, setLoading] = useState(false);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  useEffect(() => {
    if (editingMedicine) {
      setFormData({
        name: editingMedicine.name,
        dosage: editingMedicine.dosage,
        frequency: editingMedicine.frequency,
        startDate: editingMedicine.startDate.split('T')[0],
        endDate: editingMedicine.endDate?.split('T')[0] || '',
        notes: editingMedicine.notes || '',
        isActive: editingMedicine.isActive,
      });
      setReminders(editingMedicine.reminders);
    }
  }, [editingMedicine]);

  const handleSave = async () => {
    if (!formData.name || !formData.dosage || !formData.frequency) {
      setSnackbarMessage(t('addMedicine.requiredFields'));
      setSnackbarVisible(true);
      return;
    }

    setLoading(true);
    try {
      const medicineData = {
        ...formData,
        reminders,
      };

      if (editingMedicine) {
        await updateMedicine(editingMedicine.id, medicineData);
        setSnackbarMessage(t('addMedicine.successUpdate'));
      } else {
        await addMedicine(medicineData);
        setSnackbarMessage(t('addMedicine.successAdd'));
      }

      setSnackbarVisible(true);
      setTimeout(() => {
        navigation.goBack();
      }, 1500);
    } catch (err) {
      setSnackbarMessage(t('addMedicine.error'));
      setSnackbarVisible(true);
    } finally {
      setLoading(false);
    }
  };

  const addReminder = () => {
    const newReminder: Reminder = {
      id: Date.now().toString(),
      time: '08:00',
      days: ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'],
      isActive: true,
    };
    setReminders([...reminders, newReminder]);
  };

  const updateReminder = (id: string, updates: Partial<Reminder>) => {
    setReminders(prev =>
      prev.map(reminder =>
        reminder.id === id ? { ...reminder, ...updates } : reminder
      )
    );
  };

  const deleteReminder = (id: string) => {
    setReminders(prev => prev.filter(reminder => reminder.id !== id));
  };

  const toggleDay = (reminderId: string, day: string) => {
    setReminders(prev =>
      prev.map(reminder => {
        if (reminder.id === reminderId) {
          const days = reminder.days.includes(day)
            ? reminder.days.filter(d => d !== day)
            : [...reminder.days, day];
          return { ...reminder, days };
        }
        return reminder;
      })
    );
  };

  const days = t('reminder.days', { returnObjects: true }) as string[];

  return (
    <View style={styles.container}>
      <LanguageSwitcher />
      <ScrollView style={styles.scrollView}>
        <Card style={styles.card}>
          <Card.Content>
            <Title style={styles.title}>
              {editingMedicine ? t('addMedicine.editTitle') : t('addMedicine.addTitle')}
            </Title>

            <TextInput
              label={t('addMedicine.name')}
              value={formData.name}
              onChangeText={(text) => setFormData({ ...formData, name: text })}
              style={styles.input}
              mode="outlined"
            />

            <TextInput
              label={t('addMedicine.dosage')}
              value={formData.dosage}
              onChangeText={(text) => setFormData({ ...formData, dosage: text })}
              style={styles.input}
              mode="outlined"
              placeholder="Örn: 1 tablet"
            />

            <TextInput
              label={t('addMedicine.frequency')}
              value={formData.frequency}
              onChangeText={(text) => setFormData({ ...formData, frequency: text })}
              style={styles.input}
              mode="outlined"
              placeholder="Örn: Günde 2 kez"
            />

            <TextInput
              label={t('addMedicine.startDate')}
              value={formData.startDate}
              onChangeText={(text) => setFormData({ ...formData, startDate: text })}
              style={styles.input}
              mode="outlined"
            />

            <TextInput
              label={t('addMedicine.endDate')}
              value={formData.endDate}
              onChangeText={(text) => setFormData({ ...formData, endDate: text })}
              style={styles.input}
              mode="outlined"
            />

            <TextInput
              label={t('addMedicine.notes')}
              value={formData.notes}
              onChangeText={(text) => setFormData({ ...formData, notes: text })}
              style={styles.input}
              mode="outlined"
              multiline
              numberOfLines={3}
            />

            <View style={styles.switchContainer}>
              <Text>{t('addMedicine.active')}</Text>
              <Switch
                value={formData.isActive}
                onValueChange={(value) => setFormData({ ...formData, isActive: value })}
              />
            </View>

            <Title style={styles.sectionTitle}>{t('addMedicine.reminders')}</Title>

            {reminders.map((reminder) => (
              <Card key={reminder.id} style={styles.reminderCard}>
                <Card.Content>
                  <View style={styles.reminderHeader}>
                    <TextInput
                      label={t('reminder.time')}
                      value={reminder.time}
                      onChangeText={(text) => updateReminder(reminder.id, { time: text })}
                      style={styles.timeInput}
                      mode="outlined"
                    />
                    <IconButton
                      icon="delete"
                      size={20}
                      onPress={() => deleteReminder(reminder.id)}
                    />
                  </View>

                  <View style={styles.daysContainer}>
                    {days.map((day) => (
                      <Chip
                        key={day}
                        selected={reminder.days.includes(day)}
                        onPress={() => toggleDay(reminder.id, day)}
                        style={styles.dayChip}
                        mode="outlined"
                      >
                        {day.slice(0, 3)}
                      </Chip>
                    ))}
                  </View>

                  <View style={styles.switchContainer}>
                    <Text>{t('reminder.active')}</Text>
                    <Switch
                      value={reminder.isActive}
                      onValueChange={(value) => updateReminder(reminder.id, { isActive: value })}
                    />
                  </View>
                </Card.Content>
              </Card>
            ))}

            <Button
              mode="outlined"
              onPress={addReminder}
              style={styles.addReminderButton}
              icon="plus"
            >
              {t('addMedicine.addReminder')}
            </Button>

            <Button
              mode="contained"
              onPress={handleSave}
              style={styles.saveButton}
              loading={loading}
              disabled={loading}
            >
              {editingMedicine ? t('addMedicine.update') : t('addMedicine.save')}
            </Button>
          </Card.Content>
        </Card>
      </ScrollView>

      <Snackbar
        visible={snackbarVisible}
        onDismiss={() => setSnackbarVisible(false)}
        duration={3000}
      >
        {snackbarMessage}
      </Snackbar>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollView: {
    flex: 1,
  },
  card: {
    margin: 16,
    elevation: 2,
  },
  title: {
    fontSize: 24,
    marginBottom: 20,
    textAlign: 'center',
  },
  input: {
    marginBottom: 16,
  },
  switchContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    marginTop: 20,
    marginBottom: 16,
  },
  reminderCard: {
    marginBottom: 12,
    elevation: 1,
  },
  reminderHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  timeInput: {
    flex: 1,
    marginRight: 8,
  },
  daysContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 12,
  },
  dayChip: {
    margin: 2,
  },
  addReminderButton: {
    marginTop: 8,
    marginBottom: 20,
  },
  saveButton: {
    marginTop: 8,
  },
});

export default AddMedicineScreen; 
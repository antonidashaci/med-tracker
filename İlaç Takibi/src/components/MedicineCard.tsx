import React from 'react';
import { View, StyleSheet, Alert } from 'react-native';
import { Card, Title, Paragraph, Button, Chip, IconButton } from 'react-native-paper';
import { Medicine } from '../types';
import { useTranslation } from 'react-i18next';

interface MedicineCardProps {
  medicine: Medicine;
  onEdit: (medicine: Medicine) => void;
  onDelete: (id: string) => void;
  onMarkAsTaken: (medicineId: string, dosage: string) => void;
}

export const MedicineCard: React.FC<MedicineCardProps> = ({
  medicine,
  onEdit,
  onDelete,
  onMarkAsTaken,
}) => {
  const { t } = useTranslation();

  const handleDelete = () => {
    Alert.alert(
      t('home.deleteMedicine'),
      t('home.deleteMedicineConfirm', { name: medicine.name }),
      [
        { text: t('common.cancel'), style: 'cancel' },
        { text: t('home.delete'), style: 'destructive', onPress: () => onDelete(medicine.id) },
      ]
    );
  };

  const handleMarkAsTaken = () => {
    onMarkAsTaken(medicine.id, medicine.dosage);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('tr-TR');
  };

  const getStatusColor = () => {
    return medicine.isActive ? '#4CAF50' : '#9E9E9E';
  };

  return (
    <Card style={[styles.card, { borderLeftColor: getStatusColor() }]}>
      <Card.Content>
        <View style={styles.header}>
          <View style={styles.titleContainer}>
            <Title style={styles.title}>{medicine.name}</Title>
            <Chip 
              mode="outlined" 
              style={[styles.statusChip, { borderColor: getStatusColor() }]}
              textStyle={{ color: getStatusColor() }}
            >
              {medicine.isActive ? t('home.active') : t('home.inactive')}
            </Chip>
          </View>
          <View style={styles.actions}>
            <IconButton
              icon="pencil"
              size={20}
              onPress={() => onEdit(medicine)}
              accessibilityLabel={t('home.edit')}
            />
            <IconButton
              icon="delete"
              size={20}
              onPress={handleDelete}
              accessibilityLabel={t('home.delete')}
            />
          </View>
        </View>

        <View style={styles.details}>
          <Paragraph style={styles.detail}>
            <strong>{t('addMedicine.dosage')}:</strong> {medicine.dosage}
          </Paragraph>
          <Paragraph style={styles.detail}>
            <strong>{t('addMedicine.frequency')}:</strong> {medicine.frequency}
          </Paragraph>
          <Paragraph style={styles.detail}>
            <strong>{t('addMedicine.startDate')}:</strong> {formatDate(medicine.startDate)}
          </Paragraph>
          {medicine.endDate && (
            <Paragraph style={styles.detail}>
              <strong>{t('addMedicine.endDate')}:</strong> {formatDate(medicine.endDate)}
            </Paragraph>
          )}
          {medicine.notes && (
            <Paragraph style={styles.notes}>
              <strong>{t('addMedicine.notes')}:</strong> {medicine.notes}
            </Paragraph>
          )}
        </View>

        <View style={styles.reminders}>
          <Paragraph style={styles.remindersTitle}>
            <strong>{t('addMedicine.reminders')}:</strong>
          </Paragraph>
          {medicine.reminders.map((reminder) => (
            <Chip key={reminder.id} style={styles.reminderChip} mode="outlined">
              {reminder.time} - {reminder.days.join(', ')}
            </Chip>
          ))}
        </View>
      </Card.Content>

      {medicine.isActive && (
        <Card.Actions style={styles.actions}>
          <Button 
            mode="contained" 
            onPress={handleMarkAsTaken}
            style={styles.takenButton}
          >
            {t('home.markAsTaken')}
          </Button>
        </Card.Actions>
      )}
    </Card>
  );
};

const styles = StyleSheet.create({
  card: {
    marginVertical: 8,
    marginHorizontal: 16,
    borderLeftWidth: 4,
    elevation: 2,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  titleContainer: {
    flex: 1,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  statusChip: {
    alignSelf: 'flex-start',
  },
  actions: {
    flexDirection: 'row',
  },
  details: {
    marginBottom: 12,
  },
  detail: {
    marginBottom: 4,
    fontSize: 14,
  },
  notes: {
    marginTop: 8,
    fontStyle: 'italic',
    fontSize: 14,
  },
  reminders: {
    marginBottom: 8,
  },
  remindersTitle: {
    marginBottom: 8,
    fontSize: 14,
  },
  reminderChip: {
    marginRight: 8,
    marginBottom: 4,
  },
  takenButton: {
    flex: 1,
    marginHorizontal: 8,
  },
}); 
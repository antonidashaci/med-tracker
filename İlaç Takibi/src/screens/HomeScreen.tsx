import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import { 
  Text, 
  Card, 
  Title, 
  Paragraph, 
  FAB, 
  ActivityIndicator,
  Snackbar 
} from 'react-native-paper';
import { MedicineCard } from '../components/MedicineCard';
import { useMedicines } from '../hooks/useMedicines';
import { medicineService } from '../services/medicineService';
import { Medicine } from '../types';
import { LanguageSwitcher } from '../components/LanguageSwitcher';
import { useTranslation } from 'react-i18next';

interface HomeScreenProps {
  navigation: any;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({ navigation }) => {
  const { 
    activeMedicines, 
    loading, 
    error, 
    loadMedicines, 
    deleteMedicine, 
    markAsTaken 
  } = useMedicines();
  
  const [refreshing, setRefreshing] = useState(false);
  const [statistics, setStatistics] = useState({
    totalMedicines: 0,
    activeMedicines: 0,
    totalTakenToday: 0,
    adherenceRate: 0,
  });
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const { t } = useTranslation();

  const loadStatistics = async () => {
    try {
      const stats = await medicineService.getStatistics();
      setStatistics(stats);
    } catch (err) {
      console.error('İstatistikler yüklenemedi:', err);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadMedicines();
    await loadStatistics();
    setRefreshing(false);
  };

  const handleDelete = async (id: string) => {
    try {
      await deleteMedicine(id);
      await loadStatistics();
      setSnackbarMessage('İlaç başarıyla silindi');
      setSnackbarVisible(true);
    } catch (err) {
      setSnackbarMessage('İlaç silinirken hata oluştu');
      setSnackbarVisible(true);
    }
  };

  const handleMarkAsTaken = async (medicineId: string, dosage: string) => {
    try {
      await markAsTaken(medicineId, dosage);
      await loadStatistics();
      setSnackbarMessage('İlaç alındı olarak işaretlendi');
      setSnackbarVisible(true);
    } catch (err) {
      setSnackbarMessage('İlaç işaretlenirken hata oluştu');
      setSnackbarVisible(true);
    }
  };

  const handleEdit = (medicine: Medicine) => {
    navigation.navigate('AddMedicine', { medicine });
  };

  useEffect(() => {
    loadStatistics();
  }, [activeMedicines]);

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" />
        <Text>İlaçlar yükleniyor...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <LanguageSwitcher />
      <ScrollView
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        {/* İstatistikler */}
        <View style={styles.statsContainer}>
          <Card style={styles.statsCard}>
            <Card.Content>
              <Title style={styles.statsTitle}>{t('home.todayStatus')}</Title>
              <View style={styles.statsGrid}>
                <View style={styles.statItem}>
                  <Text style={styles.statNumber}>{statistics.activeMedicines}</Text>
                  <Text style={styles.statLabel}>{t('home.activeMedicines')}</Text>
                </View>
                <View style={styles.statItem}>
                  <Text style={styles.statNumber}>{statistics.totalTakenToday}</Text>
                  <Text style={styles.statLabel}>{t('home.takenToday')}</Text>
                </View>
                <View style={styles.statItem}>
                  <Text style={styles.statNumber}>{statistics.adherenceRate}%</Text>
                  <Text style={styles.statLabel}>{t('home.adherenceRate')}</Text>
                </View>
              </View>
            </Card.Content>
          </Card>
        </View>

        {/* İlaç Listesi */}
        <View style={styles.medicinesContainer}>
          <Title style={styles.sectionTitle}>{t('home.myActiveMedicines')}</Title>
          
          {activeMedicines.length === 0 ? (
            <Card style={styles.emptyCard}>
              <Card.Content>
                <Paragraph style={styles.emptyText}>
                  {t('home.noActiveMedicine')}
                </Paragraph>
              </Card.Content>
            </Card>
          ) : (
            activeMedicines.map((medicine) => (
              <MedicineCard
                key={medicine.id}
                medicine={medicine}
                onEdit={handleEdit}
                onDelete={handleDelete}
                onMarkAsTaken={handleMarkAsTaken}
              />
            ))
          )}
        </View>
      </ScrollView>

      {/* FAB */}
      <FAB
        style={styles.fab}
        icon="plus"
        onPress={() => navigation.navigate('AddMedicine')}
      />

      {/* Snackbar */}
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
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  statsContainer: {
    padding: 16,
  },
  statsCard: {
    elevation: 2,
  },
  statsTitle: {
    fontSize: 18,
    marginBottom: 16,
  },
  statsGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  statItem: {
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2196F3',
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  medicinesContainer: {
    paddingBottom: 80,
  },
  sectionTitle: {
    fontSize: 20,
    marginHorizontal: 16,
    marginBottom: 8,
  },
  emptyCard: {
    margin: 16,
    elevation: 1,
  },
  emptyText: {
    textAlign: 'center',
    color: '#666',
    lineHeight: 20,
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
  },
});

export default HomeScreen; 
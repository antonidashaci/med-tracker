import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Button } from 'react-native-paper';
import { useTranslation } from 'react-i18next';

export const LanguageSwitcher: React.FC = () => {
  const { i18n, t } = useTranslation();

  return (
    <View style={styles.container}>
      <Button
        mode={i18n.language === 'tr' ? 'contained' : 'outlined'}
        onPress={() => i18n.changeLanguage('tr')}
        style={styles.button}
      >
        {t('language.turkish')}
      </Button>
      <Button
        mode={i18n.language === 'en' ? 'contained' : 'outlined'}
        onPress={() => i18n.changeLanguage('en')}
        style={styles.button}
      >
        {t('language.english')}
      </Button>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginVertical: 8,
  },
  button: {
    marginHorizontal: 4,
  },
}); 
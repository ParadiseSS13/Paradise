import { SettingsData } from '~/common/types';
import { useSettingsSlice } from '../stores/settings';

const settingsStorageKey = 'parachat-settings';

export const defaultSettings: SettingsData = {
  theme: 'light',
  font: "Verdana, 'Helvetica Neue', Helvetica, Arial, sans-serif",
  fontUrl: '',
  fontScale: 100,
  lineHeight: 1.2,
  condenseMessages: true,
  highlights: [],
};

export const loadSettings = () => {
  let savedSettings;
  try {
    savedSettings =
      JSON.parse(window.localStorage.getItem(settingsStorageKey)) || {};
  } catch (e) {
    /* empty */
  }

  // TODO: Validate settings

  return { ...defaultSettings, ...savedSettings };
};

export const saveSettings = () => {
  const currentSettings = useSettingsSlice.getState();
  const saveObject = Object.fromEntries(
    Object.keys(defaultSettings).map(key => [
      key,
      currentSettings[key] ?? defaultSettings[key],
    ])
  );

  window.localStorage.setItem(settingsStorageKey, JSON.stringify(saveObject));
};

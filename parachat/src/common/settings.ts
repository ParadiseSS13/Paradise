import { Highlight, SettingsData } from '~/common/types';
import { useSettingsSlice } from '../stores/settings';

const settingsStorageKey = 'parachat-settings';

export const defaultSettings: SettingsData = {
  theme: 'light',
  font: "Verdana, 'Helvetica Neue', Helvetica, Arial, sans-serif",
  fontUrl: '',
  lineHeight: 1.2,
  condenseMessages: true,
  highlights: [
    {
      term: 'Jade',
      isRegex: false,
      color: '#AAAA00',
      type: Highlight.LINE,
    },
    {
      term: 'Jade',
      isRegex: false,
      color: '#0066AA',
      type: Highlight.SIMPLE,
    },
  ],
};

export const loadSettings = () => {
  let savedSettings;
  try {
    savedSettings =
      JSON.parse(window.localStorage.getItem(settingsStorageKey)) || {};
  } catch (e) {
    /* empty */
  }

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

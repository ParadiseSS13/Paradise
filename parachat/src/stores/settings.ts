import create from 'zustand';
import { loadSettings } from '~/common/settings';
import { SettingsData } from '~/common/types';

interface SettingsSlice {
  updateSettings: (newSettings: SettingsData) => void;
}

export const useSettingsSlice = create<SettingsSlice & SettingsData>()(set => ({
  ...loadSettings(),
  updateSettings: newSettings => set(() => ({ ...newSettings })),
}));

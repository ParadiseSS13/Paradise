import { useState } from 'react';
import { saveSettings } from '~/common/settings';
import { useSettingsSlice } from '~/common/store';

export const useEditSettings = (overwrite?: boolean, settingsObject?) => {
  const [unsavedSettings, setUnsavedSettings] = useState({});
  const currentSettings = useSettingsSlice(state => settingsObject || state);

  const write = (name: string, value) => {
    setUnsavedSettings({
      ...unsavedSettings,
      [name]:
        value !== undefined && (overwrite || value !== currentSettings[name])
          ? value
          : undefined,
    });
  };

  const save = () => {
    currentSettings.updateSettings(
      Object.fromEntries(Object.entries(unsavedSettings).filter(kv => kv[1]))
    );
    setUnsavedSettings({});
    saveSettings();
  };

  return {
    currentSettings,
    unsavedSettings,
    write,
    save,
  };
};

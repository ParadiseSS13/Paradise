import create from 'zustand';
import { Tab } from '~/common/types';

interface HeaderSlice {
  debugMode: boolean;
  ping: number;
  selectedTab: Tab;
  showSettings: boolean;
  unreadTabs: {
    [tab in Tab]?: number;
  };
  clearUnreadTab: (tab: Tab) => void;
  clearUnreadTabs: () => void;
  incrementUnreadTab: (tab: Tab) => void;
  setDebugMode: (debugMode: boolean) => void;
  setPing: (ping: number) => void;
  setSelectedTab: (selectedTab: Tab) => void;
  setShowSettings: (showSettings: boolean) => void;
}

export const useHeaderSlice = create<HeaderSlice>()(set => ({
  debugMode: false,
  ping: 0,
  selectedTab: 0,
  showSettings: false,
  unreadTabs: {},
  clearUnreadTab: tab =>
    set(state => ({
      unreadTabs: {
        ...state.unreadTabs,
        [tab]: undefined,
      },
    })),
  clearUnreadTabs: () => set(() => ({ unreadTabs: {} })),
  incrementUnreadTab: tab =>
    set(state => ({
      unreadTabs: {
        ...state.unreadTabs,
        [tab]: (state.unreadTabs[tab] || 0) + 1,
      },
    })),
  setDebugMode: debugMode => set(() => ({ debugMode })),
  setPing: ping => set(() => ({ ping })),
  setSelectedTab: selectedTab => set(() => ({ selectedTab })),
  setShowSettings: showSettings => set(() => ({ showSettings })),
}));

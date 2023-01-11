import create from 'zustand';
import { loadSettings } from '~/common/settings';
import {
  HighlightEntry,
  MessageInfo,
  MessageType,
  SettingsData,
  Tab,
} from '~/common/types';
import { processHighlights } from '~/common/util';

interface HeaderSlice {
  ping: number;
  selectedTab: Tab;
  unreadTabs: { [tab in Tab]?: number };
  showSettings: boolean;
  debugMode: boolean;
  setPing: (ping: number) => void;
  setSelectedTab: (selectedTab: Tab) => void;
  incrementUnreadTab: (tab: Tab) => void;
  clearUnreadTab: (tab: Tab) => void;
  clearUnreadTabs: () => void;
  setShowSettings: (showSettings: boolean) => void;
  setDebugMode: (debugMode: boolean) => void;
}

interface MessageSlice {
  messages: Array<MessageInfo>;
  codewordHighlights: Array<HighlightEntry>;
  _addMessage: (messageInfo: MessageInfo) => void;
  rebootCompleted: () => void;
  setCodewordHighlights: (codewordHighlights: Array<HighlightEntry>) => void;
}

interface AdminSlice {
  currentAudio: string;
  setCurrentAudio: (currentAudio: string) => void;
}

interface SettingsSlice {
  updateSettings: (newSettings: SettingsData) => void;
}

export const useHeaderSlice = create<HeaderSlice>()(set => ({
  ping: 0,
  selectedTab: 0,
  unreadTabs: {},
  showSettings: false,
  debugMode: false,
  setPing: ping => set(() => ({ ping })),
  setSelectedTab: selectedTab => set(() => ({ selectedTab })),
  incrementUnreadTab: tab =>
    set(state => ({
      unreadTabs: {
        ...state.unreadTabs,
        [tab]: (state.unreadTabs[tab] || 0) + 1,
      },
    })),
  clearUnreadTab: tab =>
    set(state => ({
      unreadTabs: {
        ...state.unreadTabs,
        [tab]: undefined,
      },
    })),
  clearUnreadTabs: () => set(() => ({ unreadTabs: {} })),
  setShowSettings: showSettings => set(() => ({ showSettings })),
  setDebugMode: debugMode => set(() => ({ debugMode })),
}));

export const useMessageSlice = create<MessageSlice>()(set => ({
  messages: [],
  codewordHighlights: [],
  _addMessage: messageInfo =>
    set(state => ({ messages: [...state.messages, messageInfo] })),
  rebootCompleted: () =>
    set(state => ({
      messages: state.messages.map(message =>
        message.type === MessageType.REBOOT
          ? { ...message, params: { ...message.params, completed: true } }
          : message
      ),
    })),
  setCodewordHighlights: codewordHighlights =>
    set(() => ({ codewordHighlights })),
}));

export const useAdminSlice = create<AdminSlice>()(set => ({
  currentAudio: '',
  setCurrentAudio: currentAudio => set(() => ({ currentAudio: currentAudio })),
}));

export const useSettingsSlice = create<SettingsSlice & SettingsData>()(set => ({
  ...loadSettings(),
  updateSettings: newSettings => set(() => ({ ...newSettings })),
}));

let messageIndex = 0;
export const addMessage = ({
  text,
  type = MessageType.TEXT,
  tab = Tab.OTHER,
  params = {},
}: MessageInfo) => {
  const messageInfo = {
    id: messageIndex++,
    text,
    type,
    tab,
    params,
    ...processHighlights(text),
  };

  console.log(text);
  useMessageSlice.getState()._addMessage(messageInfo);
};

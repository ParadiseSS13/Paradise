import create from 'zustand';
import { HighlightEntry, MessageInfo, MessageType, Tab } from '~/common/types';
import { processHighlights } from '~/common/util';
import { useSettingsSlice } from '~/stores/settings';

interface MessageSlice {
  codewordHighlights: Array<HighlightEntry>;
  messages: Array<MessageInfo>;
  _addMessage: (messageInfo: MessageInfo) => void;
  condenseLastMessage: () => void;
  rebootCompleted: () => void;
  setCodewordHighlights: (codewordHighlights: Array<HighlightEntry>) => void;
}

export const useMessageSlice = create<MessageSlice>()(set => ({
  codewordHighlights: [],
  messages: [],
  _addMessage: messageInfo =>
    set(state => ({ messages: [...state.messages, messageInfo] })),
  condenseLastMessage: () =>
    set(state => ({
      messages: state.messages.map((message, index) =>
        index === state.messages.length - 1
          ? { ...message, occurences: message.occurences + 1 }
          : message
      ),
    })),
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

let messageIndex = 0;
let lastMessage;
export const addMessage = ({
  text,
  type = MessageType.TEXT,
  tab = Tab.OTHER,
  params = {},
}: MessageInfo) => {
  if (
    lastMessage &&
    lastMessage.text === text &&
    lastMessage.type === type &&
    lastMessage.tab === tab &&
    useSettingsSlice.getState().condenseMessages
  ) {
    useMessageSlice.getState().condenseLastMessage();
    return;
  }

  const messageInfo: MessageInfo = {
    id: messageIndex++,
    text,
    type,
    tab,
    params,
    occurences: 1,
    ...processHighlights(text),
  };

  console.log(text);
  useMessageSlice.getState()._addMessage(messageInfo);
  lastMessage = { text, type, tab };
};

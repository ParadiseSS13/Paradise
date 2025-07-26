/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';
import DOMPurify from 'dompurify';

import {
  addHighlightSetting,
  loadSettings,
  removeHighlightSetting,
  updateHighlightSetting,
  updateSettings,
} from '../settings/actions';
import { selectSettings } from '../settings/selectors';
import {
  addChatPage,
  changeChatPage,
  changeScrollTracking,
  clearChat,
  loadChat,
  moveChatPageLeft,
  moveChatPageRight,
  rebuildChat,
  removeChatPage,
  saveChatToDisk,
  toggleAcceptedType,
  updateMessageCount,
} from './actions';
import { MAX_PERSISTED_MESSAGES, MESSAGE_SAVE_INTERVAL } from './constants';
import { createMessage, serializeMessage } from './model';
import { chatRenderer } from './renderer';
import { selectChat, selectCurrentChatPage } from './selectors';

// List of blacklisted tags
const blacklisted_tags = ['a', 'iframe', 'link', 'video'];

const saveChatToStorage = async (store) => {
  const state = selectChat(store.getState());

  // Always save the chat state (which includes custom tabs)
  storage.set('chat-state', state);

  // Only save messages if chat saving is enabled
  const chatSavingEnabled = await storage.get('chat-saving-enabled');
  if (chatSavingEnabled !== false) {
    const fromIndex = Math.max(0, chatRenderer.messages.length - MAX_PERSISTED_MESSAGES);
    const messages = chatRenderer.messages.slice(fromIndex).map((message) => serializeMessage(message));
    storage.set('chat-messages', messages);
  }
};

const loadChatFromStorage = async (store) => {
  // Always try to load the chat state (for custom tabs)
  const state = await storage.get('chat-state');

  // Discard incompatible versions
  if (state && state.version <= 4) {
    store.dispatch(loadChat());
    return;
  }

  // Check if message saving is enabled before loading messages
  const chatSavingEnabled = await storage.get('chat-saving-enabled');
  let messages = [];

  if (chatSavingEnabled !== false) {
    messages = await storage.get('chat-messages');
    if (messages) {
      for (let message of messages) {
        if (message.html) {
          message.html = DOMPurify.sanitize(message.html, {
            FORBID_TAGS: blacklisted_tags,
          });
        }
      }
      const batch = [
        ...messages,
        createMessage({
          type: 'internal/reconnected',
        }),
      ];
      chatRenderer.processBatch(batch, {
        prepend: true,
      });
    }
  }

  // Always load the chat state (with custom tabs)
  store.dispatch(loadChat(state));
};

export const chatMiddleware = (store) => {
  let initialized = false;
  let loaded = false;
  const sequences = [];
  const sequences_requested = [];
  chatRenderer.events.on('batchProcessed', (countByType) => {
    // Use this flag to workaround unread messages caused by
    // loading them from storage. Side effect of that, is that
    // message count can not be trusted, only unread count.
    if (loaded) {
      store.dispatch(updateMessageCount(countByType));
    }
  });
  chatRenderer.events.on('scrollTrackingChanged', (scrollTracking) => {
    store.dispatch(changeScrollTracking(scrollTracking));
  });
  setInterval(() => saveChatToStorage(store), MESSAGE_SAVE_INTERVAL);
  return (next) => (action) => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      loadChatFromStorage(store);
    }
    if (type === 'chat/message') {
      let payload_obj;
      try {
        payload_obj = JSON.parse(payload);
      } catch (err) {
        return;
      }

      const sequence = payload_obj.sequence;
      if (sequences.includes(sequence)) {
        return;
      }

      const sequence_count = sequences.length;
      seq_check: if (sequence_count > 0) {
        if (sequences_requested.includes(sequence)) {
          sequences_requested.splice(sequences_requested.indexOf(sequence), 1);
          // if we are receiving a message we requested, we can stop reliability checks
          break seq_check;
        }

        // cannot do reliability if we don't have any messages
        const expected_sequence = sequences[sequence_count - 1] + 1;
        if (sequence !== expected_sequence) {
          for (let requesting = expected_sequence; requesting < sequence; requesting++) {
            // requested_sequences.push(requesting); in origin, but that calls error
            sequences_requested.push(requesting);
            Byond.sendMessage('chat/resend', requesting);
          }
        }
      }

      chatRenderer.processBatch([payload_obj.content]);
      return;
    }
    if (type === loadChat.type) {
      next(action);
      const page = selectCurrentChatPage(store.getState());
      chatRenderer.changePage(page);
      chatRenderer.onStateLoaded();
      loaded = true;
      return;
    }
    if (
      type === changeChatPage.type ||
      type === addChatPage.type ||
      type === removeChatPage.type ||
      type === toggleAcceptedType.type ||
      type === moveChatPageLeft.type ||
      type === moveChatPageRight.type
    ) {
      next(action);
      const page = selectCurrentChatPage(store.getState());
      chatRenderer.changePage(page);
      return;
    }
    if (type === rebuildChat.type) {
      chatRenderer.rebuildChat();
      return next(action);
    }
    if (
      type === updateSettings.type ||
      type === loadSettings.type ||
      type === addHighlightSetting.type ||
      type === removeHighlightSetting.type ||
      type === updateHighlightSetting.type
    ) {
      next(action);
      const settings = selectSettings(store.getState());
      chatRenderer.setHighlight(settings.highlightSettings, settings.highlightSettingById);
      return;
    }
    if (type === 'roundrestart') {
      // Save chat as soon as possible
      saveChatToStorage(store);
      return next(action);
    }
    if (type === saveChatToDisk.type) {
      chatRenderer.saveToDisk();
      return;
    }
    if (type === clearChat.type) {
      chatRenderer.clearChat();
      return;
    }
    return next(action);
  };
};

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from './logging';

const logger = createLogger('hotkeys');

// Key codes
export const KEY_BACKSPACE = 8;
export const KEY_TAB = 9;
export const KEY_ENTER = 13;
export const KEY_SHIFT = 16;
export const KEY_CTRL = 17;
export const KEY_ALT = 18;
export const KEY_ESCAPE = 27;
export const KEY_SPACE = 32;
export const ARROW_KEY_UP = 38;
export const ARROW_KEY_DOWN = 40;
export const KEY_0 = 48;
export const KEY_1 = 49;
export const KEY_2 = 50;
export const KEY_3 = 51;
export const KEY_4 = 52;
export const KEY_5 = 53;
export const KEY_6 = 54;
export const KEY_7 = 55;
export const KEY_8 = 56;
export const KEY_9 = 57;
export const KEY_A = 65;
export const KEY_B = 66;
export const KEY_C = 67;
export const KEY_D = 68;
export const KEY_E = 69;
export const KEY_F = 70;
export const KEY_G = 71;
export const KEY_H = 72;
export const KEY_I = 73;
export const KEY_J = 74;
export const KEY_K = 75;
export const KEY_L = 76;
export const KEY_M = 77;
export const KEY_N = 78;
export const KEY_O = 79;
export const KEY_P = 80;
export const KEY_Q = 81;
export const KEY_R = 82;
export const KEY_S = 83;
export const KEY_T = 84;
export const KEY_U = 85;
export const KEY_V = 86;
export const KEY_W = 87;
export const KEY_X = 88;
export const KEY_Y = 89;
export const KEY_Z = 90;
export const KEY_NUMPAD_0 = 96;
export const KEY_NUMPAD_1 = 97;
export const KEY_NUMPAD_2 = 98;
export const KEY_NUMPAD_3 = 99;
export const KEY_NUMPAD_4 = 100;
export const KEY_NUMPAD_5 = 101;
export const KEY_NUMPAD_6 = 102;
export const KEY_NUMPAD_7 = 103;
export const KEY_NUMPAD_8 = 104;
export const KEY_NUMPAD_9 = 105;
export const KEY_F1 = 112;
export const KEY_F2 = 113;
export const KEY_F3 = 114;
export const KEY_F4 = 115;
export const KEY_F5 = 116;
export const KEY_F6 = 117;
export const KEY_F7 = 118;
export const KEY_F8 = 119;
export const KEY_F9 = 120;
export const KEY_F10 = 121;
export const KEY_F11 = 122;
export const KEY_F12 = 123;
export const KEY_EQUAL = 187;
export const KEY_MINUS = 189;

const MODIFIER_KEYS = [KEY_CTRL, KEY_ALT, KEY_SHIFT];

const NO_PASSTHROUGH_KEYS = [
  KEY_ESCAPE,
  KEY_ENTER,
  KEY_SPACE,
  KEY_TAB,
  KEY_CTRL,
  KEY_SHIFT,
  KEY_ALT, // to prevent alt tabbing breaking shit
  KEY_F1,
  KEY_F2,
  KEY_F3,
  KEY_F4,
  KEY_F5,
  KEY_F6,
  KEY_F7,
  KEY_F8,
  KEY_F9,
  KEY_F10,
  KEY_F11,
  KEY_F12,
];

// Tracks the "pressed" state of keys
const keyState = {};

const createHotkeyString = (ctrlKey, altKey, shiftKey, keyCode) => {
  let str = '';
  if (ctrlKey) {
    str += 'Ctrl+';
  }
  if (altKey) {
    str += 'Alt+';
  }
  if (shiftKey) {
    str += 'Shift+';
  }
  if (keyCode >= 48 && keyCode <= 90) {
    str += String.fromCharCode(keyCode);
  } else if (keyCode >= KEY_F1 && keyCode <= KEY_F12) {
    str += 'F' + (keyCode - 111);
  } else {
    str += '[' + keyCode + ']';
  }
  return str;
};

/**
 * Parses the event and compiles information about the keypress.
 */
const getKeyData = (e) => {
  const keyCode = window.event ? e.which : e.keyCode;
  const { ctrlKey, altKey, shiftKey } = e;
  return {
    keyCode,
    ctrlKey,
    altKey,
    shiftKey,
    hasModifierKeys: ctrlKey || altKey || shiftKey,
    keyString: createHotkeyString(ctrlKey, altKey, shiftKey, keyCode),
  };
};

const keyCodeToByond = (keyCode) => {
  const dict = {
    16: 'Shift',
    17: 'Ctrl',
    18: 'Alt',
    33: 'Northeast',
    34: 'Southeast',
    35: 'Southwest',
    36: 'Northwest',
    37: 'West',
    38: 'North',
    39: 'East',
    40: 'South',
    45: 'Insert',
    46: 'Delete',
  };

  if (dict[keyCode]) {
    return dict[keyCode];
  }
  if ((keyCode >= 48 && keyCode <= 57) || (keyCode >= 65 && keyCode <= 90)) {
    return String.fromCharCode(keyCode);
  }
  if (keyCode >= 96 && keyCode <= 105) {
    return 'Numpad' + (keyCode - 96);
  }
  if (keyCode >= 112 && keyCode <= 123) {
    return 'F' + (keyCode - 111);
  }
  if (keyCode === 188) {
    return ',';
  }
  if (keyCode === 189) {
    return '-';
  }
  if (keyCode === 190) {
    return '.';
  }
};

/**
 * Keyboard passthrough logic. This allows you to keep doing things
 * in game while the browser window is focused.
 */
const handlePassthrough = (e, eventType) => {
  if (e.defaultPrevented) {
    return;
  }
  const targetName = e.target && e.target.localName;
  if (targetName === 'input' || targetName === 'textarea') {
    return;
  }
  const keyData = getKeyData(e);
  const { keyCode, ctrlKey, shiftKey } = keyData;
  const byondKey = keyCodeToByond(keyCode);

  if (NO_PASSTHROUGH_KEYS.includes(keyCode)) {
    return;
  }
  if (ctrlKey || shiftKey || NO_PASSTHROUGH_KEYS.includes(keyCode)) {
    return;
  }
  // Send this keypress to BYOND
  if (eventType === 'keydown' && !keyState[keyCode]) {
    logger.debug('passthrough', eventType, keyData);
    return Byond.topic({ __keydown: keyCode });
  }
  if (eventType === 'keyup' && keyState[keyCode]) {
    logger.debug('passthrough', eventType, keyData);
    return Byond.topic({ __keyup: keyCode });
  }
};

/**
 * Cleanup procedure for keyboard passthrough, which should be called
 * whenever you're unloading tgui.
 */
export const releaseHeldKeys = () => {
  for (let keyCode of Object.keys(keyState)) {
    if (keyState[keyCode]) {
      const byondKey = keyCodeToByond(keyCode);
      logger.log(`releasing [${keyCode}] key`);
      keyState[keyCode] = false;
      Byond.topic({ __keyup: byondKey });
    }
  }
};

const hotKeySubscribers = [];

/**
 * Subscribes to a certain hotkey, and dispatches a redux action returned
 * by the callback function.
 */
export const subscribeToHotKey = (keyString, fn) => {
  hotKeySubscribers.push((store, keyData) => {
    if (keyData.keyString === keyString) {
      const action = fn(store);
      if (action) {
        store.dispatch(action);
      }
    }
  });
};

const handleHotKey = (e, eventType, store) => {
  if (eventType !== 'keyup') {
    return;
  }
  const keyData = getKeyData(e);
  const { keyCode, hasModifierKeys, keyString } = keyData;
  // Dispatch a detected hotkey as a store action
  if (
    (hasModifierKeys && !MODIFIER_KEYS.includes(keyCode)) ||
    (keyCode >= KEY_F1 && keyCode <= KEY_F12)
  ) {
    logger.log(keyString);
    for (let subscriberFn of hotKeySubscribers) {
      subscriberFn(store, keyData);
    }
  }
};

/**
 * Subscribe to an event when browser window has been completely
 * unfocused. Conveniently fires events when the browser window
 * is closed from the outside.
 */
const subscribeToLossOfFocus = (listenerFn) => {
  let timeout;
  document.addEventListener('focusout', () => {
    timeout = setTimeout(listenerFn);
  });
  document.addEventListener('focusin', () => {
    clearTimeout(timeout);
  });
  window.addEventListener('beforeunload', listenerFn);
};

/**
 * Subscribe to keydown/keyup events with globally tracked key state.
 */
const subscribeToKeyPresses = (listenerFn) => {
  document.addEventListener('keydown', (e) => {
    const keyCode = window.event ? e.which : e.keyCode;
    listenerFn(e, 'keydown');
    keyState[keyCode] = true;
  });
  document.addEventListener('keyup', (e) => {
    const keyCode = window.event ? e.which : e.keyCode;
    listenerFn(e, 'keyup');
    keyState[keyCode] = false;
  });
};

// Middleware
export const hotKeyMiddleware = (store) => {
  // Subscribe to key events
  subscribeToKeyPresses((e, eventType) => {
    // IE8: Can't determine the focused element, so by extension it passes
    // keypresses when inputs are focused.
    if (!Byond.IS_LTE_IE8) {
      handlePassthrough(e, eventType);
    }
    handleHotKey(e, eventType, store);
  });
  // IE8: focusin/focusout only available on IE9+
  if (!Byond.IS_LTE_IE8) {
    // Clean up when browser window completely loses focus
    subscribeToLossOfFocus(() => {
      releaseHeldKeys();
    });
  }
  // Pass through store actions (do nothing)
  return (next) => (action) => next(action);
};

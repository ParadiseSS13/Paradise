import { debounce, throttle } from 'tgui-core/timer';

const SECONDS = 1000;

/** Timers: Prevents overloading the server, throttles messages */
export const byondMessages = {
  // Debounce: Prevents spamming the server
  channelIncrementMsg: debounce((visible: boolean) => Byond.sendMessage('thinking', { visible }), 0.4 * SECONDS),
  // Throttle: Prevents spamming the server
  typingMsg: throttle((isMeChannel: boolean) => Byond.sendMessage('typing', { isMeChannel }), 4 * SECONDS),
} as const;

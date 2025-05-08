import { Channel } from './ChannelIterator';
import { WINDOW_SIZES } from './constants';

/**
 * Once byond signals this via keystroke, it
 * ensures window size, visibility, and focus.
 */
export const windowOpen = (channel: Channel, scale: boolean) => {
  setWindowVisibility(true, scale);
  Byond.sendMessage('open', { channel });
};

/**
 * Resets the state of the window and hides it from user view.
 * Sending "close" logs it server side.
 */
export const windowClose = (scale: boolean) => {
  setWindowVisibility(false, scale);
  Byond.winset('map', {
    focus: true,
  });
  Byond.sendMessage('close');
};

/**
 * Modifies the window size.
 */
export const windowSet = (size = WINDOW_SIZES.small, scale: boolean) => {
  const pixelRatio = scale ? window.devicePixelRatio : 1;
  const sizeStr = `${WINDOW_SIZES.width * pixelRatio}x${size * pixelRatio}`;

  Byond.winset('tgui_say.browser', {
    size: sizeStr,
  });

  Byond.winset('tgui_say', {
    size: sizeStr,
  });
};
/** Helper function to set window size and visibility */
const setWindowVisibility = (visible: boolean, scale: boolean): void => {
  const pixelRatio = scale ? window.devicePixelRatio : 1;
  let sizeStr = `${WINDOW_SIZES.width * pixelRatio}x${WINDOW_SIZES.small * pixelRatio}`;

  Byond.winset('tgui_say', {
    'is-visible': visible,
    'size': sizeStr,
  });

  Byond.winset('tgui_say.browser', {
    'size': sizeStr,
  });
};

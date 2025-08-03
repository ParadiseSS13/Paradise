/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';

import { setClientTheme } from '../themes';
import {
  addHighlightSetting,
  loadSettings,
  removeHighlightSetting,
  updateHighlightSetting,
  updateSettings,
} from './actions';
import { FONTS_DISABLED } from './constants';
import { selectSettings } from './selectors';

let statFontSizeTimer;
let statFontFamilyTimer;
let statTabsTimer;

const setGlobalFontSize = (fontSize, statFontSize, statLinked) => {
  document.documentElement.style.setProperty('font-size', fontSize + 'px');
  document.body.style.setProperty('font-size', fontSize + 'px');

  // Used solution from theme.ts
  clearInterval(statFontSizeTimer);
  Byond.command(`.output statbrowser:set_font_size ${statLinked ? fontSize : statFontSize}px`);
  statFontSizeTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_font_size ${statLinked ? fontSize : statFontSize}px`);
  }, 1500);
};

const setGlobalFontFamily = (fontFamily, statFontFamily, statLinked) => {
  if (fontFamily === FONTS_DISABLED) {
    fontFamily = null;
  }

  if (statFontFamily === FONTS_DISABLED) {
    statFontFamily = null;
  }

  document.documentElement.style.setProperty('font-family', fontFamily);
  document.body.style.setProperty('font-family', fontFamily);

  // Used solution from theme.ts
  clearInterval(statFontFamilyTimer);
  Byond.command(`.output statbrowser:set_font_style ${statLinked ? fontFamily : statFontFamily}`);
  statFontFamilyTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_font_style ${statLinked ? fontFamily : statFontFamily}`);
  }, 1500);
};

const setStatTabsStyle = (style) => {
  // Well... another timer copy-paste
  clearInterval(statTabsTimer);
  Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  statTabsTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  }, 1500);
};

export const settingsMiddleware = (store) => {
  let initialized = false;
  return (next) => (action) => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      storage.get('panel-settings').then((settings) => {
        store.dispatch(loadSettings(settings));
      });
    }
    if (
      type === updateSettings.type ||
      type === loadSettings.type ||
      type === addHighlightSetting.type ||
      type === removeHighlightSetting.type ||
      type === updateHighlightSetting.type
    ) {
      // Set client theme
      const theme = payload?.theme;
      if (theme) {
        setClientTheme(theme);
      }
      // Pass action to get an updated state
      next(action);

      const settings = selectSettings(store.getState());

      // Update stat panel personal settings
      setStatTabsStyle(settings.statTabsStyle);

      // Update global UI font size
      setGlobalFontSize(settings.fontSize, settings.statFontSize, settings.statLinked);
      setGlobalFontFamily(settings.fontFamily, settings.statFontFamily, settings.statLinked);

      // Save settings to the web storage
      storage.set('panel-settings', settings);
      return;
    }
    return next(action);
  };
};

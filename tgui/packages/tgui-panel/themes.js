/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const THEMES = ['light', 'dark'];

const COLOR_DARK_BG = '#202020';
const COLOR_DARK_BG_DARKER = '#131313';
const COLOR_DARK_BG_BUTTON = '#4C4C4D';
const COLOR_DARK_TEXT = '#A4BAD6';

const COLOR_LIGHT_BG = '#EEEEEE';
const COLOR_LIGHT_BG_LIGHTER = '#FFFFFF';
const COLOR_LIGHT_BUTTON = '#EEEEEE';
const COLOR_LIGHT_TEXT = '#000000';

/**
 * Darkmode preference, originally by Kmc2000.
 *
 * This lets you switch client themes by using winset.
 *
 * If you change ANYTHING in interface/skin.dmf you need to change it here.
 *
 * There's no way round it. We're essentially changing the skin by hand.
 * It's painful but it works, and is the way Lummox suggested.
 */
export const setClientTheme = (name) => {
  if (name === 'light') {
    return Byond.winset({
      /* Buttons */
      'rpane.textb.background-color': COLOR_LIGHT_BUTTON,
      'rpane.textb.text-color': COLOR_LIGHT_TEXT,
      'rpane.infob.background-color': COLOR_LIGHT_BUTTON,
      'rpane.infob.text-color': COLOR_LIGHT_TEXT,
      'rpane.wikib.background-color': COLOR_LIGHT_BUTTON,
      'rpane.wikib.text-color': COLOR_LIGHT_TEXT,
      'rpane.forumb.background-color': COLOR_LIGHT_BUTTON,
      'rpane.forumb.text-color': COLOR_LIGHT_TEXT,
      'rpane.rulesb.background-color': COLOR_LIGHT_BUTTON,
      'rpane.rulesb.text-color': COLOR_LIGHT_TEXT,
      'rpane.githubb.background-color': COLOR_LIGHT_BUTTON,
      'rpane.githubb.text-color': COLOR_LIGHT_TEXT,
      'rpane.webmap.background-color': COLOR_LIGHT_BUTTON,
      'rpane.webmap.text-color': COLOR_LIGHT_TEXT,
      'rpane.changelog.background-color': COLOR_LIGHT_BUTTON,
      'rpane.changelog.text-color': COLOR_LIGHT_TEXT,
      /* Mainwindow */
      'mainwindow.background-color': COLOR_LIGHT_BG,
      'mainwindow.mainvsplit.background-color': COLOR_LIGHT_BG,
      'mainwindow.tooltip.background-color': COLOR_LIGHT_BG,
      'outputwindow.background-color': COLOR_LIGHT_BG,
      'outputwindow.text-color': COLOR_LIGHT_TEXT,
      /* Rpane */
      'rpane.background-color': COLOR_LIGHT_BG,
      'rpane.rpanewindow.background-color': COLOR_LIGHT_BG,
      /* Infowindow */
      'infowindow.background-color': COLOR_LIGHT_BG,
      'infowindow.text-color': COLOR_LIGHT_TEXT,
      'infowindow.info.background-color': COLOR_LIGHT_BG_LIGHTER,
      'infowindow.info.text-color': COLOR_LIGHT_TEXT,
      'infowindow.info.highlight-color': '#009900',
      'infowindow.info.tab-text-color': COLOR_LIGHT_TEXT,
      'infowindow.info.tab-background-color': COLOR_LIGHT_BG,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_LIGHT_BG,
      'saybutton.text-color': COLOR_LIGHT_TEXT,
      'oocbutton.background-color': COLOR_LIGHT_BG,
      'oocbutton.text-color': COLOR_LIGHT_TEXT,
      'mebutton.background-color': COLOR_LIGHT_BG,
      'mebutton.text-color': COLOR_LIGHT_TEXT,
      'asset_cache_browser.background-color': COLOR_LIGHT_BG,
      'asset_cache_browser.text-color': COLOR_LIGHT_TEXT,
      'tooltip.background-color': COLOR_LIGHT_BG,
      'tooltip.text-color': COLOR_LIGHT_TEXT,
      'input.background-color': COLOR_LIGHT_BG_LIGHTER,
      'input.text-color': COLOR_LIGHT_TEXT,
    });
  }

  if (name === 'dark') {
    Byond.winset({
      /* Buttons */
      'rpane.textb.background-color': COLOR_DARK_BG_BUTTON,
      'rpane.textb.text-color': COLOR_DARK_TEXT,
      'rpane.infob.background-color': COLOR_DARK_BG_BUTTON,
      'rpane.infob.text-color': COLOR_DARK_TEXT,
      'rpane.wikib.background-color': COLOR_DARK_BG_BUTTON,
      'rpane.wikib.text-color': COLOR_DARK_TEXT,
      'rpane.forumb.background-color': COLOR_DARK_BG_BUTTON,
      'rpane.forumb.text-color': COLOR_DARK_TEXT,
      'rpane.rulesb.background-color': COLOR_DARK_BG_BUTTON,
      'rpane.rulesb.text-color': COLOR_DARK_TEXT,
      'rpane.githubb.background-color': COLOR_DARK_BG_BUTTON,
      'rpane.githubb.text-color': COLOR_DARK_TEXT,
      'rpane.webmap.background-color': COLOR_DARK_BG_BUTTON,
      'rpane.webmap.text-color': COLOR_DARK_TEXT,
      'rpane.changelog.background-color': '#40628A',
      'rpane.changelog.text-color': '#FFFFFF',
      /* Mainwindow */
      'mainwindow.background-color': COLOR_DARK_BG_DARKER,
      'mainwindow.mainvsplit.background-color': COLOR_DARK_BG,
      'mainwindow.tooltip.background-color': COLOR_DARK_BG_DARKER,
      'outputwindow.background-color': COLOR_DARK_BG,
      'outputwindow.text-color': COLOR_DARK_TEXT,
      /* Rpane */
      'rpane.background-color': COLOR_DARK_BG,
      'rpane.rpanewindow.background-color': COLOR_DARK_BG,
      /* Infowindow */
      'infowindow.background-color': COLOR_DARK_BG,
      'infowindow.text-color': COLOR_DARK_TEXT,
      'infowindow.info.background-color': COLOR_DARK_BG_DARKER,
      'infowindow.info.text-color': COLOR_DARK_TEXT,
      'infowindow.info.highlight-color': '#009900',
      'infowindow.info.tab-text-color': COLOR_DARK_TEXT,
      'infowindow.info.tab-background-color': COLOR_DARK_BG,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_DARK_BG_DARKER,
      'saybutton.text-color': COLOR_DARK_TEXT,
      'oocbutton.background-color': COLOR_DARK_BG_DARKER,
      'oocbutton.text-color': COLOR_DARK_TEXT,
      'mebutton.background-color': COLOR_DARK_BG_DARKER,
      'mebutton.text-color': COLOR_DARK_TEXT,
      'asset_cache_browser.background-color': COLOR_DARK_BG_DARKER,
      'asset_cache_browser.text-color': COLOR_DARK_TEXT,
      'tooltip.background-color': COLOR_DARK_BG_DARKER,
      'tooltip.text-color': COLOR_DARK_TEXT,
      'input.background-color': COLOR_DARK_BG_DARKER,
      'input.text-color': COLOR_DARK_TEXT,
    });
  }
};

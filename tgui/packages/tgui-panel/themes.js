/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const THEMES = ['light', 'dark', 'ntos', 'syndicate', 'paradise'];

const COLOR_DARK_BG = '#212020';
const COLOR_DARK_BG_DARKER = '#131313';
const COLOR_DARK_BG_BUTTON = '#4C4C4D';
const COLOR_DARK_TEXT = '#A4BAD6';

const COLOR_LIGHT_BG = '#EFEEEE';
const COLOR_LIGHT_BG_LIGHTER = '#FFFFFF';
const COLOR_LIGHT_BUTTON = '#EEEEEE';
const COLOR_LIGHT_TEXT = '#000000';

const COLOR_NTOS_BG = '#1b2633';
const COLOR_NTOS_BG_DARKER = '#121922';
const COLOR_NTOS_BUTTON = '#384e68';
const COLOR_NTOS_TEXT = '#b8cbe6';

const COLOR_SYNDICATE_BG = '#4d0202';
const COLOR_SYNDICATE_BG_DARKER = '#2b0101';
const COLOR_SYNDICATE_BUTTON = '#397439';
const COLOR_SYNDICATE_TEXT = '#ffffff';

const COLOR_PARADISE_BG = '#800448';
const COLOR_PARADISE_BG_DARKER = '#400125';
const COLOR_PARADISE_BUTTON = '#208080';
const COLOR_PARADISE_TEXT = '#ffffff';

let setClientThemeTimer = null;

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
  // Transmit once for fast updates and again in a little while in case we won
  // the race against statbrowser init.
  clearInterval(setClientThemeTimer);
  Byond.command(`.output statbrowser:set_theme ${name}`);
  setClientThemeTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_theme ${name}`);
  }, 1500);
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
      'mainwindow.mainvsplit.background-color': '#EFEEEE',
      'mainwindow.tooltip.background-color': COLOR_LIGHT_BG,
      'outputwindow.background-color': COLOR_LIGHT_BG,
      'outputwindow.text-color': COLOR_LIGHT_TEXT,
      /* Rpane */
      'rpane.background-color': COLOR_LIGHT_BG,
      'rpane.rpanewindow.background-color': COLOR_LIGHT_BG,
      /* Infowindow */
      'infowindow.background-color': COLOR_LIGHT_BG,
      'infowindow.text-color': COLOR_LIGHT_TEXT,
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
      'mainwindow.mainvsplit.background-color': '#212020',
      'mainwindow.tooltip.background-color': COLOR_DARK_BG_DARKER,
      'outputwindow.background-color': COLOR_DARK_BG,
      'outputwindow.text-color': COLOR_DARK_TEXT,
      /* Rpane */
      'rpane.background-color': COLOR_DARK_BG,
      'rpane.rpanewindow.background-color': COLOR_DARK_BG,
      /* Infowindow */
      'infowindow.background-color': COLOR_DARK_BG,
      'infowindow.text-color': COLOR_DARK_TEXT,
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

  if (name === 'ntos') {
    return Byond.winset({
      /* Buttons */
      'rpane.textb.background-color': COLOR_NTOS_BUTTON,
      'rpane.textb.text-color': COLOR_NTOS_TEXT,
      'rpane.infob.background-color': COLOR_NTOS_BUTTON,
      'rpane.infob.text-color': COLOR_NTOS_TEXT,
      'rpane.wikib.background-color': COLOR_NTOS_BUTTON,
      'rpane.wikib.text-color': COLOR_NTOS_TEXT,
      'rpane.forumb.background-color': COLOR_NTOS_BUTTON,
      'rpane.forumb.text-color': COLOR_NTOS_TEXT,
      'rpane.rulesb.background-color': COLOR_NTOS_BUTTON,
      'rpane.rulesb.text-color': COLOR_NTOS_TEXT,
      'rpane.githubb.background-color': COLOR_NTOS_BUTTON,
      'rpane.githubb.text-color': COLOR_NTOS_TEXT,
      'rpane.webmap.background-color': COLOR_NTOS_BUTTON,
      'rpane.webmap.text-color': COLOR_NTOS_TEXT,
      'rpane.changelog.background-color': COLOR_NTOS_BUTTON,
      'rpane.changelog.text-color': COLOR_NTOS_TEXT,
      /* Mainwindow */
      'mainwindow.background-color': COLOR_NTOS_BG,
      'mainwindow.mainvsplit.background-color': COLOR_NTOS_BG,
      'mainwindow.tooltip.background-color': COLOR_NTOS_BG,
      'outputwindow.background-color': COLOR_NTOS_BG,
      'outputwindow.text-color': COLOR_NTOS_TEXT,
      /* Rpane */
      'rpane.background-color': COLOR_NTOS_BG,
      'rpane.rpanewindow.background-color': COLOR_NTOS_BG,
      /* Infowindow */
      'infowindow.background-color': COLOR_NTOS_BG,
      'infowindow.text-color': COLOR_NTOS_TEXT,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_NTOS_BG,
      'saybutton.text-color': COLOR_NTOS_TEXT,
      'oocbutton.background-color': COLOR_NTOS_BG,
      'oocbutton.text-color': COLOR_NTOS_TEXT,
      'mebutton.background-color': COLOR_NTOS_BG,
      'mebutton.text-color': COLOR_NTOS_TEXT,
      'asset_cache_browser.background-color': COLOR_NTOS_BG,
      'asset_cache_browser.text-color': COLOR_NTOS_TEXT,
      'tooltip.background-color': COLOR_NTOS_BG,
      'tooltip.text-color': COLOR_NTOS_TEXT,
      'input.background-color': COLOR_NTOS_BG_DARKER,
      'input.text-color': COLOR_NTOS_TEXT,
    });
  }

  if (name === 'syndicate') {
    return Byond.winset({
      /* Buttons */
      'rpane.textb.background-color': COLOR_SYNDICATE_BUTTON,
      'rpane.textb.text-color': COLOR_SYNDICATE_TEXT,
      'rpane.infob.background-color': COLOR_SYNDICATE_BUTTON,
      'rpane.infob.text-color': COLOR_SYNDICATE_TEXT,
      'rpane.wikib.background-color': COLOR_SYNDICATE_BUTTON,
      'rpane.wikib.text-color': COLOR_SYNDICATE_TEXT,
      'rpane.forumb.background-color': COLOR_SYNDICATE_BUTTON,
      'rpane.forumb.text-color': COLOR_SYNDICATE_TEXT,
      'rpane.rulesb.background-color': COLOR_SYNDICATE_BUTTON,
      'rpane.rulesb.text-color': COLOR_SYNDICATE_TEXT,
      'rpane.githubb.background-color': COLOR_SYNDICATE_BUTTON,
      'rpane.githubb.text-color': COLOR_SYNDICATE_TEXT,
      'rpane.webmap.background-color': COLOR_SYNDICATE_BUTTON,
      'rpane.webmap.text-color': COLOR_SYNDICATE_TEXT,
      'rpane.changelog.background-color': COLOR_SYNDICATE_BUTTON,
      'rpane.changelog.text-color': COLOR_SYNDICATE_TEXT,
      /* Mainwindow */
      'mainwindow.background-color': COLOR_SYNDICATE_BG,
      'mainwindow.mainvsplit.background-color': COLOR_SYNDICATE_BG,
      'mainwindow.tooltip.background-color': COLOR_SYNDICATE_BG,
      'outputwindow.background-color': COLOR_SYNDICATE_BG,
      'outputwindow.text-color': COLOR_SYNDICATE_TEXT,
      /* Rpane */
      'rpane.background-color': COLOR_SYNDICATE_BG,
      'rpane.rpanewindow.background-color': COLOR_SYNDICATE_BG,
      /* Infowindow */
      'infowindow.background-color': COLOR_SYNDICATE_BG,
      'infowindow.text-color': COLOR_SYNDICATE_TEXT,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_SYNDICATE_BG,
      'saybutton.text-color': COLOR_SYNDICATE_TEXT,
      'oocbutton.background-color': COLOR_SYNDICATE_BG,
      'oocbutton.text-color': COLOR_SYNDICATE_TEXT,
      'mebutton.background-color': COLOR_SYNDICATE_BG,
      'mebutton.text-color': COLOR_SYNDICATE_TEXT,
      'asset_cache_browser.background-color': COLOR_SYNDICATE_BG,
      'asset_cache_browser.text-color': COLOR_SYNDICATE_TEXT,
      'tooltip.background-color': COLOR_SYNDICATE_BG,
      'tooltip.text-color': COLOR_SYNDICATE_TEXT,
      'input.background-color': COLOR_SYNDICATE_BG_DARKER,
      'input.text-color': COLOR_SYNDICATE_TEXT,
    });
  }

  if (name === 'paradise') {
    return Byond.winset({
      /* Buttons */
      'rpane.textb.background-color': COLOR_PARADISE_BUTTON,
      'rpane.textb.text-color': COLOR_PARADISE_TEXT,
      'rpane.infob.background-color': COLOR_PARADISE_BUTTON,
      'rpane.infob.text-color': COLOR_PARADISE_TEXT,
      'rpane.wikib.background-color': COLOR_PARADISE_BUTTON,
      'rpane.wikib.text-color': COLOR_PARADISE_TEXT,
      'rpane.forumb.background-color': COLOR_PARADISE_BUTTON,
      'rpane.forumb.text-color': COLOR_PARADISE_TEXT,
      'rpane.rulesb.background-color': COLOR_PARADISE_BUTTON,
      'rpane.rulesb.text-color': COLOR_PARADISE_TEXT,
      'rpane.githubb.background-color': COLOR_PARADISE_BUTTON,
      'rpane.githubb.text-color': COLOR_PARADISE_TEXT,
      'rpane.webmap.background-color': COLOR_PARADISE_BUTTON,
      'rpane.webmap.text-color': COLOR_PARADISE_TEXT,
      'rpane.changelog.background-color': COLOR_PARADISE_BUTTON,
      'rpane.changelog.text-color': COLOR_PARADISE_TEXT,
      /* Mainwindow */
      'mainwindow.background-color': COLOR_PARADISE_BG,
      'mainwindow.mainvsplit.background-color': COLOR_PARADISE_BG,
      'mainwindow.tooltip.background-color': COLOR_PARADISE_BG,
      'outputwindow.background-color': COLOR_PARADISE_BG,
      'outputwindow.text-color': COLOR_PARADISE_TEXT,
      /* Rpane */
      'rpane.background-color': COLOR_PARADISE_BG,
      'rpane.rpanewindow.background-color': COLOR_PARADISE_BG,
      /* Infowindow */
      'infowindow.background-color': COLOR_PARADISE_BG,
      'infowindow.text-color': COLOR_PARADISE_TEXT,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_PARADISE_BG,
      'saybutton.text-color': COLOR_PARADISE_TEXT,
      'oocbutton.background-color': COLOR_PARADISE_BG,
      'oocbutton.text-color': COLOR_PARADISE_TEXT,
      'mebutton.background-color': COLOR_PARADISE_BG,
      'mebutton.text-color': COLOR_PARADISE_TEXT,
      'asset_cache_browser.background-color': COLOR_PARADISE_BG,
      'asset_cache_browser.text-color': COLOR_PARADISE_TEXT,
      'tooltip.background-color': COLOR_PARADISE_BG,
      'tooltip.text-color': COLOR_PARADISE_TEXT,
      'input.background-color': COLOR_PARADISE_BG_DARKER,
      'input.text-color': COLOR_PARADISE_TEXT,
    });
  }
};

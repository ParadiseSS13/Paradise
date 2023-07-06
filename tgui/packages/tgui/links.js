/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { callByond } from './byond';

/**
 * Prevents baby jailing the user when he clicks an external link.
 */
export const captureExternalLinks = () => {
  // Click handler
  const listenerFn = e => {
    const tagName = String(e.target.tagName).toLowerCase();
    const href = String(e.target.href);
    // Must be a link
    if (tagName !== 'a') {
      return;
    }
    // Leave BYOND links alone
    const isByondLink = href.charAt(0) === '?'
      || href.startsWith(location.origin)
      || href.startsWith('byond://');
    if (isByondLink) {
      return;
    }
    // Prevent default action
    e.preventDefault();
    // Open the link
    callByond('', {
      src: window.__ref__,
      action: 'tgui:link',
      url: href,
    });
  };
  // Subscribe to all document clicks
  document.addEventListener('click', listenerFn);
};

/**
 * @file
 */
import { createUuid } from 'tgui-core/uuid';

export const createHighlightSetting = (obj?: Record<string, any>) => ({
  id: createUuid(),
  highlightText: '',
  highlightColor: '#ffdd44',
  highlightWholeMessage: true,
  matchWord: false,
  matchCase: false,
  ...obj,
});

export const createDefaultHighlightSetting = (obj?: Record<string, any>) =>
  createHighlightSetting({
    id: 'default',
    ...obj,
  });

export const createBlacklistSetting = (obj?: Record<string, any>) => ({
  id: createUuid(),
  blacklistText: '',
  censor: false,
  matchWord: false,
  matchCase: false,
  ...obj,
});

export const createDefaultBlacklistSetting = (obj?: Record<string, any>) =>
  createBlacklistSetting({
    id: 'default',
    ...obj,
  });

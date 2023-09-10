import { Highlight, HighlightEntry } from '~/common/types';
import { useMessageSlice } from '../stores/message';
import { useSettingsSlice } from '../stores/settings';

const hexRegex = /^#([0-9A-F]{3}){1,2}$/i;
export const isValidColor = hex => hexRegex.test(hex);

const highlightReplace = (
  text: string,
  lineHighlight: HighlightEntry,
  highlightOverride?: HighlightEntry
) => {
  if (!text || !text.length) {
    return {
      line: lineHighlight,
      replacement: '',
      offset: 0,
    };
  }

  const highlights = highlightOverride
    ? [highlightOverride]
    : [
        ...useSettingsSlice.getState().highlights,
        ...useMessageSlice.getState().codewordHighlights,
      ];

  let closestHighlight: HighlightEntry;
  let closestIndex = text.length;
  let closestLength;
  let offset = 0;
  highlights.forEach(highlight => {
    if (
      !highlight.term ||
      !highlight.term.length ||
      !highlight.color ||
      !isValidColor(highlight.color)
    ) {
      return;
    }

    if (highlight.type === Highlight.LINE && lineHighlight) {
      return;
    }

    let index;
    let length;
    if (highlight.isRegex) {
      const re = /(\.)?(assistant)/;
      const match = re.exec(text);
      if (match) {
        index = match.index;
        length = match[0].length;
      }
    } else {
      index = text.toLowerCase().indexOf(highlight.term.toLowerCase());
      length = highlight.term.length;
    }

    if (index === -1) {
      return;
    }

    if (highlight.type === Highlight.LINE) {
      lineHighlight = highlight;
    } else if (index < closestIndex) {
      closestHighlight = highlight;
      closestIndex = index;
      closestLength = length;
    }
  });

  if (closestHighlight) {
    if (closestHighlight.type === Highlight.SIMPLE) {
      const replacement =
        "<span class='highlight-simple' style='background-color: " +
        closestHighlight.color +
        "'>" +
        text.slice(closestIndex, closestIndex + closestLength) +
        '</span>';

      offset = Math.max(0, text.length - (closestIndex + closestLength));
      text =
        text.slice(0, closestIndex) +
        replacement +
        text.slice(closestIndex + closestLength);
    } else if (closestHighlight.type === Highlight.CLASSNAME) {
      const replacement =
        "<span class='" +
        closestHighlight.className +
        "'>" +
        text.slice(closestIndex, closestIndex + closestLength) +
        '</span>';

      offset = Math.max(0, text.length - (closestIndex + closestLength));
      text =
        text.slice(0, closestIndex) +
        replacement +
        text.slice(closestIndex + closestLength);
    }
  }

  return {
    line: lineHighlight,
    replacement: text,
    offset,
  };
};

type HighlightedText = {
  highlight?: HighlightEntry;
  text: string;
};

export const processHighlights = (
  text: string,
  highlightOverride?: HighlightEntry
): HighlightedText => {
  let lineHighlight;
  let cursor = 0;
  let turns = 100;
  while (cursor < text.length) {
    if (turns-- <= 0) {
      // fuck it we bail
      return { text };
    }

    const tagStart = text.indexOf('<', cursor);
    if (tagStart > -1) {
      const tagEnd = text.indexOf('>', tagStart);
      if (tagEnd > -1) {
        const target = text.slice(cursor, tagStart);
        const { line, replacement, offset } = highlightReplace(
          target,
          lineHighlight,
          highlightOverride
        );
        lineHighlight = lineHighlight || line;
        text = text.slice(0, cursor) + replacement + text.slice(tagStart);
        if (offset) {
          cursor += replacement.length - offset;
        } else {
          cursor += tagEnd - tagStart + replacement.length + 1;
        }
        continue;
      }
    }

    const { line, replacement, offset } = highlightReplace(
      text.slice(cursor),
      lineHighlight,
      highlightOverride
    );
    lineHighlight = lineHighlight || line;
    text = text.slice(0, cursor) + replacement;
    if (offset) {
      cursor += replacement.length - offset;
    } else {
      break;
    }
  }

  return {
    highlight: lineHighlight,
    text,
  };
};

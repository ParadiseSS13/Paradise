import { useMessageSlice } from '~/common/store';
import { ByondCall, Highlight, HighlightEntry } from '~/common/types';

export const codewords = (phrases, responses) => {
  const highlights: Array<HighlightEntry> = [];

  const processCodewords = (codeword, className) => {
    codeword = codeword.trim();
    if (!codeword.length) {
      return;
    }

    highlights.push({
      term: codeword,
      isRegex: false,
      type: Highlight.CLASSNAME,
      className,
    });
  };

  phrases
    .split(',')
    .forEach(codeword => processCodewords(codeword, 'codephrases'));
  responses
    .split(',')
    .forEach(codeword => processCodewords(codeword, 'coderesponses'));

  useMessageSlice.getState().setCodewordHighlights(highlights);
};

export const codewordsClear: ByondCall = topic => {};

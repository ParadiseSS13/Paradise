export type HighlightEntry = {
  term: string;
  isRegex: boolean;
  color?: string;
  type: Highlight;
  /**
   * Used by Highlight.CLASSNAME
   */
  className?: string;
};

export enum Tab {
  ALL,
  LOCAL,
  RADIO,
  OOC,
  ADMIN,
  OTHER,
}

export enum Highlight {
  LINE,
  SIMPLE,
  /**
   * Internally used by codewords to change the text color
   */
  CLASSNAME,
}

export enum MessageType {
  TEXT,
  REBOOT,
}

export enum SettingsTab {
  GENERAL,
  HIGHLIGHT,
  THEME,
}

export type SettingsData = {
  font: string;
  fontUrl: string;
  lineHeight: number;
  highlights: Array<HighlightEntry>;
};

export type MessageInfo = {
  id?: number;
  text: string;
  type?: MessageType;
  tab?: Tab;
  params?: object;
  highlight?: object;
  occurences: number;
};

export type ByondCall = (topic: string) => void;

declare global {
  interface Window {
    debugs: Array<string>;

    // BYOND calls
    ehjaxCallback: ByondCall;
    output: ByondCall;
    reboot: ByondCall;
    rebootFinished: ByondCall;
    codewords: (phrases: string, responses: string) => void;
    codewordsClear: ByondCall;
    playAudio: ByondCall;
  }
}

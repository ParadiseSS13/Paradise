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
  theme: 'dark' | 'light';
  font: string;
  fontUrl: string;
  lineHeight: number;
  condenseMessages: boolean;
  highlights: Array<HighlightEntry>;
};

export type MessageInfo = {
  id?: number;
  text: string;
  type?: MessageType;
  tab?: Tab;
  params?: { timeout?: number; completed?: boolean };
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
    playAudio: (
      uid: string,
      sender: string,
      file: string,
      volume: number
    ) => void;
  }
}

import 'styled-components';

declare module 'styled-components' {
  export interface DefaultTheme {
    background: {
      [0]: string;
      [1]: string;
      [2]: string;
      [3]: string;
    };
    error: string;
    errorBg: string;
    textPrimary: string;
    textSecondary: string;
    textDisabled: string;
    cssTheme: string;
    accent?: {
      primary: string;
      [0]: string;
      [1]: string;
      [2]: string;
      [3]: string;
      [4]: string;
      [5]: string;
      [6]: string;
    };
    font?: string;
    lineHeight?: number;
  }
}

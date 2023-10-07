import 'styled-components';

declare module 'styled-components' {
  export interface DefaultTheme {
    isDark: 'dark' | 'default';
    background: {
      [0]: string;
      [1]: string;
      [2]: string;
      [3]: string;
    };
    success: string;
    warning: string;
    warning2: string;
    error: string;
    errorBg: string;
    textPrimary: string;
    textPrimaryLight: string;
    textSecondary: string;
    textDisabled: string;
    cssTheme: string;
    primary?: string;
    accent?: Record<number, string>;
    font?: string;
    fontScale?: number;
    lineHeight?: number;
    animationDurationMs?: number;
  }
}

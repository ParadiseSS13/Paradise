import { css } from 'styled-components';

export const animationDurationMs = 150;

export const fadeIn = {
  initial: css`
    opacity: 0;
  `,
  entering: { opacity: 1 },
  entered: { opacity: 1 },
  exiting: { opacity: 0 },
  exited: { opacity: 0 },
};

export const slideUp = {
  initial: css`
    transform: translateY(10px);
  `,
  entering: { transform: 'translateY(0)' },
  entered: { transform: 'translateY(0)' },
  exiting: { transform: 'translateY(10px)' },
  exited: { transform: 'translateY(10px)' },
};

import styled, { css } from 'styled-components';
import { animationDurationMs } from '~/common/animations';

export const Button = styled.a<{
  disabled?: boolean;
  neutral?: boolean;
  small?: boolean;
}>`
  background-color: ${({ theme }) => theme.accent.primary};
  color: ${({ theme }) => theme.textPrimary};
  display: inline-block;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  user-select: none;
  transition-duration: ${animationDurationMs}ms;
  border: 1px solid transparent;

  &:hover {
    background-color: ${({ theme }) => theme.accent[6]};
  }

  &:active {
    background-color: ${({ theme }) => theme.accent[5]};
  }

  ${props =>
    props.disabled &&
    css`
      cursor: default !important;
      color: ${({ theme }) => theme.textDisabled} !important;
      background-color: ${({ theme }) => theme.background[2]} !important;
      border: 1px solid ${({ theme }) => theme.background[3]} !important;
    `}

  ${props =>
    props.neutral &&
    css`
      background-color: ${({ theme }) => theme.background[1]};

      &:hover {
        background-color: ${({ theme }) => theme.background[3]};
      }

      &:active {
        background-color: ${({ theme }) => theme.background[2]};
      }
    `}

  ${props =>
    props.small &&
    css`
      padding: 4px 8px;
    `}
`;

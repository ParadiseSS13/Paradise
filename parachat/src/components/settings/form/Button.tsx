import styled, { css } from 'styled-components';
import { animationDurationMs } from '~/common/animations';

export const Button = styled.a`
  background-color: ${props => props.theme.accent.primary};
  color: ${props => props.theme.colors.fg[0]};
  display: inline-block;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  user-select: none;
  transition-duration: ${animationDurationMs}ms;
  border: 1px solid transparent;

  &:hover {
    background-color: ${props => props.theme.accent[6]};
  }

  &:active {
    background-color: ${props => props.theme.accent[5]};
  }

  ${props =>
    props.disabled &&
    css`
      cursor: default !important;
      color: ${props => props.theme.colors.fg[2]} !important;
      background-color: ${props => props.theme.colors.bg[2]} !important;
      border: 1px solid ${props => props.theme.colors.bg[3]} !important;
    `}

  ${props =>
    props.neutral &&
    css`
      background-color: ${props => props.theme.colors.bg[1]};

      &:hover {
        background-color: ${props => props.theme.colors.bg[3]};
      }

      &:active {
        background-color: ${props => props.theme.colors.bg[2]};
      }
    `}

  ${props =>
    props.small &&
    css`
      padding: 4px 8px;
    `}
`;

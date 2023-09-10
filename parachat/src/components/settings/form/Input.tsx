import styled, { css } from 'styled-components';

const Input = styled.input<{ stretch?: boolean }>`
  border: 1px solid ${({ theme }) => theme.background[1]};
  padding: 4px 8px;
  background: transparent;
  border-radius: 4px;
  color: ${({ theme }) => theme.textPrimary};
  cursor: text;
  font-family: inherit;
  transition-duration: 0.2s;
  vertical-align: middle;

  &:hover,
  &:focus {
    border-color: ${({ theme }) => theme.accent[4]};
  }

  ${props =>
    props.stretch &&
    css`
      flex: 1;
    `}
`;

export default Input;

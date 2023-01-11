import styled, { css } from 'styled-components';

const Input = styled.input`
  color: ${props => props.theme.colors.fg[0]};
  background: transparent;
  border: 1px solid ${props => props.theme.colors.bg[1]};
  border-radius: 4px;
  padding: 4px 8px;
  transition-duration: 0.2s;
  vertical-align: middle;
  font-family: inherit;
  cursor: text;

  &:hover,
  &:focus {
    border-color: ${props => props.theme.accent.primary};
  }

  ${props =>
    props.stretch &&
    css`
      flex: 1;
    `}
`;

export default Input;

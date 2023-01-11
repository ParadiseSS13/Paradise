import styled from 'styled-components';

const Label = styled.span`
  color: ${props => props.theme.colors.fg[0]};
  min-width: 90px;
  display: inline-block;
  vertical-align: middle;
  margin-right: 8px;
`;

export default Label;

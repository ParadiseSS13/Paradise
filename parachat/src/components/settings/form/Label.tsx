import styled from 'styled-components';

const Label = styled.span`
  color: ${({ theme }) => theme.colors.fg[0]};
  width: 90px;
  display: inline-block;
  vertical-align: middle;
  margin-right: 8px;
`;

export default Label;

import styled from 'styled-components';

export const Separator = styled.div`
  display: block;
  height: 1px;
  margin: 12px 0;
  background-color: ${props => props.theme.colors.bg[1]};
`;

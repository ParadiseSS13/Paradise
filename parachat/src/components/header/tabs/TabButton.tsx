import styled, { css } from 'styled-components';

interface TabButtonProps {
  active?: boolean;
  name: string;
  unread?: number;
  onTabClick?: () => void;
}

const TabWrapper = styled.a<{ active?: boolean }>`
  padding: 0 12px;
  color: ${({ theme }) => theme.textSecondary};
  text-decoration: none;
  transition-duration: ${({ theme }) => theme.animationDurationMs}ms;

  &:hover {
    background-color: ${({ theme }) => theme.background[2]};
  }
  &:active {
    background-color: ${({ theme }) => theme.background[1]};
  }

  ${({ active }) =>
    active &&
    css`
      background-color: ${({ theme }) => theme.background[1]} !important;
      color: ${({ theme }) => theme.accent[5]};
      cursor: default;
    `}
`;

const TabName = styled.span``;

const UnreadCount = styled.span`
  width: 2em;
  height: 2em;
  margin-left: 1em;
  background-color: ${({ theme }) => theme.accent[4]};
  border-radius: 32px;
  color: ${({ theme }) => theme.textPrimary};
  display: inline-block;
  font-weight: bold;
  font-size: 75%;
  line-height: 2em;
  overflow: visible;
  text-align: center;
  vertical-align: middle;
`;

const TabButton = ({ active, name, unread, onTabClick }: TabButtonProps) => {
  return (
    <TabWrapper href="#" active={active} onClick={onTabClick}>
      <TabName>{name}</TabName>
      {unread && <UnreadCount>{Math.min(99, unread)}</UnreadCount>}
    </TabWrapper>
  );
};

export default TabButton;

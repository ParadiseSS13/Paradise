import styled, { css } from 'styled-components';
import { animationDurationMs } from '~/common/animations';

interface TabButtonProps {
  active?: boolean;
  name: string;
  unread?: number;
  onTabClick?: () => void;
}

const TabWrapper = styled.a<{ active?: boolean }>`
  padding: 0 12px;
  color: ${({ theme }) => theme.colors.fg[1]};
  text-decoration: none;
  transition-duration: ${animationDurationMs}ms;

  &:hover {
    background-color: ${({ theme }) => theme.colors.bg[2]};
  }
  &:active {
    background-color: ${({ theme }) => theme.colors.bg[1]};
  }

  ${({ active }) =>
    active &&
    css`
      background-color: ${({ theme }) => theme.colors.bg[1]} !important;
      color: ${({ theme }) => theme.accent.primary};
      cursor: default;
    `}
`;

const TabName = styled.span``;

const UnreadCount = styled.span`
  width: 2em;
  height: 2em;
  margin-left: 1em;
  background-color: ${props => props.theme.accent.primary};
  border-radius: 32px;
  color: ${props => props.theme.colors.fg[0]};
  display: inline-block;
  font-weight: bold;
  font-size: 75%;
  line-height: 2em;
  overflow: visible;
  text-align: center;
  vertical-align: middle;
`;

const TabButton: React.FC<TabButtonProps> = ({
  active,
  name,
  unread,
  onTabClick,
}) => {
  return (
    <TabWrapper href="#" active={active} onClick={onTabClick}>
      <TabName>{name}</TabName>
      {unread && <UnreadCount>{Math.min(99, unread)}</UnreadCount>}
    </TabWrapper>
  );
};

export default TabButton;

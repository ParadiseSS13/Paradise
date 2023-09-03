import PropTypes from 'prop-types';
import styled, { css } from 'styled-components';
import { animationDurationMs } from '~/common/animations';

const TabWrapper = styled.a`
  padding: 0 12px;
  text-decoration: none;
  color: ${props => props.theme.colors.fg[1]};
  transition-duration: ${animationDurationMs}ms;

  &:hover {
    background-color: ${props => props.theme.colors.bg[2]};
  }
  &:active {
    background-color: ${props => props.theme.colors.bg[1]};
  }

  ${props =>
    props.active &&
    css`
      background-color: ${props => props.theme.colors.bg[1]} !important;
      color: ${props => props.theme.accent.primary};
      cursor: default;
    `}
`;

const TabName = styled.span``;

const UnreadCount = styled.span`
  display: inline-block;
  width: 2em;
  height: 2em;
  line-height: 2em;
  font-weight: bold;
  font-size: 75%;
  margin-left: 1em;
  border-radius: 32px;
  text-align: center;
  vertical-align: middle;
  background-color: ${props => props.theme.accent.primary};
  color: ${props => props.theme.colors.fg[0]};
  overflow: visible;
`;

const TabButton = ({ active, name, unread, onTabClick }) => {
  return (
    <TabWrapper
      href="#"
      active={active}
      unread={unread > 0}
      onClick={onTabClick}
    >
      <TabName>{name}</TabName>
      {unread && <UnreadCount>{Math.min(99, unread)}</UnreadCount>}
    </TabWrapper>
  );
};

TabButton.propTypes = {
  active: PropTypes.bool,
  name: PropTypes.string.isRequired,
  unread: PropTypes.number,
  onTabClick: PropTypes.func,
};

export default TabButton;

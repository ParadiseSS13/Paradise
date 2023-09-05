import styled from 'styled-components';
import Ping from './Ping';
import Settings from './Settings';
import Tabs from './tabs/Tabs';

const HeaderWrapper = styled.div`
  display: flex;
  height: 32px;
  line-height: 32px;
  user-select: none;
`;

const Header: React.FC = () => {
  return (
    <HeaderWrapper>
      <Tabs />
      <Ping />
      <Settings />
    </HeaderWrapper>
  );
};

export default Header;

import styled from 'styled-components';
import { useHeaderSlice } from '~/stores/header';

const DebugButtonWrapper = styled.a`
  background-color: rgba(0, 0, 0, 0.5);
  color: white;
  text-decoration: none;
  position: absolute;
  left: 0;
  bottom: 0;
  padding: 4px 8px;
  z-index: 200;
`;

const DebugButton = () => {
  const debugMode = useHeaderSlice(state => state.debugMode);
  const setDebugMode = useHeaderSlice(state => state.setDebugMode);

  return (
    <DebugButtonWrapper href="#" onClick={() => setDebugMode(!debugMode)}>
      Debug
    </DebugButtonWrapper>
  );
};

export default DebugButton;

import styled from 'styled-components';
import { useHeaderSlice } from '~/stores/header';

const DebugConsoleWrapper = styled.div`
  background-color: rgba(0, 0, 0, 0.5);
  color: white;
  text-decoration: none;
  font-family: monospace;
  position: absolute;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  padding: 8px 8px;
  box-sizing: border-box;
  word-wrap: break-word;
  overflow: auto;
  z-index: 200;
`;

const ClearButton = styled.a`
  background-color: rgba(0, 0, 0, 0.5);
  color: white;
  text-decoration: none;
  position: absolute;
  right: 0;
  bottom: 0;
  padding: 4px 8px;
`;

const DebugConsole = () => {
  const debugMode = useHeaderSlice(state => state.debugMode);
  if (!debugMode) {
    return;
  }

  return (
    <DebugConsoleWrapper>
      <ClearButton
        href="#"
        onClick={() => {
          window.debugs = [];
        }}
      >
        Clear
      </ClearButton>
      {window.debugs.map((text, i) => (
        <div key={i}>{text}</div>
      ))}
    </DebugConsoleWrapper>
  );
};

export default DebugConsole;

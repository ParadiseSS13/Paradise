import styled from 'styled-components';
import { useHeaderSlice } from '~/stores/header';

const SettingsWrapper = styled.div`
  padding: 0 12px;
  cursor: pointer;
  background-color: ${({ theme }) => theme.background[1]};
  transition-duration: ${({ theme }) => theme.animationDurationMs}ms;

  &:hover {
    background-color: ${({ theme }) => theme.background[2]};
  }
  &:active {
    background-color: ${({ theme }) => theme.background[0]};
  }
`;

const Settings = () => {
  const setShowSettings = useHeaderSlice(state => state.setShowSettings);

  return (
    <SettingsWrapper onClick={() => setShowSettings(true)}>
      Settings
    </SettingsWrapper>
  );
};

export default Settings;

import styled from 'styled-components';
import { useHeaderSlice } from '~/stores/header';

const SettingsWrapper = styled.a`
  padding: 0 12px;
  color: ${({ theme }) => theme.textPrimary};
  background-color: ${({ theme }) => theme.background[1]};
  transition-duration: ${({ theme }) => theme.animationDurationMs}ms;
  text-decoration: none;

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
    <SettingsWrapper href="#" onClick={() => setShowSettings(true)}>
      Settings
    </SettingsWrapper>
  );
};

export default Settings;

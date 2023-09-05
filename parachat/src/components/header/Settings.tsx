import styled from 'styled-components';
import { animationDurationMs } from '~/common/animations';
import { useHeaderSlice } from '~/stores/header';

const SettingsWrapper = styled.div`
  padding: 0 12px;
  cursor: pointer;
  background-color: ${props => props.theme.colors.bg[1]};
  transition-duration: ${animationDurationMs}ms;

  &:hover {
    background-color: ${props => props.theme.colors.bg[2]};
  }
  &:active {
    background-color: ${props => props.theme.colors.bg[0]};
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

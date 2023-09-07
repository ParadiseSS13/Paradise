import styled from 'styled-components';
import { useEditSettings } from '~/hooks/useEditSettings';

const ThemeSettingsWrapper = styled.div``;

const Hint = styled.span`
  display: inline-block;
  margin-left: 98px;
  margin-bottom: 8px;
  color: ${({ theme }) => theme.textDisabled};
`;

const ThemeSettings = () => {
  const { currentSettings, unsavedSettings, write, save } = useEditSettings();

  return <ThemeSettingsWrapper>TODO</ThemeSettingsWrapper>;
};

export default ThemeSettings;

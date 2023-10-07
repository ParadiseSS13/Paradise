import { generate } from '@ant-design/colors';
import styled, { ThemeProvider } from 'styled-components';
import { animationDurationMs } from '~/common/animations';
import GlobalStyle from '~/components/GlobalStyle';
import MessageList from '~/components/MessageList';
import DebugButton from '~/components/debug/DebugButton';
import DebugConsole from '~/components/debug/DebugConsole';
import Audio from '~/components/footer/Audio';
import Header from '~/components/header/Header';
import SettingsMenu from '~/components/settings/SettingsMenu';
import { useSettingsSlice } from '~/stores/settings';
import dark from '~/themes/dark';
import light from '~/themes/light';

const AppWrapper = styled.div`
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  height: 100vh;
`;

const App = () => {
  const theme = useSettingsSlice(state => state.theme);
  const font = useSettingsSlice(state => state.font);
  const fontUrl = useSettingsSlice(state => state.fontUrl);
  const fontScale = useSettingsSlice(state => state.fontScale);
  const lineHeight = useSettingsSlice(state => state.lineHeight);
  const enableAnimations = useSettingsSlice(state => state.enableAnimations);
  const primary = '#1668dc';
  const curTheme = theme === 'light' ? light : dark;

  return (
    <ThemeProvider
      theme={{
        ...curTheme,
        font,
        fontScale,
        lineHeight,
        primary: primary,
        accent: generate(primary, { theme: curTheme.isDark }),
        animationDurationMs: enableAnimations ? animationDurationMs : 0,
      }}
    >
      {fontUrl && <style>@import url({fontUrl});</style>}
      <GlobalStyle />
      <AppWrapper>
        <SettingsMenu />
        <Header />
        <MessageList />
        <Audio />
        <DebugConsole />
        <DebugButton />
      </AppWrapper>
    </ThemeProvider>
  );
};

export default App;

import styled, { ThemeProvider } from 'styled-components';
import { useSettingsSlice } from '~/common/store';
import { generateAccent } from '~/common/util';
import Audio from '~/components/footer/Audio';
import GlobalStyle from '~/components/GlobalStyle';
import Header from '~/components/header/Header';
import MessageList from '~/components/MessageList';
import SettingsMenu from '~/components/settings/SettingsMenu';
import dark from '~/themes/dark';

const AppWrapper = styled.div`
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  height: 100vh;
`;

const App = () => {
  const font = useSettingsSlice(state => state.font);
  const fontUrl = useSettingsSlice(state => state.fontUrl);
  const lineHeight = useSettingsSlice(state => state.lineHeight);

  return (
    <ThemeProvider
      theme={{
        ...dark,
        font,
        lineHeight,
        accent: generateAccent('#1668dc'),
      }}
    >
      {fontUrl && <style>@import url({fontUrl});</style>}
      <GlobalStyle />
      <AppWrapper>
        <SettingsMenu />
        <Header />
        <MessageList />
        <Audio />
        {/* <DebugConsole /> */}
        {/* <DebugButton /> */}
      </AppWrapper>
    </ThemeProvider>
  );
};

export default App;

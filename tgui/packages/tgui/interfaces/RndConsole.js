import { useBackend } from "../backend";
import { Window } from "../layouts";
import { Box, NoticeBox } from "../components";
import {
  SettingsMenu,
  RndRoute,
  DeconstructionMenu,
  MainMenu,
  RndNavbar,
  CurrentLevels,
  DataDiskMenu,
  LatheMenu,
} from './RndConsoleComponents';


export const RndConsole = (properties, context) => {
  const { data } = useBackend(context);
  const { wait_message } = data;

  return (
    <Window>
      <Window.Content>
        <Box className="RndConsole">
          <RndNavbar />
          <RndRoute menu={0} render={() => <MainMenu />} />
          <RndRoute menu={1} render={() => <CurrentLevels />} />
          <RndRoute menu={2} render={() => <DataDiskMenu />} />
          <RndRoute menu={3} render={() => <DeconstructionMenu />} />
          <RndRoute menu={n => n === 4 || n === 5} render={() => <LatheMenu />} />
          <RndRoute menu={6} render={() => <SettingsMenu />} />
          {wait_message ? (
            <Box className="RndConsole__Overlay">
              <Box className="RndConsole__Overlay__Wrapper">
                <NoticeBox info>
                  {wait_message}
                </NoticeBox>
              </Box>
            </Box>
          ) : null}
        </Box>
      </Window.Content>
    </Window>
  );
};

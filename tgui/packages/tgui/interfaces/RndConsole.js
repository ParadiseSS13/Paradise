import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, NoticeBox } from '../components';
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

export const MENU = {
  MAIN: 0,
  LEVELS: 1,
  DISK: 2,
  DESTROY: 3,
  LATHE: 4,
  IMPRINTER: 5,
  SETTINGS: 6,
};

export const SUBMENU = {
  MAIN: 0,
  DISK_COPY: 1,
  LATHE_CATEGORY: 1,
  LATHE_MAT_STORAGE: 2,
  LATHE_CHEM_STORAGE: 3,
  SETTINGS_DEVICES: 1,
};

export const RndConsole = (properties, context) => {
  const { data } = useBackend(context);
  const { wait_message } = data;

  return (
    <Window width={800} height={550}>
      <Window.Content>
        <Box className="RndConsole">
          <RndNavbar />
          <RndRoute menu={MENU.MAIN} render={() => <MainMenu />} />
          <RndRoute menu={MENU.LEVELS} render={() => <CurrentLevels />} />
          <RndRoute menu={MENU.DISK} render={() => <DataDiskMenu />} />
          <RndRoute menu={MENU.DESTROY} render={() => <DeconstructionMenu />} />
          <RndRoute menu={(n) => n === MENU.LATHE || n === MENU.IMPRINTER} render={() => <LatheMenu />} />
          <RndRoute menu={MENU.SETTINGS} render={() => <SettingsMenu />} />
          {wait_message ? (
            <Box className="RndConsole__Overlay">
              <Box className="RndConsole__Overlay__Wrapper">
                <NoticeBox color="black">{wait_message}</NoticeBox>
              </Box>
            </Box>
          ) : null}
        </Box>
      </Window.Content>
    </Window>
  );
};

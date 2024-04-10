import { RndRoute, RndNavButton } from './index';
import { Box } from '../../components';
import { MENU, SUBMENU } from '../RndConsole';

export const RndNavbar = () => (
  <Box className="RndConsole__RndNavbar">
    <RndRoute
      menu={(n) => n !== MENU.MAIN}
      render={() => <RndNavButton menu={MENU.MAIN} submenu={SUBMENU.MAIN} icon="reply" content="Main Menu" />}
    />

    {/* Links to return to submenu 0 for each menu other than main menu */}
    <RndRoute
      submenu={(n) => n !== SUBMENU.MAIN}
      render={() => (
        <Box>
          <RndRoute
            menu={MENU.DISK}
            render={() => <RndNavButton submenu={SUBMENU.MAIN} icon="reply" content="Disk Operations Menu" />}
          />

          <RndRoute
            menu={MENU.LATHE}
            render={() => <RndNavButton submenu={SUBMENU.MAIN} icon="reply" content="Protolathe Menu" />}
          />

          <RndRoute
            menu={MENU.IMPRINTER}
            render={() => <RndNavButton submenu={SUBMENU.MAIN} icon="reply" content="Circuit Imprinter Menu" />}
          />

          <RndRoute
            menu={MENU.SETTINGS}
            render={() => <RndNavButton submenu={SUBMENU.MAIN} icon="reply" content="Settings Menu" />}
          />
        </Box>
      )}
    />

    <RndRoute
      menu={(n) => n === MENU.LATHE || n === MENU.IMPRINTER}
      submenu={SUBMENU.MAIN}
      render={() => (
        <Box>
          <RndNavButton submenu={SUBMENU.LATHE_MAT_STORAGE} icon="arrow-up" content="Material Storage" />
          <RndNavButton submenu={SUBMENU.LATHE_CHEM_STORAGE} icon="arrow-up" content="Chemical Storage" />
        </Box>
      )}
    />
  </Box>
);

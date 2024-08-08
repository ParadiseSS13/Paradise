import { useBackend } from '../../backend';
import { Box, Tabs } from '../../components';
import { MENU, PRINTER_MENU } from '.';
import { LatheMainMenu } from './LatheMainMenu';
import { LatheCategory } from './LatheCategory';
import { LatheMaterialStorage } from './LatheMaterialStorage';
import { LatheChemicalStorage } from './LatheChemicalStorage';

const Tab = Tabs.Tab;

const PrinterTab = (props, context) => {
  const { act, data } = useBackend(context);
  const [act_id, currentMenu] =
    data.menu === MENU.LATHE ? ['nav_protolathe', data.submenu_protolathe] : ['nav_imprinter', data.submenu_imprinter];
  const { menu, ...rest } = props;
  return <Tab selected={currentMenu === menu} onClick={() => act(act_id, { menu })} {...rest} />;
};

const decideTab = (tab) => {
  switch (tab) {
    case PRINTER_MENU.MAIN:
      return <LatheMainMenu />;
    case PRINTER_MENU.SEARCH:
      return <LatheCategory />;
    case PRINTER_MENU.MATERIALS:
      return <LatheMaterialStorage />;
    case PRINTER_MENU.CHEMICALS:
      return <LatheChemicalStorage />;
  }
};

export const LatheMenu = (properties, context) => {
  const { data } = useBackend(context);

  const { menu, linked_lathe, linked_imprinter } = data;

  if (menu === MENU.LATHE && !linked_lathe) {
    return <Box>NO PROTOLATHE LINKED TO CONSOLE</Box>;
  }

  if (menu === MENU.IMPRINTER && !linked_imprinter) {
    return <Box>NO CIRCUIT IMPRITER LINKED TO CONSOLE</Box>;
  }

  return (
    <Box>
      <Tabs>
        <PrinterTab menu={PRINTER_MENU.MAIN} icon="bars">
          Main Menu
        </PrinterTab>
        <PrinterTab menu={PRINTER_MENU.MATERIALS} icon="layer-group">
          Materials
        </PrinterTab>
        <PrinterTab menu={PRINTER_MENU.CHEMICALS} icon="flask-vial">
          Chemicals
        </PrinterTab>
      </Tabs>
      {decideTab(data.menu === MENU.LATHE ? data.submenu_protolathe : data.submenu_imprinter)}
    </Box>
  );
};

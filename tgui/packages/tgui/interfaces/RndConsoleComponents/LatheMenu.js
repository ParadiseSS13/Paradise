import { useBackend } from '../../backend';
import { RndRoute } from './RndRoute';
import { LatheMainMenu, LatheCategory, LatheMaterialStorage, LatheChemicalStorage } from './index';
import { Box } from '../../components';
import { SUBMENU } from '../RndConsole';

export const LatheMenu = (properties, context) => {
  const { data } = useBackend(context);

  const { menu, linked_lathe, linked_imprinter } = data;

  if (menu === 4 && !linked_lathe) {
    return <Box>NO PROTOLATHE LINKED TO CONSOLE</Box>;
  }

  if (menu === 5 && !linked_imprinter) {
    return <Box>NO CIRCUIT IMPRITER LINKED TO CONSOLE</Box>;
  }

  return (
    <Box>
      <RndRoute submenu={SUBMENU.MAIN} render={() => <LatheMainMenu />} />
      <RndRoute submenu={SUBMENU.LATHE_CATEGORY} render={() => <LatheCategory />} />
      <RndRoute submenu={SUBMENU.LATHE_MAT_STORAGE} render={() => <LatheMaterialStorage />} />
      <RndRoute submenu={SUBMENU.LATHE_CHEM_STORAGE} render={() => <LatheChemicalStorage />} />
    </Box>
  );
};

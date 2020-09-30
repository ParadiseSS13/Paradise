import { useBackend } from "../../backend";
import { RndRoute } from "./RndRoute";
import { LatheMainMenu, LatheCategory, LatheMaterialStorage, LatheChemicalStorage } from "./index";
import { Box } from "../../components";

export const LatheMenu = (properties, context) => {
  const { data } = useBackend(context);

  const {
    menu,
    linked_lathe,
    linked_imprinter,
  } = data;

  if (menu === 4 && !linked_lathe) {
    return (
      <Box>
        NO PROTOLATHE LINKED TO CONSOLE
      </Box>
    );
  }

  if (menu === 5 && !linked_imprinter) {
    return (
      <Box>
        NO CIRCUIT IMPRITER LINKED TO CONSOLE
      </Box>
    );
  }

  return (
    <Box>
      <RndRoute submenu={0} render={() => <LatheMainMenu />} />
      <RndRoute submenu={1} render={() => <LatheCategory />} />
      <RndRoute submenu={2} render={() => <LatheMaterialStorage />} />
      <RndRoute submenu={3} render={() => <LatheChemicalStorage />} />
    </Box>
  );
};

import { useBackend } from "../../backend";
import { RndRoute } from "./RndRoute";
import { LatheMainMenu, LatheCategory, LatheMaterialStorage, LatheChemicalStorage } from "./index";

export const LatheMenu = (properties, context) => {
  const { data } = useBackend(context);

  const {
    menu,
    linked_lathe,
    linked_imprinter,
  } = data;

  if (menu === 4 && !linked_lathe) {
    return (
      <div>
        NO PROTOLATHE LINKED TO CONSOLE
      </div>
    );
  }

  if (menu === 5 && !linked_imprinter) {
    return (
      <div>
        NO CIRCUIT IMPRITER LINKED TO CONSOLE
      </div>
    );
  }

  return (
    <div>
      <RndRoute submenu={0} render={() => <LatheMainMenu />} />
      <RndRoute submenu={1} render={() => <LatheCategory />} />
      <RndRoute submenu={2} render={() => <LatheMaterialStorage />} />
      <RndRoute submenu={3} render={() => <LatheChemicalStorage />} />
    </div>
  );
};

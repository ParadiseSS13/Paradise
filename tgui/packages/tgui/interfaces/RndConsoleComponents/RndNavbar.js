import { RndRoute, RndNavButton } from "./index";
import { Box } from "../../components";

export const RndNavbar = () => (
  <Box className="RndConsole__RndNavbar">
    <RndRoute menu={n => n !== 0} render={() => (
      <RndNavButton menu={0} submenu={0} icon="reply" content="Main Menu" />
    )} />

    {/* Links to return to submenu 0 for each menu other than main menu */}
    <RndRoute submenu={n => n > 0} render={() => (
      <>
        <RndRoute menu={2} render={() => (
          <RndNavButton submenu={0} icon="reply" content="Disk Operations Menu" />
        )} />

        <RndRoute menu={4} render={() => (
          <RndNavButton submenu={0} icon="reply" content="Protolathe Menu" />
        )} />

        <RndRoute menu={5} render={() => (
          <RndNavButton submenu={0} icon="reply" content="Circuit Imprinter Menu" />
        )} />

        <RndRoute menu={6} render={() => (
          <RndNavButton submenu={0} icon="reply" content="Settings Menu" />
        )} />
      </>
    )} />

    <RndRoute menu={n => n === 4 || n === 5} submenu={0} render={() => (
      <>
        <RndNavButton submenu={2} icon="arrow-up" content="Material Storage" />
        <RndNavButton submenu={3} icon="arrow-up" content="Chemical Storage" />
      </>
    )} />

  </Box>
);

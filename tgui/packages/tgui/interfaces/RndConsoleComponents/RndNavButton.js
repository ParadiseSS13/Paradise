import { useBackend } from "../../backend";
import { Button } from "../../components";

export const RndNavButton = (properties, context) => {
  const { icon, children, disabled, content } = properties;
  const { data, act } = useBackend(context);
  const { menu, submenu } = data;

  let nextMenu = menu;
  let nextSubmenu = submenu;

  if (properties.menu !== null && properties.menu !== undefined) {
    nextMenu = properties.menu;
  }
  if (properties.submenu !== null && properties.submenu !== undefined) {
    nextSubmenu = properties.submenu;
  }

  // const active = data.menu === menu && data.submenu === submenu;

  return (
    <Button
      content={content}
      icon={icon}
      disabled={disabled} onClick={() => {
        act('nav', { menu: nextMenu, submenu: nextSubmenu });
      }}>
      {children}
    </Button>
  );
};

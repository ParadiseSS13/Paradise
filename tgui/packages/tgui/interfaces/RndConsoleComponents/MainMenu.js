import { useBackend } from "../../backend";
import { Box, Flex, LabeledList, Section } from "../../components";
import { RndNavButton } from "./index";
import { MENU, SUBMENU } from "../RndConsole";

export const MainMenu = (properties, context) => {
  const { data } = useBackend(context);

  const {
    disk_type,
    linked_destroy,
    linked_lathe,
    linked_imprinter,
    tech_levels,
  } = data;

  return (
    <Section title="Main Menu">
      <Flex className="RndConsole__MainMenu__Buttons" direction="column" align="flex-start">
        <RndNavButton disabled={!disk_type} menu={MENU.DISK} submenu={SUBMENU.MAIN} icon="save" content="Disk Operations" />
        <RndNavButton disabled={!linked_destroy} menu={MENU.DESTROY} submenu={SUBMENU.MAIN} icon="unlink"
          content="Destructive Analyzer Menu" />
        <RndNavButton disabled={!linked_lathe} menu={MENU.LATHE} submenu={SUBMENU.MAIN} icon="print" content="Protolathe Menu" />
        <RndNavButton disabled={!linked_imprinter} menu={MENU.IMPRINTER} submenu={SUBMENU.MAIN} icon="print"
          content="Circuit Imprinter Menu" />
        <RndNavButton menu={MENU.SETTINGS} submenu={SUBMENU.MAIN} icon="cog" content="Settings" />
      </Flex>

      <Box mt="12px" />
      <h3>Current Research Levels:</h3>
      <LabeledList>
        {tech_levels.map(({ name, level }) => (
          <LabeledList.Item label={name} key={name}>
            {level}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

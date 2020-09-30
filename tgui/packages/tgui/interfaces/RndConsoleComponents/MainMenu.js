import { useBackend } from "../../backend";
import { Box, Flex, LabeledList, Section } from "../../components";
import { RndNavButton } from "./index";

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
      <Flex direction="column" align="flex-start">
        <RndNavButton disabled={!disk_type} menu={2} submenu={0} icon="save" content="Disk Operations" />
        <RndNavButton disabled={!linked_destroy} menu={3} submenu={0} icon="unlink"
          content="Destructive Analyzer Menu" />
        <RndNavButton disabled={!linked_lathe} menu={4} submenu={0} icon="print" content="Protolathe Menu" />
        <RndNavButton disabled={!linked_imprinter} menu={5} submenu={0} icon="print"
          content="Circuit Imprinter Menu" />
        <RndNavButton menu={6} submenu={0} icon="cog" content="Settings" />
      </Flex>

      <Box mt="12px" />
      <h3>Current Research Levels:</h3>
      <LabeledList>
        {tech_levels.map(({ name, level }) => (
          <LabeledList.Item labelColor="yellow" label={name} key={name}>
            {level}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

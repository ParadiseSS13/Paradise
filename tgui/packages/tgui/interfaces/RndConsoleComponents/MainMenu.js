import { useBackend } from '../../backend';
import { AnimatedNumber, Box, Button, Flex, LabeledList, Section } from '../../components';
import { RndNavButton } from './index';
import { MENU, SUBMENU } from '../RndConsole';
import { Fragment } from 'inferno';

export const MainMenu = (properties, context) => {
  const { data, act } = useBackend(context);

  const {
    disk_type,
    linked_analyzer,
    linked_lathe,
    linked_imprinter,
    tech_levels,
    research_points,
  } = data;

  return (
    <Section title="Main Menu">
      <Flex
        className="RndConsole__MainMenu__Buttons"
        direction="column"
        align="flex-start"
      >
        <RndNavButton
          disabled={!disk_type}
          menu={MENU.DISK}
          submenu={SUBMENU.MAIN}
          icon="save"
          content="Disk Operations"
        />
        <RndNavButton
          disabled={!linked_analyzer}
          menu={MENU.ANALYZER}
          submenu={SUBMENU.MAIN}
          icon="microscope"
          content="Science Analyzer Menu"
        />
        <RndNavButton
          disabled={!linked_lathe}
          menu={MENU.LATHE}
          submenu={SUBMENU.MAIN}
          icon="print"
          content="Protolathe Menu"
        />
        <RndNavButton
          disabled={!linked_imprinter}
          menu={MENU.IMPRINTER}
          submenu={SUBMENU.MAIN}
          icon="print"
          content="Circuit Imprinter Menu"
        />
        <RndNavButton
          menu={MENU.SETTINGS}
          submenu={SUBMENU.MAIN}
          icon="cog"
          content="Settings"
        />
      </Flex>

      <Box mt="12px" />
      <h3>Current Research Levels:</h3>
      <LabeledList>
        <LabeledList.Item label="Current research points"><AnimatedNumber value={research_points} /></LabeledList.Item>
        {tech_levels.map((t) => (
          <LabeledList.Item label={t.name} key={t.name}>
            <Fragment>
              {t.level}
              <Button
                ml={2}
                mt={0}
                mb={0}
                content={"Upgrade (" + t.nextpoints + " points)"}
                disabled={t.nextpoints > research_points}
                onClick={() => act('levelup', { tech: t.id })}
                icon="arrow-circle-up" />
            </Fragment>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

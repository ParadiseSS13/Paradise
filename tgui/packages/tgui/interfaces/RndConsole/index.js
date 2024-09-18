import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Box, Button, Icon, LabeledList, NoticeBox, Section, Table, Tabs } from '../../components';
import { classes } from 'common/react';
import { DataDiskMenu } from './DataDiskMenu';
import { LatheMenu } from './LatheMenu';
import { LinkMenu } from './LinkMenu';
import { SettingsMenu } from './SettingsMenu';
import { DeconstructionMenu } from './DeconstructionMenu';

const Tab = Tabs.Tab;

export const MENU = {
  MAIN: 0,
  DISK: 2,
  DESTROY: 3,
  LATHE: 4,
  IMPRINTER: 5,
  SETTINGS: 6,
};

export const PRINTER_MENU = {
  MAIN: 0,
  SEARCH: 1,
  MATERIALS: 2,
  CHEMICALS: 3,
};

const decideTab = (tab) => {
  switch (tab) {
    case MENU.MAIN:
      return <MainMenu />;
    case MENU.DISK:
      return <DataDiskMenu />;
    case MENU.DESTROY:
      return <DeconstructionMenu />;
    case MENU.LATHE:
    case MENU.IMPRINTER:
      return <LatheMenu />;
    case MENU.SETTINGS:
      return <SettingsMenu />;
    default:
      return 'UNKNOWN MENU';
  }
};

const ConsoleTab = (props, context) => {
  const { act, data } = useBackend(context);
  const { menu: currentMenu } = data;
  const { menu, ...rest } = props;
  return <Tab selected={currentMenu === menu} onClick={() => act('nav', { menu })} {...rest} />;
};

export const RndConsole = (properties, context) => {
  const { act, data } = useBackend(context);

  if (!data.linked) {
    return <LinkMenu />;
  }

  const { menu, linked_destroy, linked_lathe, linked_imprinter, wait_message } = data;

  return (
    <Window width={800} height={550}>
      <Window.Content>
        <Box className="RndConsole">
          <Tabs>
            <ConsoleTab icon="flask" menu={MENU.MAIN}>
              Research
            </ConsoleTab>
            {!!linked_destroy && (
              <ConsoleTab icon="microscope" menu={MENU.DESTROY}>
                Analyze
              </ConsoleTab>
            )}
            {!!linked_lathe && (
              <ConsoleTab icon="print" menu={MENU.LATHE}>
                Protolathe
              </ConsoleTab>
            )}
            {!!linked_imprinter && (
              <ConsoleTab icon="memory" menu={MENU.IMPRINTER}>
                Imprinter
              </ConsoleTab>
            )}
            <ConsoleTab icon="floppy-disk" menu={MENU.DISK}>
              Disk
            </ConsoleTab>
            <ConsoleTab icon="cog" menu={MENU.SETTINGS}>
              Settings
            </ConsoleTab>
          </Tabs>
          {decideTab(menu)}
          <WaitNotice />
        </Box>
      </Window.Content>
    </Window>
  );
};

const WaitNotice = (props, context) => {
  const { data } = useBackend(context);
  const { wait_message } = data;
  if (!wait_message) {
    return null;
  }

  return (
    <Box className="RndConsole__Overlay">
      <Box className="RndConsole__Overlay__Wrapper">
        <NoticeBox color="black">{wait_message}</NoticeBox>
      </Box>
    </Box>
  );
};

const MainMenu = (props, context) => {
  const { data } = useBackend(context);

  const { tech_levels } = data;

  return (
    <Section>
      <Table id="research-levels">
        <Table.Row>
          <Table.Cell />
          <Table.Cell header>Research Field</Table.Cell>
          <Table.Cell header>Level</Table.Cell>
        </Table.Row>
        {tech_levels.map(({ id, name, desc, level, ui_icon }) => (
          <Table.Row key={id}>
            <Table.Cell>
              <Button icon="circle-info" tooltip={desc} />
            </Table.Cell>
            <Table.Cell>
              <Icon name={ui_icon} /> {name}
            </Table.Cell>
            <Table.Cell>{level}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

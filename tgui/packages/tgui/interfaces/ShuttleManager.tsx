import { useContext, useState } from 'react';
import { Box, Button, LabeledList, Section, Stack, Table, Tabs } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import TabsContext from './common/TabsContext';

type JumpToCoordsProps = {
  coords: Coord3;
};

const JumpToCoords = (props: JumpToCoordsProps) => {
  const { act } = useBackend();
  const { coords } = props;
  const { x, y, z } = coords;
  return <Button onClick={() => act('jump_to_coords', { x: x, y: y, z: z })}>JMP</Button>;
};

type Coord3 = {
  x: number;
  y: number;
  z: number;
};

const Coords = (props: { coords: Coord3 }) => {
  let { coords } = props;
  return (
    <Box>
      ({coords.x}, {coords.y}, {coords.z})
    </Box>
  );
};

type SecLevel = {
  number: number;
  name: string;
  color: string;
};

type DockingPort = {
  name: string;
  id: string;
  uid: string;
  loc: Coord3;
  width: number;
  height: number;
};

enum ShuttleMode {
  Igniting = 0,
  Idle = 1,
  Recall = 2,
  Call = 3,
  Docked = 4,
  Stranded = 5,
  Escape = 6,
  Endgame = 7,
}

const ShuttleModeLabels: Record<ShuttleMode, string> = {
  [ShuttleMode.Igniting]: 'LAUNCH',
  [ShuttleMode.Idle]: 'IDLE',
  [ShuttleMode.Recall]: 'RCL',
  [ShuttleMode.Call]: 'ETA',
  [ShuttleMode.Docked]: 'ETD',
  [ShuttleMode.Stranded]: 'ERR',
  [ShuttleMode.Escape]: 'ESC',
  [ShuttleMode.Endgame]: 'END',
};

type MobileDockingPort = DockingPort & {
  mode: ShuttleMode;
  call_time: number;
  ignition_time: number;
  timer_str: string;
  can_fast_travel: BooleanLike;
};

type StationaryDockingPort = DockingPort & {
  has_docked: BooleanLike;
};

enum HijackStatus {
  NotBegun = 0,
  Stage1 = 1,
  Stage2 = 2,
  Stage3 = 3,
  Stage4 = 4,
  Hijacked = 5,
}

const HijackStatusLabels: Record<HijackStatus, string> = {
  [HijackStatus.NotBegun]: 'Not Begun',
  [HijackStatus.Stage1]: 'Stage 1',
  [HijackStatus.Stage2]: 'Stage 2',
  [HijackStatus.Stage3]: 'Stage 3',
  [HijackStatus.Stage4]: 'Stage 4',
  [HijackStatus.Hijacked]: 'Hijack Complete',
};

type EmergencyDockingPort = MobileDockingPort & {
  hijack_status: HijackStatus;
  ai_hacked: BooleanLike;
};

type Hostile = {
  name: string;
  type: string;
  uid: string;
  loc?: Coord3;
};

type EmergencyShuttleData = {
  port: EmergencyDockingPort;
  status_text: string;
  call_time: number;
  dock_time: number;
  escape_time: number;
  hostiles: Hostile[];
  home_port?: StationaryDockingPort;
  away_port?: StationaryDockingPort;
};

type ManagerData = {
  sec_level: SecLevel;
  mobile_docking_ports: MobileDockingPort[];
  stationary_docking_ports: StationaryDockingPort[];
  emergency: EmergencyShuttleData;
};

const Navigation = () => {
  const { tabIndex, setTabIndex } = useContext(TabsContext);

  return (
    <Tabs>
      <Tabs.Tab
        icon="rocket"
        selected={tabIndex === 0}
        onClick={() => {
          setTabIndex(0);
        }}
      >
        Emergency Shuttle
      </Tabs.Tab>
      <Tabs.Tab
        icon="table-list"
        selected={tabIndex === 1}
        onClick={() => {
          setTabIndex(1);
        }}
      >
        Shuttles
      </Tabs.Tab>
      <Tabs.Tab
        icon="anchor"
        selected={tabIndex === 2}
        onClick={() => {
          setTabIndex(2);
        }}
      >
        Docks
      </Tabs.Tab>
    </Tabs>
  );
};

const Vv = (props: { uid: string }) => {
  const { act } = useBackend();
  const { uid } = props;

  return (
    <Button
      onClick={() => {
        act('vv', { uid: uid });
      }}
    >
      VV
    </Button>
  );
};

const EmergencyShuttle = (props: { data: EmergencyShuttleData; sec_level: SecLevel }) => {
  const { act } = useBackend();
  const { data, sec_level } = props;
  const { port, home_port, away_port } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title="Emergency Shuttle"
          buttons={
            <>
              <Box inline mx={1}>
                <Coords coords={port.loc} />
              </Box>
              <JumpToCoords coords={port.loc} />
              <Vv uid={port.uid} />
            </>
          }
        >
          <Stack fill vertical>
            <Stack>
              <Stack.Item grow>
                <Stack vertical>
                  <Stack.Item>
                    <Button onClick={() => act('call_shuttle')}>Call Shuttle</Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button onClick={() => act('cancel_shuttle')}>Cancel Shuttle</Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button onClick={() => act('deny_shuttle')}>Toggle Deny</Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button onClick={() => act('fast_travel', { uid: port.uid })} disabled={!port.can_fast_travel}>
                      Fast Forward
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item textAlign="center">
                <Box>
                  Alert Level:{' '}
                  <span style={{ color: sec_level.color, fontWeight: 'bold' }}>
                    {sec_level.name.charAt(0).toUpperCase() + sec_level.name.slice(1)}
                  </span>
                  <br />
                  Hijack Status: {HijackStatusLabels[port.hijack_status]} <br />
                </Box>
                <Box className="ShuttleManager__StatusDisplay">
                  {ShuttleModeLabels[port.mode]}
                  <br />
                  {port.mode === ShuttleMode.Idle ? `--:--` : port.timer_str}
                </Box>
                <Box>
                  <Button.Checkbox disabled checked={port.ai_hacked}>
                    AI Hacked
                  </Button.Checkbox>
                </Box>
              </Stack.Item>
            </Stack>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Hostile Environments">
          <Table>
            <Table.Row>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Inspect</Table.Cell>
              <Table.Cell>Actions</Table.Cell>
            </Table.Row>
            {data.hostiles.map((hostile) => {
              return (
                <Table.Row key={hostile.uid}>
                  <Table.Cell>
                    {hostile.name} (<code>{hostile.type}</code>)
                  </Table.Cell>
                  <Table.Cell>
                    <Vv uid={hostile.uid} />
                  </Table.Cell>
                  <Table.Cell>
                    <Button onClick={() => act('remove_hostile', { uid: hostile.uid })}>Remove</Button>
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
        <Section title="Troubleshooting">
          <Section title="Status">
            <LabeledList>
              <LabeledList.Item label="Emergency Shuttle Ports">
                <StatusCheckbox checked={!!home_port}>Station</StatusCheckbox>
                <StatusCheckbox checked={!!away_port}>Central</StatusCheckbox>
              </LabeledList.Item>
              <LabeledList.Item label="Force Send">
                <Button.Confirm
                  confirmContent="Are you absolutely fucking sure?"
                  onClick={() => act('force_send_eshuttle')}
                  tooltip="Only use at round-end if SSshuttle is otherwise completely broken!"
                >
                  Force Send
                </Button.Confirm>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

type StatusCheckboxProps = Partial<{
  checked: BooleanLike;
  children: React.ReactNode;
}>;

/* A checkbox that's only red when its unchecked, not when it's disabled */
const StatusCheckbox = (props: StatusCheckboxProps) => {
  const { checked } = props;
  const good = {
    'color': 'var(--color-good) !important',
    '--button-background': 'hsl(from var(--color-good) h s l / 0.2)',
  } as React.CSSProperties;

  return (
    <Button.Checkbox disabled checked={checked} style={checked ? good : {}}>
      {props.children}
    </Button.Checkbox>
  );
};

const Shuttles = (props: { ports: MobileDockingPort[] }) => {
  const { act } = useBackend<ManagerData>();
  const [showShuttleIds, setShowShuttleIds] = useState(false);

  const { ports } = props;
  return (
    <Section
      title="Shuttles"
      buttons={
        <Button.Checkbox checked={showShuttleIds} onClick={() => setShowShuttleIds(!showShuttleIds)}>
          Show IDs
        </Button.Checkbox>
      }
    >
      <Table>
        {ports
          .toSorted((a, b) => sortSlug(a).localeCompare(sortSlug(b)))
          .map((port) => (
            <Table.Row key={port.uid} className="candystripe ShuttleManager__PortRow">
              <Table.Cell>
                {port.name}
                {showShuttleIds && (
                  <>
                    {' '}
                    (<code>{port.id}</code>)
                  </>
                )}
              </Table.Cell>
              <Table.Cell>
                {ShuttleMode[port.mode]} {port.mode !== ShuttleMode.Idle && <code>{port.timer_str}</code>}
              </Table.Cell>
              <Table.Cell>
                <Coords coords={port.loc} />
              </Table.Cell>
              <Table.Cell>
                <Vv uid={port.uid} />
                <JumpToCoords coords={port.loc} />
                <Button
                  disabled={port.mode !== ShuttleMode.Idle}
                  onClick={() => act('send_shuttle', { name: port.name, uid: port.uid })}
                >
                  Send
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};

const sortSlug = (port: DockingPort) => {
  return `${port.loc.z}-${port.name}`;
};

const StationaryPorts = (props: { ports: StationaryDockingPort[] }) => {
  const { act } = useBackend();
  const { ports } = props;
  const [showPortIds, setShowPortIds] = useState(false);
  return (
    <Section
      title="Docks"
      buttons={
        <Button.Checkbox checked={showPortIds} onClick={() => setShowPortIds(!showPortIds)}>
          Show IDs
        </Button.Checkbox>
      }
    >
      <Table>
        {ports
          .filter((port) => port.width && port.height)
          .toSorted((a, b) => sortSlug(a).localeCompare(sortSlug(b)))
          .map((port) => (
            <Table.Row key={port.uid} className="candystripe ShuttleManager__PortRow">
              <Table.Cell>
                {port.name}
                {showPortIds && (
                  <>
                    {' '}
                    (<code>{port.id}</code>)
                  </>
                )}
              </Table.Cell>
              <Table.Cell>
                <Coords coords={port.loc} />
              </Table.Cell>
              <Table.Cell>
                <Vv uid={port.uid} />
                <JumpToCoords coords={port.loc} />
                <Button
                  disabled={!!port.has_docked}
                  onClick={() => act('send_to_port', { name: port.name, uid: port.uid })}
                >
                  Send Shuttle
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};

const Content = (props: ManagerData) => {
  const { tabIndex } = useContext(TabsContext);

  let { mobile_docking_ports, emergency, sec_level, stationary_docking_ports } = props;

  switch (tabIndex) {
    case 0:
      return <EmergencyShuttle data={emergency} sec_level={sec_level} />;
    case 1:
      return <Shuttles ports={mobile_docking_ports} />;
    case 2:
      return <StationaryPorts ports={stationary_docking_ports} />;
    default:
      return 'Something went wrong with this menu, make an issue report please!';
  }
};

export const ShuttleManager = () => {
  const { tabIndex } = useContext(TabsContext);
  const { data } = useBackend<ManagerData>();

  return (
    <Window width={700} height={650} title="Shuttle Manager">
      <Window.Content scrollable>
        <TabsContext.Default tabIndex={tabIndex}>
          <Stack fill vertical>
            <Stack.Item>
              <Navigation />
              <Content {...data} />
            </Stack.Item>
          </Stack>
        </TabsContext.Default>
      </Window.Content>
    </Window>
  );
};

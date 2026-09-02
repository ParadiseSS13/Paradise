import {
  Box,
  Button,
  Collapsible,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

export const PowernetDebugger = (props) => {
  return (
    <Window title="Powernet Debugger" width={1000} height={750}>
      <Window.Content scrollable>
        <DebuggerNavigation />
        <DebuggerContent />
      </Window.Content>
    </Window>
  );
};

const DebuggerNavigation = (props) => {
  const { data, act } = useBackend();
  const [tabIndex, setTabIndex] = useLocalState('tabIndex', 'powernets');
  const { selected_nets } = data;
  return (
    <Tabs>
      <Tabs.Tab
        icon="list"
        selected={tabIndex === 'powernets'}
        onClick={() => {
          setTabIndex('powernets');
          act('set_page', { page: 1 });
        }}
      >
        Global Powernet List
      </Tabs.Tab>
      {selected_nets.map((net) => (
        <Tabs.Tab
          key={net}
          icon="bolt"
          selected={tabIndex === net}
          onClick={() => {
            act('detailed_view', { PW_UID: net });
            setTabIndex(net);
          }}
        >
          {net}
        </Tabs.Tab>
      ))}
      {selected_nets.length > 0 && (
        <Tabs.Tab icon="folder-minus" color="red" onClick={() => act('clear_tabs')}>
          Clear Tabs
        </Tabs.Tab>
      )}
    </Tabs>
  );
};

const DebuggerContent = (props) => {
  const { data } = useBackend();
  const { debug_page } = data;

  switch (debug_page) {
    case 1:
      return <PowernetList />;
    case 2:
      return <DetailedPowernet />;
    default:
      return <NoticeBox danger>{"You are somehow on a tab that doesn't exist! Please let a coder know."}</NoticeBox>;
  }
};

// Numeric, sortable columns for the global powernet list. `power` columns are rendered through formatPower().
const SORT_COLUMNS = [
  { key: 'cables', label: 'Cables', tooltip: 'Number of cable segments in this powernet' },
  { key: 'nodes', label: 'Nodes', tooltip: 'Power machines wired directly into the net (SMES, terminals, etc.)' },
  { key: 'available_power', label: 'Available', tooltip: 'Power available to draw this cycle', power: true },
  { key: 'power_demand', label: 'Demand', tooltip: 'Power drawn from the net this cycle', power: true },
  { key: 'queued_production', label: 'Q. Prod', tooltip: 'Production queued for the next cycle', power: true },
  { key: 'queued_demand', label: 'Q. Demand', tooltip: 'Demand queued for the next cycle', power: true },
];

const SortHeaderCell = (props) => {
  const { column } = props;
  const [sortBy, setSortBy] = useLocalState('pw_sortBy', 'cables');
  const [sortAsc, setSortAsc] = useLocalState('pw_sortAsc', false);
  const active = sortBy === column.key;
  return (
    <Table.Cell header>
      <Tooltip content={column.tooltip}>
        <Box
          inline
          nowrap
          style={{ cursor: 'pointer' }}
          color={active ? 'white' : 'label'}
          onClick={() => {
            if (active) {
              setSortAsc(!sortAsc);
            } else {
              setSortBy(column.key);
              setSortAsc(false);
            }
          }}
        >
          {column.label}
          {active && <Icon ml={0.5} name={sortAsc ? 'caret-up' : 'caret-down'} />}
        </Box>
      </Tooltip>
    </Table.Cell>
  );
};

const PowernetList = (props) => {
  const [, setTabIndex] = useLocalState('tabIndex', 'powernets');
  const [sortBy] = useLocalState('pw_sortBy', 'cables');
  const [sortAsc] = useLocalState('pw_sortAsc', false);
  const { act, data } = useBackend();
  const { powernets = [], filters } = data;

  const sorted = [...powernets].sort((a, b) => {
    const delta = (a[sortBy] ?? 0) - (b[sortBy] ?? 0);
    return sortAsc ? delta : -delta;
  });

  return (
    <Section
      title="Regional Powernets"
      buttons={
        <>
          <Box inline mr={1} color="label">
            {powernets.length} shown
          </Box>
          <Button.Checkbox
            content="Station only"
            checked={!filters.off_station}
            tooltip="When on, hides powernets that aren't on a station z-level"
            onClick={() => act('filter_off_station')}
          />
        </>
      }
    >
      {powernets.length === 0 ? (
        <NoticeBox info>
          No regional powernets match your filters. Try toggling &quot;Station only&quot; off, or check that there are
          cabled powernets large enough to be listed.
        </NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell header>Powernet</Table.Cell>
            {SORT_COLUMNS.map((column) => (
              <SortHeaderCell key={column.key} column={column} />
            ))}
            <Table.Cell header textAlign="right">
              Actions
            </Table.Cell>
          </Table.Row>
          {sorted.map((powernet) => {
            const deficit = powernet.power_demand > powernet.available_power;
            return (
              <Table.Row key={powernet.PW_UID} className="candystripe">
                <Table.Cell>
                  <Button
                    icon="magnifying-glass"
                    tooltip="View Variables"
                    onClick={() => act('open_vv', { tgt_UID: powernet.PW_UID })}
                  >
                    {powernet.PW_UID}
                  </Button>
                </Table.Cell>
                <Table.Cell>{powernet.cables}</Table.Cell>
                <Table.Cell>{powernet.nodes}</Table.Cell>
                <Table.Cell>{formatPower(powernet.available_power)}</Table.Cell>
                <Table.Cell>
                  <Box inline color={deficit ? 'bad' : 'good'}>
                    {formatPower(powernet.power_demand)}
                  </Box>
                </Table.Cell>
                <Table.Cell>{formatPower(powernet.queued_production)}</Table.Cell>
                <Table.Cell>{formatPower(powernet.queued_demand)}</Table.Cell>
                <Table.Cell textAlign="right">
                  <Button
                    icon="microscope"
                    tooltip="Detailed view"
                    onClick={() => {
                      act('detailed_view', { PW_UID: powernet.PW_UID });
                      setTabIndex(powernet.PW_UID);
                    }}
                  >
                    Details
                  </Button>
                </Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      )}
    </Section>
  );
};

const PowernetImage = (props) => {
  const { data } = useBackend();
  return (
    <img
      src={`data:image/jpeg;base64,${data.power_images[props.power_type][props.dir]}`}
      style={{
        verticalAlign: 'middle',
        width: '32px',
        margin: '0px',
        marginLeft: '0px',
        marginRight: '4px',
      }}
    />
  );
};

// Small helper: renders an "On"/"Off" powernet channel value with good/bad coloring.
const StatusCell = (props) => {
  const on = props.value === 'On';
  return (
    <Table.Cell>
      <Box inline color={on ? 'good' : 'bad'}>
        {props.value}
      </Box>
    </Table.Cell>
  );
};

const LocalNetList = (props) => {
  const { act, data } = useBackend();
  const [, setTabIndex] = useLocalState('tabIndex', 'powernets');
  const { selected_net } = data;
  const localNets = selected_net.local_powernets ?? [];

  return (
    <Collapsible title={`Local Powernets (${localNets.length})`} icon="diagram-project">
      {localNets.length === 0 ? (
        <NoticeBox info>No local powernets are hanging off this regional net.</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell header>Powernet</Table.Cell>
            <Table.Cell header>Area</Table.Cell>
            <Table.Cell header>
              <Tooltip content="Machines registered to this local powernet">Machines</Tooltip>
            </Table.Cell>
            <Table.Cell header>
              <Tooltip content="Master breaker (APC operating)">M</Tooltip>
            </Table.Cell>
            <Table.Cell header>
              <Tooltip content="Equipment channel">Eq</Tooltip>
            </Table.Cell>
            <Table.Cell header>
              <Tooltip content="Lighting channel">L</Tooltip>
            </Table.Cell>
            <Table.Cell header>
              <Tooltip content="Environment channel">Env</Tooltip>
            </Table.Cell>
            <Table.Cell header textAlign="right">
              Actions
            </Table.Cell>
          </Table.Row>
          {localNets.map((powernet) => (
            <Table.Row key={powernet.PW_UID} className="candystripe">
              <Table.Cell>
                <Button
                  icon="magnifying-glass"
                  tooltip="View Variables"
                  onClick={() => act('open_vv', { tgt_UID: powernet.PW_UID })}
                >
                  {powernet.PW_UID}
                </Button>
              </Table.Cell>
              <Table.Cell>{powernet.name}</Table.Cell>
              <Table.Cell>{powernet.machines}</Table.Cell>
              <StatusCell value={powernet.master} />
              <StatusCell value={powernet.equipment} />
              <StatusCell value={powernet.lighting} />
              <StatusCell value={powernet.environment} />
              <Table.Cell textAlign="right">
                <Button
                  icon="location-crosshairs"
                  tooltip="Jump to area"
                  onClick={() => act('jmp', { tgt_UID: powernet.PW_UID })}
                />
                <Button
                  icon="microscope"
                  tooltip="Detailed view"
                  onClick={() => {
                    act('detailed_view', { PW_UID: powernet.PW_UID });
                    setTabIndex(powernet.PW_UID);
                  }}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Collapsible>
  );
};

const RegionalMachineList = (props) => {
  const { act, data } = useBackend();
  const { selected_net, filters } = data;
  const machines = selected_net.power_machines ?? [];
  return (
    <>
      <Stack mb={1} align="center">
        <Stack.Item grow color="label">
          Filters
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox content="APCs" checked={!filters.apcs} onClick={() => act('filter_apcs')} />
          <Button.Checkbox content="Terminals" checked={!filters.terminals} onClick={() => act('filter_terminals')} />
        </Stack.Item>
      </Stack>
      {machines.length === 0 ? (
        <NoticeBox info>No power machines match your filters.</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell header>Machine</Table.Cell>
            <Table.Cell header>Name</Table.Cell>
            <Table.Cell header textAlign="right">
              Actions
            </Table.Cell>
          </Table.Row>
          {machines.map((machine) => (
            <Table.Row key={machine.PW_UID} className="candystripe">
              <Table.Cell>
                <PowernetImage power_type={machine.type} dir={machine.dir} />
                <Box inline color="label">
                  {machine.PW_UID}
                </Box>
              </Table.Cell>
              <Table.Cell>{machine.name}</Table.Cell>
              <Table.Cell textAlign="right">
                <Button
                  icon="magnifying-glass"
                  tooltip="View Variables"
                  onClick={() => act('open_vv', { tgt_UID: machine.PW_UID })}
                />
                <Button
                  icon="location-crosshairs"
                  tooltip="Jump to machine"
                  onClick={() => act('jmp', { tgt_UID: machine.PW_UID })}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </>
  );
};

const LocalMachineList = (props) => {
  const { act, data } = useBackend();
  const { selected_net, filters } = data;
  const machines = selected_net.local_machines ?? [];
  return (
    <>
      <Stack mb={1} align="center">
        <Stack.Item grow color="label">
          Filters
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox content="Lights" checked={!filters.lights} onClick={() => act('filter_lights')} />
          <Button.Checkbox content="Pipes" checked={!filters.pipes} onClick={() => act('filter_pipes')} />
        </Stack.Item>
      </Stack>
      {machines.length === 0 ? (
        <NoticeBox info>No machines match your filters.</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell header>Machine</Table.Cell>
            <Table.Cell header>Name</Table.Cell>
            <Table.Cell header>Powered</Table.Cell>
            <Table.Cell header>Channel</Table.Cell>
            <Table.Cell header>State</Table.Cell>
            <Table.Cell header>
              <Tooltip content="Idle power consumption">Idle</Tooltip>
            </Table.Cell>
            <Table.Cell header>
              <Tooltip content="Active power consumption">Active</Tooltip>
            </Table.Cell>
          </Table.Row>
          {machines.map((machine) => (
            <Table.Row key={machine.PW_UID} className="candystripe">
              <Table.Cell>
                <PowernetImage power_type={machine.type} dir={machine.dir} />
                <Button
                  icon="magnifying-glass"
                  tooltip="View Variables"
                  onClick={() => act('open_vv', { tgt_UID: machine.PW_UID })}
                />
                <Button
                  icon="location-crosshairs"
                  tooltip="Jump to machine"
                  onClick={() => act('jmp', { tgt_UID: machine.PW_UID })}
                />
              </Table.Cell>
              <Table.Cell>{machine.name}</Table.Cell>
              <Table.Cell>
                <Box inline color={machine.powered ? 'good' : 'bad'}>
                  {machine.powered ? 'Powered' : 'Offline'}
                </Box>
              </Table.Cell>
              <Table.Cell>{machine.pw_channel}</Table.Cell>
              <Table.Cell>{machine.pw_state}</Table.Cell>
              <Table.Cell>{formatPower(machine.idle_consumption)}</Table.Cell>
              <Table.Cell>{formatPower(machine.active_consumption)}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </>
  );
};

const PowerMachineList = (props) => {
  const { data } = useBackend();
  const { selected_net } = data;
  if (!selected_net || !selected_net.power_stats) {
    return null;
  }
  return (
    <Collapsible title="Power Machines" icon="server">
      {selected_net.net_type === 'regional' && <RegionalMachineList />}
      {selected_net.net_type === 'local' && <LocalMachineList />}
    </Collapsible>
  );
};

// Renders a local powernet channel: colored On/Off plus its passive draw.
const ChannelRow = (props) => {
  const { label, channel } = props;
  return (
    <LabeledList.Item label={label}>
      <Box inline color={channel.powered ? 'good' : 'bad'}>
        {channel.powered ? 'On' : 'Off'}
      </Box>
      <Box inline ml={1} color="label">
        {formatPower(channel.passive_consumption)}
      </Box>
    </LabeledList.Item>
  );
};

const PowernetStats = (props) => {
  const { data } = useBackend();
  const { selected_net } = data;
  const stats = selected_net.power_stats;
  if (!stats) {
    return null;
  }

  return (
    <Collapsible title="Powernet Stats" icon="gauge-high" open>
      {selected_net.net_type === 'regional' && (
        <LabeledList>
          <LabeledList.Item label="Cable Count">{stats.cables}</LabeledList.Item>
          <LabeledList.Item label="Available Power">{formatPower(stats.available_power)}</LabeledList.Item>
          <LabeledList.Item label="Power Demand">
            <Box inline color={stats.power_demand > stats.available_power ? 'bad' : 'good'}>
              {formatPower(stats.power_demand)}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Queued Production">{formatPower(stats.queued_production)}</LabeledList.Item>
          <LabeledList.Item label="Queued Demand">{formatPower(stats.queued_demand)}</LabeledList.Item>
        </LabeledList>
      )}
      {selected_net.net_type === 'local' && (
        <LabeledList>
          <LabeledList.Item label="Area">{stats.area_name}</LabeledList.Item>
          <LabeledList.Item label="Power Flag">{stats.power_flag}</LabeledList.Item>
          <LabeledList.Item label="APC">
            <Box inline color={stats.has_apc ? 'good' : 'bad'}>
              {stats.has_apc ? 'Has APC' : 'No APC'}
            </Box>
          </LabeledList.Item>
          <ChannelRow label="Master Channel" channel={stats.all_channels} />
          <ChannelRow label="Equipment Channel" channel={stats.equipment_channel} />
          <ChannelRow label="Lighting Channel" channel={stats.lighting_channel} />
          <ChannelRow label="Environment Channel" channel={stats.environment_channel} />
        </LabeledList>
      )}
    </Collapsible>
  );
};

const PowernetLogs = (props) => {
  const { data } = useBackend();
  const { selected_net } = data;
  const logs = selected_net.logs ?? [];

  return (
    <Collapsible title={`Powernet Logs (${logs.length})`} icon="scroll">
      {logs.length === 0 ? (
        <NoticeBox info>
          No log entries. Powernet logging is for debugging purposes only and is not enabled by default.
          here.
        </NoticeBox>
      ) : (
        <Box m={1} style={{ fontFamily: 'monospace', maxHeight: '200px', overflowY: 'auto' }}>
          {logs.map((log, index) => (
            <Box key={index} className="candystripe" p="2px" style={{ whiteSpace: 'pre-wrap' }}>
              {log}
            </Box>
          ))}
        </Box>
      )}
    </Collapsible>
  );
};

const DetailedPowernet = (props) => {
  const { act, data } = useBackend();
  const { selected_net } = data;

  if (!selected_net || !selected_net.power_stats) {
    return (
      <Section
        title="Powernet"
        buttons={
          <Button icon="arrow-left" onClick={() => act('set_page', { page: 1 })}>
            Back to list
          </Button>
        }
      >
        <NoticeBox info>
          This powernet is no longer available (it may have been rebuilt). Head back to the list.
        </NoticeBox>
      </Section>
    );
  }

  const PW_UID = selected_net.power_stats.PW_UID;
  const label = selected_net.net_type === 'local' ? 'Local' : 'Regional';

  return (
    <Section
      title={`${label} Powernet ${PW_UID}`}
      buttons={
        <Button icon="arrow-left" onClick={() => act('set_page', { page: 1 })}>
          Back to list
        </Button>
      }
    >
      <PowernetStats />
      <PowerMachineList />
      {selected_net.local_powernets && <LocalNetList />}
      {selected_net.logs && <PowernetLogs />}
    </Section>
  );
};

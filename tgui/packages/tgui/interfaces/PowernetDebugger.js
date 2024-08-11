import { useBackend, useLocalState } from '../backend';
import { Button, Section, Table, Box, LabeledList, Collapsible, ProgressBar, Tabs, Icon } from '../components';
import { Window } from '../layouts';

export const PowernetDebugger = (props, context) => {
  return (
    <Window resizable width={1000} height={750}>
      <Window.Content scrollable>
        <DebuggerNavigation />
        <DebuggerContent />
      </Window.Content>
    </Window>
  );
};

const DebuggerNavigation = (properties, context) => {
  const { data, act } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 'powernets');
  const { selected_nets } = data;
  return (
    <Tabs>
      <Tabs.Tab
        selected={'powernets' === tabIndex}
        onClick={() => {
          setTabIndex('powernets');
          act('set_page', { 'page': 1 });
        }}
      >
        <Icon name="list" />
        Global Powernet List
      </Tabs.Tab>
      {selected_nets.map((net) => (
        <Tabs.Tab
          key={net}
          selected={net === tabIndex}
          onClick={() => {
            act('detailed_view', { 'PW_UID': net });
            setTabIndex(net);
          }}
        >
          <Icon name="bolt" />
          {net}
        </Tabs.Tab>
      ))}
      <Tabs.Tab color="red" onClick={() => act('clear_tabs')}>
        <Icon name="folder-minus" />
        Clear Tabs
      </Tabs.Tab>
    </Tabs>
  );
};

const DebuggerContent = (props, context) => {
  const { data } = useBackend(context);
  const { debug_page } = data;

  switch (debug_page) {
    case 1:
      return <PowernetList />;
    case 2:
      return <DetailedPowernet />;
    default:
      return "You are somehow on a tab that doesn't exist! Please let a coder know.";
  }
};

const PowernetList = (properties, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex');
  const { act, data } = useBackend(context);

  const { powernets, filters } = data;

  return (
    <Section title="Powernets">
      <LabeledList>
        <LabeledList.Item label="Filters">
          <Button.Checkbox
            content="Off-Station"
            checked={!filters.off_station}
            selected={!filters.off_station}
            onClick={() => act('filter_off_station')}
          />
        </LabeledList.Item>
      </LabeledList>
      <Table className="Library__Booklist">
        <Table.Row bold>
          <Table.Cell>PW-UID</Table.Cell>
          <Table.Cell>Cables</Table.Cell>
          <Table.Cell>Nodes</Table.Cell>
          <Table.Cell>Avail</Table.Cell>
          <Table.Cell>D</Table.Cell>
          <Table.Cell>QP</Table.Cell>
          <Table.Cell>QD</Table.Cell>
        </Table.Row>
        {powernets.map((powernet) => (
          <Table.Row key={powernet.PW_UID}>
            <Table.Cell>
              <Button
                content={`${powernet.PW_UID} (VV)`}
                onClick={() => act('open_vv', { 'tgt_UID': powernet.PW_UID })}
              />
            </Table.Cell>
            <Table.Cell>{powernet.cables}</Table.Cell>
            <Table.Cell>{powernet.nodes} </Table.Cell>
            <Table.Cell>{powernet.available_power} </Table.Cell>
            <Table.Cell>{powernet.power_demand} </Table.Cell>
            <Table.Cell>{powernet.queued_demand} </Table.Cell>
            <Table.Cell>{powernet.queued_production} </Table.Cell>
            <Table.Cell textAlign="right">
              <Button
                content="Details"
                icon="microscope"
                onClick={() => {
                  act('detailed_view', { 'PW_UID': powernet.PW_UID });
                  setTabIndex(powernet.PW_UID);
                }}
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const PowernetImage = (props, context) => {
  const { data } = useBackend(context);
  return (
    <img
      src={`data:image/jpeg;base64,${data.power_images[props.power_type][props.dir]}`}
      style={{
        'vertical-align': 'middle',
        width: '32px',
        margin: '0px',
        'margin-left': '0px',
        'margin-right': '4px',
      }}
    />
  );
};

const LocalNetList = (properties, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 'powernets');
  const { selected_net } = data;

  return (
    <Collapsible title="Local Powernets">
      <Table className="Library__Booklist">
        <Table.Row bold>
          <Table.Cell>PW-UID</Table.Cell>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Machine Count</Table.Cell>
          <Table.Cell>M</Table.Cell>
          <Table.Cell>Eq</Table.Cell>
          <Table.Cell>L</Table.Cell>
          <Table.Cell>Env</Table.Cell>
        </Table.Row>
        {selected_net.local_powernets.map((powernet) => (
          <Table.Row key={powernet.PW_UID}>
            <Button
              content={`${powernet.PW_UID} (VV)`}
              onClick={() => act('open_vv', { 'tgt_UID': powernet.PW_UID })}
            />
            <Table.Cell>{powernet.name}</Table.Cell>
            <Table.Cell>{powernet.machines} </Table.Cell>
            <Table.Cell>{powernet.master} </Table.Cell>
            <Table.Cell>{powernet.equipment} </Table.Cell>
            <Table.Cell>{powernet.lighting} </Table.Cell>
            <Table.Cell>{powernet.environment} </Table.Cell>
            <Table.Cell textAlign="right">
              <Button content="JMP" icon="print" onClick={() => act('jmp', { 'tgt_UID': powernet.PW_UID })} />
              <Button
                content="Details"
                icon="microscope"
                onClick={() => {
                  act('detailed_view', { 'PW_UID': powernet.PW_UID });
                  setTabIndex(powernet.PW_UID);
                }}
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Collapsible>
  );
};

const PowerMachineList = (properties, context) => {
  const { act, data } = useBackend(context);

  const { selected_net, filters } = data;

  return (
    <Collapsible title="Power Machines">
      {selected_net && selected_net.net_type === 'regional' && Boolean(selected_net.power_stats) && (
        <>
          <LabeledList>
            <LabeledList.Item label="Filters">
              <Button.Checkbox
                content="APCs"
                checked={!filters.apcs}
                selected={!filters.apcs}
                onClick={() => act('filter_apcs')}
              />
              <Button.Checkbox
                content="Terminals"
                checked={!filters.terminals}
                selected={!filters.terminals}
                onClick={() => act('filter_terminals')}
              />
            </LabeledList.Item>
          </LabeledList>
          <Table className="Library__Booklist">
            <Table.Row bold>
              <Table.Cell>PW-UID</Table.Cell>
              <Table.Cell>Machine</Table.Cell>
            </Table.Row>
            {selected_net.power_machines.map((machine) => (
              <Table.Row key={machine.PW_UID}>
                <Table.Cell>
                  <PowernetImage power_type={machine.type} dir={machine.dir} />
                  <Button
                    content={`${machine.PW_UID} (VV)`}
                    onClick={() => act('open_vv', { 'tgt_UID': machine.PW_UID })}
                  />
                  <Button content="JMP" onClick={() => act('jmp', { 'tgt_UID': machine.PW_UID })} />
                </Table.Cell>
                <Table.Cell>{machine.name}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </>
      )}
      {selected_net && selected_net.net_type === 'local' && Boolean(selected_net.power_stats) && (
        <>
          <LabeledList>
            <LabeledList.Item label="Filters">
              <Button.Checkbox
                content="Lights"
                checked={!filters.lights}
                selected={!filters.lights}
                onClick={() => act('filter_lights')}
              />
              <Button.Checkbox
                content="Pipes"
                checked={!filters.pipes}
                selected={!filters.pipes}
                onClick={() => act('filter_pipes')}
              />
            </LabeledList.Item>
          </LabeledList>
          <Table className="Library__Booklist">
            <Table.Row bold>
              <Table.Cell>PW-UID</Table.Cell>
              <Table.Cell>Machine</Table.Cell>
              <Table.Cell>Powered</Table.Cell>
              <Table.Cell>Channel</Table.Cell>
              <Table.Cell>State</Table.Cell>
              <Table.Cell>Idle Csmp</Table.Cell>
              <Table.Cell>Active Csmp</Table.Cell>
            </Table.Row>
            {selected_net &&
              selected_net.local_machines.map((machine) => (
                <Table.Row key={machine.PW_UID}>
                  <Table.Cell>
                    <PowernetImage power_type={machine.type} dir={machine.dir} />
                    <Button
                      content={`${machine.PW_UID} (VV)`}
                      onClick={() => act('open_vv', { 'tgt_UID': machine.PW_UID })}
                    />
                    <Button content="JMP" onClick={() => act('jmp', { 'tgt_UID': machine.PW_UID })} />
                  </Table.Cell>
                  <Table.Cell>{machine.name}</Table.Cell>
                  <Table.Cell>{machine.powered ? 'Powered' : 'Offline'}</Table.Cell>
                  <Table.Cell>{machine.pw_channel}</Table.Cell>
                  <Table.Cell>{machine.pw_state}</Table.Cell>
                  <Table.Cell>{machine.idle_consumption}</Table.Cell>
                  <Table.Cell>{machine.active_consumption}</Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </>
      )}
    </Collapsible>
  );
};

const PowernetStats = (properties, context) => {
  const { act, data } = useBackend(context);
  const { selected_net } = data;

  let masterChannel = '';
  let equipmentChannel = '';
  let lightingChannel = '';
  let environmentChannel = '';
  if (selected_net.net_type === 'local') {
    masterChannel += selected_net.power_stats.all_channels['powered'] ? 'On - ' : 'Off - ';
    masterChannel += `${selected_net.power_stats.all_channels['passive_consumption']} kw`;
    equipmentChannel += selected_net.power_stats.equipment_channel['powered'] ? 'On - ' : 'Off - ';
    equipmentChannel += `${selected_net.power_stats.equipment_channel['passive_consumption']} kw`;
    lightingChannel += selected_net.power_stats.lighting_channel['powered'] ? 'On - ' : 'Off - ';
    lightingChannel += `${selected_net.power_stats.lighting_channel['passive_consumption']} kw`;
    environmentChannel += selected_net.power_stats.environment_channel['powered'] ? 'On - ' : 'Off - ';
    environmentChannel += `${selected_net.power_stats.environment_channel['passive_consumption']} kw`;
  }

  return (
    <Collapsible title="Powernet Stats">
      {selected_net.net_type === 'regional' && (
        <LabeledList>
          <LabeledList.Item label="cable count">{selected_net.power_stats.cables}</LabeledList.Item>
          <LabeledList.Item label="Available Power">{selected_net.power_stats.available_power}</LabeledList.Item>
          <LabeledList.Item label="Power Demand">{selected_net.power_stats.power_demand}</LabeledList.Item>
          <LabeledList.Item label="Queued Production">{selected_net.power_stats.queued_production}</LabeledList.Item>
          <LabeledList.Item label="Queued Demand">{selected_net.power_stats.queued_demand}</LabeledList.Item>
        </LabeledList>
      )}
      {selected_net.net_type === 'local' && (
        <LabeledList>
          <LabeledList.Item label="Area">{selected_net.power_stats.area_name}</LabeledList.Item>
          <LabeledList.Item label="Power Flag">{selected_net.power_stats.power_flag}</LabeledList.Item>
          <LabeledList.Item label="APC">{selected_net.power_stats.has_apc ? 'Has APC' : 'No APC'}</LabeledList.Item>
          <LabeledList.Item label="Master Channel">{masterChannel}</LabeledList.Item>
          <LabeledList.Item label="Equipment Channel">{equipmentChannel}</LabeledList.Item>
          <LabeledList.Item label="Lighting Channel">{lightingChannel}</LabeledList.Item>
          <LabeledList.Item label="Environment Channel">{environmentChannel}</LabeledList.Item>
        </LabeledList>
      )}
    </Collapsible>
  );
};

const PowernetLogs = (properties, context) => {
  const { act, data } = useBackend(context);
  const { selected_net } = data;

  return (
    <Collapsible title="Powernet Logs">
      {selected_net.logs.map((log) => (
        <>
          {log}
          <br />
        </>
      ))}
    </Collapsible>
  );
};

const DetailedPowernet = (properties, context) => {
  const { act, data } = useBackend(context);

  const { selected_net } = data;

  let PW_UID = '';
  if (selected_net && selected_net.power_stats) {
    PW_UID = selected_net.power_stats.PW_UID;
  }

  return (
    <Section
      title={`Selected Powernet ${PW_UID}`}
      buttons={<Button content="Back" icon="sign-out-alt" onClick={() => act('set_page', { 'page': 1 })} />}
    >
      <PowernetStats />
      <PowerMachineList />
      {selected_net.local_powernets && <LocalNetList />}
      {selected_net.logs && <PowernetLogs />}
    </Section>
  );
};

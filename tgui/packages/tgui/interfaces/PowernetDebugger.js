import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Section,
  Table,
  Box,
  LabeledList,
  Collapsible,
  ProgressBar,
  Tabs,
  Icon } from '../components';
import { LabeledListItem } from '../components/LabeledList';
import { Window } from '../layouts';

export const PowernetDebugger = (props, context) => {
  return (
    <Window resizable>
      <Window.Content scrollable>
        <LibraryComputerNavigation/>
        <DebuggerContent />
      </Window.Content>
    </Window>
  );
};

const LibraryComputerNavigation = (properties, context) => {
  const { data, act } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', "powernets");
  const { selected_nets } = data
  return (
    <Tabs>
      <Tabs.Tab
        selected={"powernets" === tabIndex}
        onClick={() => {
          setTabIndex("powernets")
          act('set_page', { "page" : 1 });}}>
        <Icon name="list" />
        Global Powernet List
      </Tabs.Tab>
      {selected_nets
        .map(net => (
          <Tabs.Tab key={net}
            selected={net === tabIndex}
            onClick={() =>  {
              act('detailed_view', { "PW_UID" : net})
              setTabIndex(net);}}>
            <Icon name="bolt" />
            {net}
          </Tabs.Tab>
        ))
      }
      <Tabs.Tab
        color="red"
        onClick={() => act('clear_tabs')}>
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
      return <DetailedPowernet/>;
    default:
      return "You are somehow on a tab that doesn't exist! Please let a coder know.";
  }
};

const PowernetList = (properties, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex');
  const { act, data } = useBackend(context);

  const { powernets } = data;

  return (
    <Section title="Powernets">
      <Table className="Library__Booklist">
        <Table.Row bold>
          <Table.Cell>PW-UID</Table.Cell>
          <Table.Cell>Voltage</Table.Cell>
          <Table.Cell>Cables</Table.Cell>
          <Table.Cell>Nodes</Table.Cell>
          <Table.Cell>Batteries</Table.Cell>
          <Table.Cell>Subnets</Table.Cell>
          <Table.Cell>Avail</Table.Cell>
          <Table.Cell>D</Table.Cell>
          <Table.Cell>QP</Table.Cell>
          <Table.Cell>QD</Table.Cell>
        </Table.Row>
        {powernets
          .map(powernet => (
              <Table.Row key={powernet.PW_UID}>
                <Table.Cell>{powernet.PW_UID}</Table.Cell>
                <Table.Cell>{powernet.voltage === 1 ? <Box color="Green">LOW</Box> : <Box color="Yellow">HIGH</Box>}</Table.Cell>
                <Table.Cell>{powernet.cables}</Table.Cell>
                <Table.Cell>{powernet.nodes} </Table.Cell>
                <Table.Cell>{powernet.batteries} </Table.Cell>
                <Table.Cell>{powernet.subnet_connectors} </Table.Cell>
                <Table.Cell>{powernet.available_power} </Table.Cell>
                <Table.Cell>{powernet.power_demand} </Table.Cell>
                <Table.Cell>{powernet.queued_demand} </Table.Cell>
                <Table.Cell>{powernet.queued_production} </Table.Cell>
                <Table.Cell textAlign="right">
                  <Button
                      content="JMP"
                      icon="print"
                      onClick={() => act('shitfuck', {})}
                    />
                  <Button
                    content="Details"
                    icon="microscope"
                    onClick={() => {
                      act('detailed_view', {"PW_UID": powernet.PW_UID})
                      setTabIndex(powernet.PW_UID);}}
                  />
                </Table.Cell>
              </Table.Row>
          ))}
      </Table>
    </Section>
  );
};



const PowerMachineList = (properties, context) => {
  const { act, data } = useBackend(context);

  const { selected_net } = data;

  return (
    <Collapsible title="Power Machines">
      <Table className="Library__Booklist">
        <Table.Row bold>
          <Table.Cell>PW-UID</Table.Cell>
          <Table.Cell>Machine</Table.Cell>
        </Table.Row>
        {selected_net.power_machines
            .map(machine => (
              <Table.Row key={machine.PW_UID}>
                <Table.Cell>
                  <PowernetImage power_type={machine.type} dir={machine.dir}/>
                  <Button
                    content={`${machine.PW_UID} (VV)`}
                    onClick={() => act('open_vv', { "PW_UID" : machine.PW_UID })}
                  />
                  <Button
                    content="JMP"
                    onClick={() => act('jmp', { "PW_UID" : machine.PW_UID })}
                  />
                </Table.Cell>
                <Table.Cell>{machine.name}</Table.Cell>
              </Table.Row>
          ))}
      </Table>
    </Collapsible>
  );
};

const BatteryList = (properties, context) => {
  const { act, data } = useBackend(context);
  const { selected_net } = data;

  return (
    <Collapsible title="Batteries">
      <Table className="Library__Booklist">
        <Table.Row bold>
          <Table.Cell>PW-UID</Table.Cell>
          <Table.Cell>Battery</Table.Cell>
          <Table.Cell>Status</Table.Cell>
          <Table.Cell>Charge</Table.Cell>
          <Table.Cell>Max Charge</Table.Cell>
          <Table.Cell>Safe Capacity</Table.Cell>
        </Table.Row>
        {selected_net.batteries
            .map(battery => (
              <Table.Row key={battery.PW_UID}>
                <Table.Cell>
                  <PowernetImage power_type={battery.type} dir={battery.dir}/>
                  <Button
                    content={`${battery.PW_UID} (VV)`}
                    onClick={() => act('open_vv', { "PW_UID" : battery.PW_UID })}
                  />
                  <Button
                    content="JMP"
                    onClick={() => act('jmp', { "PW_UID" : battery.PW_UID })}
                  />
                </Table.Cell>
                <Table.Cell>{battery.name}</Table.Cell>
                <Table.Cell>{battery.status}</Table.Cell>
                <Table.Cell>
                  <ProgressBar
                    value={battery.charge / battery.max_charge}
                    ranges={{
                      good: [0.5, Infinity],
                      average: [0.15, 0.5],
                      bad: [-Infinity, 0.15],
                    }}
                  />
                </Table.Cell>
                <Table.Cell>{battery.max_charge}</Table.Cell>
                <Table.Cell>{battery.safe_capacity}</Table.Cell>
              </Table.Row>
          ))}
        </Table>
      </Collapsible>
  );
};

const TransformerList = (properties, context) => {
  const { act, data } = useBackend(context);

  const { selected_net } = data;

  return (
    <Collapsible title="Transformers">
      <Table className="Library__Booklist">
          <Table.Row bold>
            <Table.Cell>PW-UID</Table.Cell>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>Wattage Setting</Table.Cell>
            <Table.Cell>Last Output</Table.Cell>
          </Table.Row>
          {selected_net.transformers
              .map(transformer => (
                <Table.Row key={transformer.PW_UID}>
                  <PowernetImage power_type={transformer.type} dir={transformer.dir}/>
                  <Button
                    content={`${transformer.PW_UID} (VV)`}
                    onClick={() => act('open_vv', { "PW_UID" : transformer.PW_UID })}
                  />
                  <Button
                    content="JMP"
                    onClick={() => act('jmp', { "PW_UID" : transformer.PW_UID })}
                  />
                  <Table.Cell>{transformer.name}</Table.Cell>
                  <Table.Cell>{transformer.wattage_setting}</Table.Cell>
                  <Table.Cell>{transformer.last_output}</Table.Cell>
                </Table.Row>
              ))}
        </Table>
      </Collapsible>
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
        'margin-right' : '4px'
      }}
    />
  )

}

const PowernetStats = (properties, context) => {
  const { act, data } = useBackend(context);
  const { selected_net } = data;

  return (
      <Section label="Powernet Stats">
        <LabeledList>
          <LabeledListItem label="voltage">{selected_net.stats.voltage === 1 ? <Box color="Yellow">LOW</Box> : <Box color="Red">HIGH</Box>}</LabeledListItem>
          <LabeledListItem label="cable count">{selected_net.stats.cables}</LabeledListItem>
          <LabeledListItem label="Available Power">{selected_net.stats.available_power}</LabeledListItem>
          <LabeledListItem label="Power Demand">{selected_net.stats.power_demand}</LabeledListItem>
          <LabeledListItem label="Queued Production">{selected_net.stats.queued_production}</LabeledListItem>
          <LabeledListItem label="Queued Demand">{selected_net.stats.queued_demand}</LabeledListItem>
        </LabeledList>
      </Section>
  );
};

const DetailedPowernet = (properties, context) => {
  const { act, data } = useBackend(context);

  const { selected_net } = data;

  return (
    <Section
      title={`Selected Powernet ${selected_net.stats.PW_UID}`}
      buttons={
        <Button
          content="Back"
          icon="sign-out-alt"
          onClick={() => act('set_page', { "page" : 1 })}
    />}>
      <PowernetStats/>
      <Section lable="Powernet Contents">
        <TransformerList/>
        <BatteryList/>
        <PowerMachineList/>
      </Section>
    </Section>
  );
};



import { map, sortBy } from 'common/collections';
import { useState } from 'react';
import {
  Box,
  Button,
  ColorBox,
  Flex,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Table,
  Tooltip,
} from 'tgui-core/components';
import { Chart } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BooleanLike } from 'tgui-core/react';
const PEAK_DRAW = 600000;

export const PowerMonitor = (props) => {
  return (
    <Window width={600} height={650}>
      <Window.Content scrollable>
        <PowerMonitorMainContent />
      </Window.Content>
    </Window>
  );
};

type APC = {
  Name: string;
  Equipment: string;
  Lights: string;
  Environment: string;
  CellPct: number;
  CellStatus: string;
  Load: number;
};

type PowerMonitorMainData = {
  powermonitor: string;
  select_monitor: BooleanLike;
};

// This constant is so it can be thrown
// into PDAs with minimal effort
export const PowerMonitorMainContent = (props) => {
  const { act, data } = useBackend<PowerMonitorMainData>();
  const { powermonitor, select_monitor } = data;
  return (
    <Box m={0}>
      {!powermonitor && select_monitor && <SelectionView />}
      {powermonitor && <DataView />}
    </Box>
  );
};

type PowerMonitor = {
  Area: string;
  uid: string;
};

type SelectionViewData = {
  powermonitors: PowerMonitor[];
};

const SelectionView = (props) => {
  const { act, data } = useBackend<SelectionViewData>();
  const { powermonitors } = data;

  return (
    <Section title="Select Power Monitor">
      {powermonitors.map((p) => (
        <Box key={p.uid}>
          <Button
            content={p.Area}
            icon="arrow-right"
            onClick={() =>
              act('selectmonitor', {
                selectmonitor: p.uid,
              })
            }
          />
        </Box>
      ))}
    </Section>
  );
};

type DataHistory = {
  supply: number[];
  demand: number[];
};

type DataViewData = {
  powermonitor: string;
  history: DataHistory;
  apcs: APC[];
  select_monitor: BooleanLike;
  no_powernet: BooleanLike;
};

const DataView = (props) => {
  const { act, data } = useBackend<DataViewData>();
  const { powermonitor, history, apcs, select_monitor, no_powernet } = data;

  let body;
  if (no_powernet) {
    body = (
      <Box color="bad" textAlign="center">
        <Icon name="exclamation-triangle" size={2} my="0.5rem" />
        <br />
        Warning: The monitor is not connected to power grid via cable!
      </Box>
    );
  } else {
    const [sortByField, setSortByField] = useState('name');
    const supply = history.supply[history.supply.length - 1] || 0;
    const demand = history.demand[history.demand.length - 1] || 0;
    const supplyData = history.supply.map((value, i) => [i, value]);
    const demandData = history.demand.map((value, i) => [i, value]);
    const maxValue = Math.max(PEAK_DRAW, ...history.supply, ...history.demand);
    // Process area data
    let parsedApcs: (APC & { id: string })[] = apcs.map((apc, i) => ({
      ...apc,
      // Generate a unique id
      id: apc.Name + i,
    }));

    switch (sortByField) {
      case 'name':
        parsedApcs = sortBy(parsedApcs, (apc) => apc.Name);
        break;
      case 'charge':
        parsedApcs = sortBy(parsedApcs, (apc) => -apc.CellPct);
        break;
      case 'draw':
        parsedApcs = sortBy(parsedApcs, (apc) => -apc.Load);
        break;
    }

    body = (
      <>
        <Flex spacing={1}>
          <Flex.Item width="200px">
            <Section>
              <LabeledList>
                <LabeledList.Item label="Supply">
                  <ProgressBar value={supply} minValue={0} maxValue={maxValue} color="green">
                    {toFixed(supply / 1000) + ' kW'}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Draw">
                  <ProgressBar value={demand} minValue={0} maxValue={maxValue} color="red">
                    {toFixed(demand / 1000) + ' kW'}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Section fill ml={1}>
              <Chart.Line
                fillPositionedParent
                data={supplyData}
                rangeX={[0, supplyData.length - 1]}
                rangeY={[0, maxValue]}
                strokeColor="rgba(32, 177, 66, 1)"
                fillColor="rgba(32, 177, 66, 0.25)"
              />
              <Chart.Line
                fillPositionedParent
                data={demandData}
                rangeX={[0, demandData.length - 1]}
                rangeY={[0, maxValue]}
                strokeColor="rgba(219, 40, 40, 1)"
                fillColor="rgba(219, 40, 40, 0.25)"
              />
            </Section>
          </Flex.Item>
        </Flex>
        <Box mb={1}>
          <Box inline mr={2} color="label">
            Sort by:
          </Box>
          <Button.Checkbox checked={sortByField === 'name'} content="Name" onClick={() => setSortByField('name')} />
          <Button.Checkbox
            checked={sortByField === 'charge'}
            content="Charge"
            onClick={() => setSortByField('charge')}
          />
          <Button.Checkbox checked={sortByField === 'draw'} content="Draw" onClick={() => setSortByField('draw')} />
        </Box>
        <Table>
          <Table.Row header>
            <Table.Cell>Area</Table.Cell>
            <Table.Cell collapsing>Charge</Table.Cell>
            <Table.Cell textAlign="right">Draw</Table.Cell>
            <Table.Cell collapsing>
              <Tooltip content="Equipment">Eqp</Tooltip>
            </Table.Cell>
            <Table.Cell collapsing>
              <Tooltip content="Lighting">Lgt</Tooltip>
            </Table.Cell>
            <Table.Cell collapsing>
              <Tooltip content="Environment">Env</Tooltip>
            </Table.Cell>
          </Table.Row>
          {map(parsedApcs, (area, i) => (
            <Table.Row key={area.id} className="Table__row candystripe">
              <Table.Cell>{decodeHtmlEntities(area.Name)}</Table.Cell>
              <Table.Cell className="Table__cell text-right text-nowrap">
                <AreaCharge charging={area.CellStatus} charge={area.CellPct} />
              </Table.Cell>
              <Table.Cell className="Table__cell text-right text-nowrap">{area.Load}</Table.Cell>
              <Table.Cell className="Table__cell text-center text-nowrap">
                <AreaStatusColorBox status={area.Equipment} />
              </Table.Cell>
              <Table.Cell className="Table__cell text-center text-nowrap">
                <AreaStatusColorBox status={area.Lights} />
              </Table.Cell>
              <Table.Cell className="Table__cell text-center text-nowrap">
                <AreaStatusColorBox status={area.Environment} />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </>
    );
  }

  return (
    <Section
      title={powermonitor}
      buttons={
        <Box m={0}>{select_monitor && <Button content="Back" icon="arrow-up" onClick={() => act('return')} />}</Box>
      }
    >
      {body}
    </Section>
  );
};

const AreaCharge = (props) => {
  const { charging, charge } = props;
  let icon_name = '';
  switch (charge) {
    case 'N':
      if (charge > 50) icon_name = 'battery-half';
      else icon_name = 'battery-quarter';
      break;
    case 'C':
      icon_name = 'bolt';
      break;
    case 'F':
      icon_name = 'battery-full';
      break;
    case 'M':
      icon_name = 'slash';
      break;
  }
  return (
    <>
      <Icon
        width="18px"
        textAlign="center"
        name={icon_name}
        color={
          (charging === 'N' && (charge > 50 ? 'yellow' : 'red')) ||
          (charging === 'C' && 'yellow') ||
          (charging === 'F' && 'green') ||
          (charging === 'M' && 'orange')
        }
      />
      <Box inline width="36px" textAlign="right">
        {toFixed(charge) + '%'}
      </Box>
    </>
  );
};

const AreaStatusColorBox = (props) => {
  let auto;
  let active;
  const { status } = props;
  switch (status) {
    case 'AOn':
      auto = true;
      active = true;
      break;
    case 'AOff':
      auto = true;
      active = false;
      break;
    case 'On':
      auto = false;
      active = true;
      break;
    case 'Off':
      auto = false;
      active = false;
      break;
  }
  const tooltipText = (active ? 'On' : 'Off') + ` [${auto ? 'auto' : 'manual'}]`;
  return (
    <Tooltip content={tooltipText}>
      <ColorBox color={active ? 'good' : 'bad'} content={auto ? undefined : 'M'} />
    </Tooltip>
  );
};

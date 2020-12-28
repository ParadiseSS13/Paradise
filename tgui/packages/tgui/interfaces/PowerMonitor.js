import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Chart, ColorBox, Flex, Icon, LabeledList, ProgressBar, Section, Table } from "../components";
import { Window } from "../layouts";
const PEAK_DRAW = 600000;

export const PowerMonitor = (props, context) => {
  return (
    <Window resizeable>
      <Window.Content scrollable>
        <PowerMonitorMainContent />
      </Window.Content>
    </Window>
  );
};

// This constant is so it can be thrown
// into PDAs with minimal effort
export const PowerMonitorMainContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    powermonitor,
    select_monitor,
  } = data;
  return (
    <Box m={0}>
      {(!powermonitor && select_monitor) && (
        <SelectionView />
      )}
      {(powermonitor && (
        <DataView />
      ))}
    </Box>
  );
};

const SelectionView = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    powermonitors,
  } = data;


  return (
    <Section title="Select Power Monitor">
      {powermonitors.map(p => (
        <Box key={p}>
          <Button
            content={p.Name}
            icon="arrow-right"
            onClick={() => act('selectmonitor', {
              selectmonitor: p.uid,
            })}
          />
        </Box>
      ))}
    </Section>
  );
};

const DataView = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    powermonitor,
    history,
    apcs,
    select_monitor,
    no_powernet,
  } = data;

  let body;
  if (no_powernet) {
    body = (
      <Box color="bad" textAlign="center">
        <Icon
          name="exclamation-triangle"
          size="2"
          my="0.5rem"
        /><br />
        Warning: The monitor is not connected to power grid via cable!
      </Box>
    );
  } else {
    const [
      sortByField,
      setSortByField,
    ] = useLocalState(context, 'sortByField', null);
    const supply = history.supply[history.supply.length - 1] || 0;
    const demand = history.demand[history.demand.length - 1] || 0;
    const supplyData = history.supply.map((value, i) => [i, value]);
    const demandData = history.demand.map((value, i) => [i, value]);
    const maxValue = Math.max(
      PEAK_DRAW,
      ...history.supply,
      ...history.demand);
      // Process area data
    const parsedApcs = flow([
      map((apc, i) => ({
        ...apc,
        // Generate a unique id
        id: apc.name + i,
      })),
      sortByField === 'name' && sortBy(apc => apc.Name),
      sortByField === 'charge' && sortBy(apc => -apc.CellPct),
      sortByField === 'draw' && sortBy(apc => -apc.Load),
    ])(apcs);

    body = (
      <Fragment>
        <Flex spacing={1}>
          <Flex.Item width="200px">
            <Section>
              <LabeledList>
                <LabeledList.Item label="Supply">
                  <ProgressBar
                    value={supply}
                    minValue={0}
                    maxValue={maxValue}
                    color="green">
                    {toFixed(supply / 1000) + ' kW'}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Draw">
                  <ProgressBar
                    value={demand}
                    minValue={0}
                    maxValue={maxValue}
                    color="red">
                    {toFixed(demand / 1000) + ' kW'}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Section position="relative" height="100%">
              <Chart.Line
                fillPositionedParent
                data={supplyData}
                rangeX={[0, supplyData.length - 1]}
                rangeY={[0, maxValue]}
                strokeColor="rgba(32, 177, 66, 1)"
                fillColor="rgba(32, 177, 66, 0.25)" />
              <Chart.Line
                fillPositionedParent
                data={demandData}
                rangeX={[0, demandData.length - 1]}
                rangeY={[0, maxValue]}
                strokeColor="rgba(219, 40, 40, 1)"
                fillColor="rgba(219, 40, 40, 0.25)" />
            </Section>
          </Flex.Item>
        </Flex>
        <Box mb={1}>
          <Box inline mr={2} color="label">
            Sort by:
          </Box>
          <Button.Checkbox
            checked={sortByField === 'name'}
            content="Name"
            onClick={() => setSortByField(sortByField !== 'name' && 'name')} />
          <Button.Checkbox
            checked={sortByField === 'charge'}
            content="Charge"
            onClick={() => setSortByField(
              sortByField !== 'charge' && 'charge'
            )} />
          <Button.Checkbox
            checked={sortByField === 'draw'}
            content="Draw"
            onClick={() => setSortByField(sortByField !== 'draw' && 'draw')} />
        </Box>
        <Table>
          <Table.Row header>
            <Table.Cell>
              Area
            </Table.Cell>
            <Table.Cell collapsing>
              Charge
            </Table.Cell>
            <Table.Cell textAlign="right">
              Draw
            </Table.Cell>
            <Table.Cell collapsing title="Equipment">
              Eqp
            </Table.Cell>
            <Table.Cell collapsing title="Lighting">
              Lgt
            </Table.Cell>
            <Table.Cell collapsing title="Environment">
              Env
            </Table.Cell>
          </Table.Row>
          {parsedApcs.map((area, i) => (
            <Table.Row
              key={area.id}
              className="Table__row candystripe">
              <Table.Cell>
                {decodeHtmlEntities(area.Name)}
              </Table.Cell>
              <Table.Cell className="Table__cell text-right text-nowrap">
                <AreaCharge
                  charging={area.CellStatus}
                  charge={area.CellPct} />
              </Table.Cell>
              <Table.Cell className="Table__cell text-right text-nowrap">
                {area.Load}
              </Table.Cell>
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
      </Fragment>
    );
  }

  return (
    <Section title={powermonitor}
      buttons={
        <Box m={0}>
          {select_monitor && (
            <Button
              content="Back"
              icon="arrow-up"
              onClick={() => act('return')}
            />
          )}
        </Box>
      }>
      {body}
    </Section>
  );
};

const AreaCharge = props => {
  const { charging, charge } = props;
  return (
    <Fragment>
      <Icon
        width="18px"
        textAlign="center"
        name={(
          charging === "N" && (
            charge > 50
              ? 'battery-half'
              : 'battery-quarter'
          )
          || charging === "C" && 'bolt'
          || charging === "F" && 'battery-full'
          || charging === "M" && 'slash'
        )}
        color={(
          charging === "N" && (
            charge > 50
              ? 'yellow'
              : 'red'
          )
          || charging === "C" && 'yellow'
          || charging === "F" && 'green'
          || charging === "M" && 'orange'
        )} />
      <Box
        inline
        width="36px"
        textAlign="right">
        {toFixed(charge) + '%'}
      </Box>
    </Fragment>
  );
};

AreaCharge.defaultHooks = pureComponentHooks;


const AreaStatusColorBox = props => {
  let auto;
  let active;
  const { status } = props;
  switch (status) {
    case "AOn":
      auto = true;
      active = true;
      break;
    case "AOff":
      auto = true;
      active = false;
      break;
    case "On":
      auto = false;
      active = true;
      break;
    case "Off":
      auto = false;
      active = false;
      break;
  }
  const tooltipText = (active ? 'On' : 'Off')
    + ` [${auto ? 'auto' : 'manual'}]`;
  return (
    <ColorBox
      color={active ? 'good' : 'bad'}
      content={auto ? undefined : 'M'}
      title={tooltipText} />
  );
};

AreaStatusColorBox.defaultHooks = pureComponentHooks;

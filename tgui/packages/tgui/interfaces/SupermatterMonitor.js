import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Section, Box, Button, Table, LabeledList, ProgressBar } from '../components';
import { Window } from '../layouts';
import { TableRow, TableCell } from '../components/Table';

export const SupermatterMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  if (data.active === 0) {
    return <SupermatterMonitorListView />;
  } else {
    return <SupermatterMonitorDataView />;
  }
};

const powerToColor = power => {
  if (power > 300) {
    return 'bad';
  } else if (power > 150) {
    return 'average';
  } else {
    return 'good';
  }
};

const temperatureToColor = temp => {
  if (temp > 5000) {
    return 'bad';
  } else if (temp > 4000) {
    return 'average';
  } else {
    return 'good';
  }
};

const pressureToColor = pressure => {
  if (pressure > 10000) {
    return 'bad';
  } else if (pressure > 5000) {
    return 'average';
  } else {
    return 'good';
  }
};

const SupermatterMonitorListView = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content scrollable>
        <Section title="Detected Supermatter Shards" buttons={
          <Button
            icon="sync"
            content="Refresh"
            onClick={() => act("refresh")}
          />
        }>
          <Box m={1}>
            {data.supermatters.length === 0 ? (
              <h3>No shards detected</h3>
            ) : (
              <Table>
                <Table.Row header>
                  <TableCell>Area</TableCell>
                  <TableCell>Integrity</TableCell>
                  <TableCell>Details</TableCell>
                </Table.Row>
                {data.supermatters.map(sm => (
                  <TableRow key={sm}>
                    <TableCell>{sm.area_name}</TableCell>
                    <TableCell>{sm.integrity}%</TableCell>
                    <TableCell>
                      <Button
                        icon="sign-in-alt"
                        content="View"
                        onClick={() => act('view', {
                          view: sm.uid,
                        })}
                      />
                    </TableCell>
                  </TableRow>
                ))}
              </Table>
            )}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

const SupermatterMonitorDataView = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content>
        <Section title="Crystal Status" buttons={
          <Button
            icon="caret-square-left"
            content="Back"
            onClick={() => act("back")}
          />
        }>
          <LabeledList>
            <LabeledList.Item label="Core Integrity">
              <ProgressBar
                ranges={{
                  good: [95, Infinity],
                  average: [80, 94],
                  bad: [-Infinity, 79],
                }}
                minValue="0"
                maxValue="100"
                value={data.SM_integrity}>
                {data.SM_integrity}%
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Relative EER">
              <Box color={powerToColor(data.SM_power)}>
                {data.SM_power} MeV/cm3
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <Box color={temperatureToColor(data.SM_ambienttemp)}>
                {data.SM_ambienttemp} K
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <Box color={pressureToColor(data.SM_ambientpressure)}>
                {data.SM_ambientpressure} kPa
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Gas Composition">
          <LabeledList>
            <LabeledList.Item label="Oxygen">
              {data.SM_gas_O2}%
            </LabeledList.Item>
            <LabeledList.Item label="Carbon Dioxide">
              {data.SM_gas_CO2}%
            </LabeledList.Item>
            <LabeledList.Item label="Nitrogen">
              {data.SM_gas_N2}%
            </LabeledList.Item>
            <LabeledList.Item label="Plasma">
              {data.SM_gas_PL}%
            </LabeledList.Item>
            <LabeledList.Item label="Other">
              {data.SM_gas_OTHER}%
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

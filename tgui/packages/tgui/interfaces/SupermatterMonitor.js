import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { toFixed } from 'common/math';
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

const logScale = value => Math.log2(16 + Math.max(0, value)) - 4;

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
            <LabeledList.Item label="Integrity">
              <ProgressBar
                value={data.SM_integrity / 100}
                ranges={{
                  good: [0.90, Infinity],
                  average: [0.5, 0.90],
                  bad: [-Infinity, 0.5],
                }} />
            </LabeledList.Item>
            <LabeledList.Item label="Relative EER">
              <ProgressBar
                value={data.SM_power}
                minValue={0}
                maxValue={5000}
                ranges={{
                  good: [-Infinity, 5000],
                  average: [5000, 7000],
                  bad: [7000, Infinity],
                }}>
                {toFixed(data.SM_power) + ' MeV/cm3'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <ProgressBar
                value={logScale(data.SM_ambienttemp)}
                minValue={0}
                maxValue={logScale(10000)}
                ranges={{
                  teal: [-Infinity, logScale(80)],
                  good: [logScale(80), logScale(373)],
                  average: [logScale(373), logScale(1000)],
                  bad: [logScale(1000), Infinity],
                }}>
                {toFixed(data.SM_ambienttemp) + ' K'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <ProgressBar
                value={logScale(data.SM_ambientpressure)}
                minValue={0}
                maxValue={logScale(50000)}
                ranges={{
                  good: [logScale(1), logScale(300)],
                  average: [-Infinity, logScale(1000)],
                  bad: [logScale(1000), +Infinity],
                }}>
                {toFixed(data.SM_ambientpressure) + ' kPa'}
              </ProgressBar>
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
            <LabeledList.Item label="Nitrous Oxide">
              {data.SM_gas_N2O}%
            </LabeledList.Item>
            <LabeledList.Item label="Agent B">
              {data.SM_gas_AB}%
            </LabeledList.Item>			
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

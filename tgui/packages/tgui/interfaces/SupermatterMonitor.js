import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Section, Box, Button, Stack, Table, LabeledList, ProgressBar } from '../components';
import { getGasColor, getGasLabel } from '../constants';
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

const logScale = (value) => Math.log2(16 + Math.max(0, value)) - 4;

const SupermatterMonitorListView = (props, context) => {
  const { act, data } = useBackend(context);
  const { supermatters = [] } = data;
  return (
    <Window width={450} height={185}>
      <Window.Content scrollable>
        <Section
          fill
          title="Detected Supermatters"
          buttons={<Button icon="sync" content="Refresh" onClick={() => act('refresh')} />}
        >
          <Table>
            {supermatters.map((sm) => (
              <Table.Row key={sm.supermatter_id}>
                <Table.Cell>{sm.supermatter_id + '. ' + sm.area_name}</Table.Cell>
                <Table.Cell collapsing color="label">
                  Integrity:
                </Table.Cell>
                <Table.Cell collapsing width="120px">
                  <ProgressBar
                    value={sm.integrity / 100}
                    ranges={{
                      good: [0.9, Infinity],
                      average: [0.5, 0.9],
                      bad: [-Infinity, 0.5],
                    }}
                  />
                </Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    content="Details"
                    onClick={() =>
                      act('view', {
                        view: sm.supermatter_id,
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

const SupermatterMonitorDataView = (props, context) => {
  const { act, data } = useBackend(context);
  const { active, SM_integrity, SM_power, SM_ambienttemp, SM_ambientpressure } = data;
  const gases = flow([(gases) => gases.filter((gas) => gas.amount >= 0.01), sortBy((gas) => -gas.amount)])(
    data.gases || []
  );
  const gasMaxAmount = Math.max(1, ...gases.map((gas) => gas.amount));
  return (
    <Window width={550} height={185}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="270px">
            <Section fill scrollable title="Metrics">
              <LabeledList>
                <LabeledList.Item label="Integrity">
                  <ProgressBar
                    value={SM_integrity / 100}
                    ranges={{
                      good: [0.9, Infinity],
                      average: [0.5, 0.9],
                      bad: [-Infinity, 0.5],
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Relative EER">
                  <ProgressBar
                    value={SM_power}
                    minValue={0}
                    maxValue={5000}
                    ranges={{
                      good: [-Infinity, 5000],
                      average: [5000, 7000],
                      bad: [7000, Infinity],
                    }}
                  >
                    {toFixed(SM_power) + ' MeV/cm3'}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Temperature">
                  <ProgressBar
                    value={logScale(SM_ambienttemp)}
                    minValue={0}
                    maxValue={logScale(10000)}
                    ranges={{
                      teal: [-Infinity, logScale(80)],
                      good: [logScale(80), logScale(373)],
                      average: [logScale(373), logScale(1000)],
                      bad: [logScale(1000), Infinity],
                    }}
                  >
                    {toFixed(SM_ambienttemp) + ' K'}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Pressure">
                  <ProgressBar
                    value={logScale(SM_ambientpressure)}
                    minValue={0}
                    maxValue={logScale(50000)}
                    ranges={{
                      good: [logScale(1), logScale(300)],
                      average: [-Infinity, logScale(1000)],
                      bad: [logScale(1000), Infinity],
                    }}
                  >
                    {toFixed(SM_ambientpressure) + ' kPa'}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Section
              fill
              scrollable
              title="Gases"
              buttons={<Button icon="arrow-left" content="Back" onClick={() => act('back')} />}
            >
              <LabeledList>
                {gases.map((gas) => (
                  <LabeledList.Item key={gas.name} label={getGasLabel(gas.name)}>
                    <ProgressBar color={getGasColor(gas.name)} value={gas.amount} minValue={0} maxValue={gasMaxAmount}>
                      {toFixed(gas.amount, 2) + '%'}
                    </ProgressBar>
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

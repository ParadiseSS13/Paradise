import { Button, LabeledList, ProgressBar, Section, Stack, Table } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

interface SupermatterData {
  active: number;
  supermatters?: Array<{
    supermatter_id: string;
    area_name: string;
    integrity: number;
  }>;
  SM_integrity: number;
  SM_power: number;
  SM_pre_reduction_power: number;
  SM_ambienttemp: number;
  SM_ambientpressure: number;
  SM_moles: number;
  SM_gas_coefficient: number;
  gases?: Array<{
    name: string;
    amount: number;
    portion: number;
  }>;
}

export const SupermatterMonitor = () => {
  const { act, data } = useBackend<SupermatterData>();

  if (data.active === 0) {
    return <SupermatterMonitorListView />;
  } else {
    return <SupermatterMonitorDataView />;
  }
};

const logScale = (value: number): number => Math.log2(16 + Math.max(0, value)) - 4;

const SupermatterMonitorListView = () => {
  const { act, data } = useBackend<SupermatterData>();
  const { supermatters = [] } = data;

  return (
    <Window width={450} height={250}>
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

const SupermatterMonitorDataView = () => {
  const { act, data } = useBackend<SupermatterData>();
  const {
    SM_integrity,
    SM_power,
    SM_pre_reduction_power,
    SM_ambienttemp,
    SM_ambientpressure,
    SM_moles,
    SM_gas_coefficient,
    gases = [],
  } = data;

  const filteredGases = (gases ?? []).filter((gas) => gas.amount >= 0.01).sort((a, b) => b.amount - a.amount);

  const gasMaxAmount = Math.max(1, ...filteredGases.map((gas) => gas.portion));

  return (
    <Window width={550} height={270}>
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
                <LabeledList.Item label="Peak EER">
                  <ProgressBar
                    value={SM_pre_reduction_power}
                    minValue={0}
                    maxValue={5000}
                    ranges={{
                      good: [-Infinity, 5000],
                      average: [5000, 7000],
                      bad: [7000, Infinity],
                    }}
                  >
                    {toFixed(SM_pre_reduction_power) + ' MeV/cm3'}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Nominal EER">
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
                <LabeledList.Item label="Gas Coefficient">
                  <ProgressBar
                    value={SM_gas_coefficient}
                    minValue={1}
                    maxValue={5.25}
                    ranges={{
                      bad: [1, 1.55],
                      average: [1.55, 5.25],
                      good: [5.25, Infinity],
                    }}
                  >
                    {SM_gas_coefficient.toFixed(2)}
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
                <LabeledList.Item label="Mole Per Tile">
                  <ProgressBar
                    value={SM_moles}
                    minValue={0}
                    maxValue={12000}
                    ranges={{
                      teal: [-Infinity, 100],
                      average: [100, 11333],
                      good: [11333, 12000],
                      bad: [12000, Infinity],
                    }}
                  >
                    {toFixed(SM_moles) + ' mol'}
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
                {filteredGases.map((gas) => (
                  <LabeledList.Item key={gas.name} label={getGasLabel(gas.name, gas.name)}>
                    <ProgressBar color={getGasColor(gas.name)} value={gas.portion} minValue={0} maxValue={gasMaxAmount}>
                      {toFixed(gas.amount) + ' mol (' + gas.portion + '%)'}
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

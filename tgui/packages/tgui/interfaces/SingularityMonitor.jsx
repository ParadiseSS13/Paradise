import { Button, LabeledList, ProgressBar, Section, Stack, Table } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const SingularityMonitor = (props) => {
  const { act, data } = useBackend();
  if (data.active === 0) {
    return <SingularityMonitorListView />;
  } else {
    return <SingularityMonitorDataView />;
  }
};

const logScale = (value) => Math.log2(16 + Math.max(0, value)) - 4;

const SingularityMonitorListView = (props) => {
  const { act, data } = useBackend();
  const { singularities = [] } = data;
  return (
    <Window width={450} height={185}>
      <Window.Content scrollable>
        <Section
          fill
          title="Detected Singularities"
          buttons={<Button icon="sync" content="Refresh" onClick={() => act('refresh')} />}
        >
          <Table>
            {singularities.map((singulo) => (
              <Table.Row key={singulo.singularity_id}>
                <Table.Cell>{singulo.singularity_id + '. ' + singulo.area_name}</Table.Cell>
                <Table.Cell collapsing color="label">
                  Stage:
                </Table.Cell>
                <Table.Cell collapsing width="120px">
                  <ProgressBar
                    value={singulo.stage}
                    minValue={0}
                    maxValue={6}
                    ranges={{
                      good: [1, 2],
                      average: [3, 4],
                      bad: [5, 6],
                    }}
                  >
                    {toFixed(singulo.stage)}
                  </ProgressBar>
                </Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    content="Details"
                    onClick={() =>
                      act('view', {
                        view: singulo.singularity_id,
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

const SingularityMonitorDataView = (props) => {
  const { act, data } = useBackend();
  const {
    active,
    singulo_stage,
    singulo_potential_stage,
    singulo_energy,
    singulo_high,
    singulo_low,
    generators = [],
  } = data;
  return (
    <Window width={550} height={185}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="270px">
            <Section fill scrollable title="Metrics">
              <LabeledList>
                <LabeledList.Item label="Stage">
                  <ProgressBar
                    value={singulo_stage}
                    minValue={0}
                    maxValue={6}
                    ranges={{
                      good: [1, 2],
                      average: [3, 4],
                      bad: [5, 6],
                    }}
                  >
                    {toFixed(singulo_stage)}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Potential Stage">
                  <ProgressBar
                    value={singulo_potential_stage}
                    minValue={0}
                    maxValue={6}
                    ranges={{
                      good: [1, singulo_stage + 0.5],
                      average: [singulo_stage + 0.5, singulo_stage + 1.5],
                      bad: [singulo_stage + 1.5, singulo_stage + 2],
                    }}
                  >
                    {toFixed(singulo_potential_stage)}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Energy">
                  <ProgressBar
                    value={singulo_energy}
                    minValue={singulo_low}
                    maxValue={singulo_high}
                    ranges={{
                      good: [0.67 * singulo_high + 0.33 * singulo_low, singulo_high],
                      average: [0.33 * singulo_high + 0.67 * singulo_low, 0.67 * singulo_high + 0.33 * singulo_low],
                      bad: [singulo_low, 0.33 * singulo_high + 0.67 * singulo_low],
                    }}
                  >
                    {toFixed(singulo_energy) + 'MJ'}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Section
              fill
              scrollable
              title="Field Generators"
              buttons={<Button icon="arrow-left" content="Back" onClick={() => act('back')} />}
            >
              <LabeledList>
                {generators.map((generator) => (
                  <LabeledList.Item key={generator.gen_index} label="Remaining Charge">
                    <ProgressBar
                      value={generator.charge}
                      minValue={0}
                      maxValue={125}
                      ranges={{
                        good: [80, 125],
                        average: [30, 80],
                        bad: [0, 30],
                      }}
                    >
                      {toFixed(generator.charge)}
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

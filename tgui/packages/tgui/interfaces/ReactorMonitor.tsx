import { Button, Knob, LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

interface FissionReactorData {
  active: number;
  supermatters?: Array<{
    supermatter_id: string;
    area_name: string;
    integrity: number;
  }>;
  venting: boolean;
  NGCR_integrity: number;
  NGCR_power: number;
  NGCR_ambienttemp: number;
  NGCR_ambientpressure: number;
  NGCR_coefficient: number;
  NGCR_operatingpower: number;
  NGCR_throttle: number;
  gases?: Array<{
    name: string;
    amount: number;
    portion: number;
  }>;
}

export const ReactorMonitor = (props) => {
  const logScale = (value: number): number => Math.log2(16 + Math.max(0, value)) - 4;
  const { act, data } = useBackend<FissionReactorData>();
  const {
    venting,
    NGCR_integrity,
    NGCR_power,
    NGCR_ambienttemp,
    NGCR_ambientpressure,
    NGCR_coefficient,
    NGCR_operatingpower,
    NGCR_throttle,
    gases = [],
  } = data;
  const filteredGases = (gases ?? []).filter((gas) => gas.amount >= 0.01).sort((a, b) => b.amount - a.amount);
  const gasMaxAmount = Math.max(1, ...filteredGases.map((gas) => gas.portion));
  return (
    <Window width={550} height={500}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="270px">
            <Section fill scrollable title="Metrics">
              <LabeledList>
                <LabeledList.Item label="Integrity">
                  <ProgressBar
                    value={NGCR_integrity / 100}
                    ranges={{
                      good: [0.9, Infinity],
                      average: [0.5, 0.9],
                      bad: [-Infinity, 0.5],
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Power Generation">
                  <ProgressBar
                    value={NGCR_power}
                    minValue={0}
                    maxValue={2000}
                    ranges={
                      NGCR_power <= 10000
                        ? {
                            good: [400, Infinity],
                            average: [200, 400],
                            bad: [-Infinity, 200],
                          }
                        : {
                            good: [-Infinity, Infinity],
                          }
                    }
                  >
                    {toFixed(NGCR_power < 10000 ? NGCR_power : NGCR_power / 1000) +
                      (NGCR_power < 10000 ? ' KW' : ' MW')}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Reactivity Coefficient">
                  <ProgressBar
                    value={NGCR_coefficient}
                    minValue={1}
                    maxValue={5.25}
                    ranges={{
                      bad: [1, 1.55],
                      average: [1.55, 5.25],
                      good: [5.25, Infinity],
                    }}
                  >
                    {NGCR_coefficient.toFixed(2)}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Temperature">
                  <ProgressBar
                    value={logScale(NGCR_ambienttemp)}
                    minValue={0}
                    maxValue={logScale(10000)}
                    ranges={{
                      teal: [-Infinity, logScale(80)],
                      good: [logScale(80), logScale(373)],
                      average: [logScale(373), logScale(1000)],
                      bad: [logScale(1000), Infinity],
                    }}
                  >
                    {toFixed(NGCR_ambienttemp) + ' K'}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Pressure">
                  <ProgressBar
                    value={logScale(NGCR_ambientpressure)}
                    minValue={0}
                    maxValue={logScale(50000)}
                    ranges={{
                      good: [logScale(1), logScale(1000)],
                      average: [-Infinity, logScale(3000)],
                      bad: [logScale(3000), Infinity],
                    }}
                  >
                    {toFixed(NGCR_ambientpressure) + ' kPa'}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Control Rod Limiter">
                  <ProgressBar
                    value={NGCR_operatingpower}
                    minValue={0}
                    maxValue={100}
                    ranges={{
                      teal: [100, Infinity],
                      good: [70, 99],
                      average: [30, 70],
                      bad: [-Infinity, 30],
                    }}
                  >
                    {toFixed(NGCR_operatingpower) + ' %'}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
              <Section title="Desired Control Rod Limit" textAlign="center">
                <Knob
                  size={5}
                  value={NGCR_throttle}
                  unit="%"
                  minValue={0}
                  maxValue={100}
                  step={1}
                  stepPixelSize={2}
                  onChange={(e, value) =>
                    act('set_throttle', {
                      NGCR_throttle: value,
                    })
                  }
                />
              </Section>
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Stack fill vertical>
              <Stack.Item grow>
                <Section
                  fill
                  scrollable
                  title="Gases"
                  buttons={
                    <Button
                      icon={'power-off'}
                      content={venting ? 'Vent Open' : 'Vent Closed'}
                      selected={venting}
                      onClick={() => act('toggle_vent')}
                    />
                  }
                >
                  <LabeledList>
                    {filteredGases.map((gas) => (
                      <LabeledList.Item key={gas.name} label={getGasLabel(gas.name, gas.name)}>
                        <ProgressBar
                          color={getGasColor(gas.name)}
                          value={gas.portion}
                          minValue={0}
                          maxValue={gasMaxAmount}
                        >
                          {toFixed(gas.amount) + ' mol (' + gas.portion + '%)'}
                        </ProgressBar>
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

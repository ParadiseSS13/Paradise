import {
  Button,
  Knob,
  LabeledControls,
  LabeledList,
  ProgressBar,
  RoundGauge,
  Section,
  Stack,
} from 'tgui-core/components';
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
  NGCR_overheat_level: number;
  NGCR_overpressure_level: number;
  NGCR_mols_created: number;
  NGCR_instability_level: number;
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
    NGCR_overheat_level,
    NGCR_overpressure_level,
    NGCR_mols_created,
    NGCR_instability_level,
    gases = [],
  } = data;
  const filteredGases = (gases ?? []).filter((gas) => gas.amount >= 0.01).sort((a, b) => b.amount - a.amount);
  const gasMaxAmount = Math.max(1, ...filteredGases.map((gas) => gas.portion));
  return (
    <Window width={600} height={600}>
      <Window.Content>
        <Stack height="30%">
          <Stack.Item width="300px" minHeight="140px">
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
        <Section title="Core Statistics" height="30%" align="center" verticalAlign="end">
          <LabeledControls>
            <LabeledControls.Item label="Instability">
              <RoundGauge
                size={4}
                position="bottom"
                value={NGCR_instability_level}
                minValue={0.5}
                maxValue={3}
                ranges={{
                  good: [0.5, 1.5],
                  average: [1.5, 2],
                  bad: [2, 3],
                }}
                format={(v) => `${Math.round(v)}x`}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Core Temperature">
              <RoundGauge
                size={4}
                value={NGCR_ambienttemp}
                minValue={0}
                maxValue={NGCR_overheat_level * 1.2}
                alertAfter={NGCR_overheat_level}
                ranges={{
                  good: [0, NGCR_overheat_level * 0.7],
                  average: [NGCR_overheat_level * 0.7, NGCR_overheat_level],
                  bad: [NGCR_overheat_level, NGCR_overheat_level * 1.2],
                }}
                format={(v) => `${Math.round(v)} K`}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Core Pressure">
              <RoundGauge
                size={4}
                value={NGCR_ambientpressure}
                minValue={0}
                maxValue={NGCR_overpressure_level * 1.2}
                alertAfter={NGCR_overpressure_level}
                ranges={{
                  good: [0, NGCR_overpressure_level * 0.7],
                  average: [NGCR_overpressure_level * 0.7, NGCR_overpressure_level],
                  bad: [NGCR_overpressure_level, NGCR_overpressure_level * 1.2],
                }}
                format={(v) => `${Math.round(v)} KPA`}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Gas Production">
              <RoundGauge
                size={4}
                value={NGCR_mols_created}
                minValue={0}
                maxValue={50}
                ranges={{
                  good: [0, 25],
                  average: [25, 40],
                  bad: [40, 50],
                }}
                format={(v) => `${Math.round(v)} Mols`}
              />
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Section title="Control Panel" textAlign="center">
          <LabeledControls textAlign="center">
            <LabeledControls.Item label="Control Rod Position">
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
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};

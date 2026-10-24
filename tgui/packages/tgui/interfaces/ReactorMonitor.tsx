import {
  Button,
  Chart,
  Flex,
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
const PEAK_GEN = 1000;

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
  NGCR_heat_minimum: number;
  NGCR_coolant_degrade_mod: number;
  NGCR_coolant_mod: number;
  NGCR_moderator_degrade_mod: number;
  NGCR_moderator_mod: number;
  NGCR_history: DataHistory;
  NGCR_scrub_o2: boolean;
  NGCR_scrub_n2: boolean;
  NGCR_scrub_co2: boolean;
  NGCR_scrub_toxins: boolean;
  NGCR_scrub_n2o: boolean;
  NGCR_scrub_h2: boolean;
  NGCR_scrub_h2o: boolean;
  gases?: Array<{
    name: string;
    amount: number;
    portion: number;
  }>;
}

type DataHistory = {
  generation: number[];
};
function roundToDecimal(num: number, decimalPlaces: number): number {
  const factor = Math.pow(10, decimalPlaces);
  return Math.round(num * factor) / factor;
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
    NGCR_heat_minimum,
    NGCR_coolant_degrade_mod,
    NGCR_coolant_mod,
    NGCR_moderator_degrade_mod,
    NGCR_moderator_mod,
    NGCR_scrub_o2,
    NGCR_scrub_n2,
    NGCR_scrub_co2,
    NGCR_scrub_toxins,
    NGCR_scrub_n2o,
    NGCR_scrub_h2,
    NGCR_scrub_h2o,
    gases = [],
  } = data;
  const { NGCR_history } = data;
  const filteredGases = (gases ?? []).filter((gas) => gas.amount >= 0.01).sort((a, b) => b.amount - a.amount);
  const gasMaxAmount = Math.max(1, ...filteredGases.map((gas) => gas.portion));
  const generation = NGCR_history.generation[NGCR_history.generation.length - 1] || 0;
  const powerData = NGCR_history.generation.map((value, i) => [i, value]);
  const maxValue = Math.max(PEAK_GEN, ...NGCR_history.generation);
  return (
    <Window width={725} height={875}>
      <Window.Content>
        <Stack height="200px">
          <Stack.Item width="50%" minHeight="140px" minWidth="200px">
            <Section fill scrollable title="Power Metrics">
              <ProgressBar
                value={NGCR_power}
                minValue={0}
                maxValue={2000}
                ranges={
                  NGCR_power <= 10000
                    ? {
                        blue: [1000, Infinity],
                        good: [400, 1000],
                        average: [200, 400],
                        bad: [-Infinity, 200],
                      }
                    : {
                        good: [-Infinity, Infinity],
                      }
                }
              >
                {toFixed(NGCR_power < 10000 ? NGCR_power : NGCR_power / 1000) + (NGCR_power < 10000 ? ' KW' : ' MW')}
              </ProgressBar>
              <Chart.Line
                fillPositionedParent
                data={powerData}
                rangeX={[0, powerData.length - 1]}
                rangeY={[0, maxValue]}
                strokeColor="rgba(32, 177, 66, 1)"
                fillColor="rgba(32, 177, 66, 0.25)"
              />
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
                      tooltip="CAUTION: Opens the emergency external-facing vent."
                      content={venting ? 'Emergency Vent Open' : 'Emergency Vent Closed'}
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
        <Section />
        <Section title="Core Statistics" align="center" flexGrow>
          <Flex justify="space-around" grow fill>
            <Flex.Item minWidth="120px" width="30%">
              <LabeledControls wrap justify="space-around">
                <LabeledControls.Item label="Instability" align-self>
                  <RoundGauge
                    size={2}
                    value={NGCR_instability_level}
                    minValue={0.5}
                    maxValue={3}
                    ranges={{
                      good: [0.5, 1.5],
                      average: [1.5, 2],
                      bad: [2, 3],
                    }}
                    format={(v) => `${roundToDecimal(v, 2)}x`}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item label="Rod Limiter" align-self>
                  <RoundGauge
                    size={2}
                    value={NGCR_operatingpower}
                    minValue={0}
                    maxValue={100}
                    ranges={{
                      average: [80, 100],
                      good: [10, 80],
                      blue: [0, 10],
                    }}
                    format={(v) => `${Math.round(v)}%`}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item label="Temp Min." align-self>
                  <RoundGauge
                    size={2}
                    value={NGCR_heat_minimum}
                    minValue={0}
                    maxValue={1000}
                    ranges={{
                      good: [0, 100],
                      average: [100, 400],
                      bad: [400, 1000],
                    }}
                    format={(v) => `${Math.round(v)} K`}
                  />
                </LabeledControls.Item>
              </LabeledControls>
            </Flex.Item>
            <Flex.Item flexGrow minWidth="140px" align="center" width="40%">
              <LabeledControls wrap justify="space-around">
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
                <LabeledControls.Item label="Core Integrity">
                  <RoundGauge
                    size={4}
                    value={NGCR_integrity}
                    minValue={0}
                    maxValue={100}
                    alertBefore={90}
                    ranges={{
                      good: [90, 100],
                      average: [40, 90],
                      bad: [0, 40],
                    }}
                    format={(v) => `${Math.round(v)}%`}
                  />
                </LabeledControls.Item>
              </LabeledControls>
            </Flex.Item>
            <Flex.Item minWidth="120px" width="30%">
              <LabeledControls wrap justify="space-around">
                <LabeledControls.Item label="Pressure">
                  <RoundGauge
                    size={2}
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
                <LabeledControls.Item label="Reactivity" align-self>
                  <RoundGauge
                    size={2}
                    value={NGCR_coefficient}
                    minValue={0}
                    maxValue={30}
                    ranges={{
                      good: [0, 5],
                      blue: [5, 20],
                      purple: [20, 30],
                    }}
                    format={(v) => `${roundToDecimal(v, 2)}x`}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item label="Waste" align-self>
                  <RoundGauge
                    size={2}
                    value={NGCR_mols_created}
                    minValue={0}
                    maxValue={50}
                    ranges={{
                      good: [0, 25],
                      blue: [25, 40],
                      purple: [40, 50],
                    }}
                    format={(v) => `${roundToDecimal(v, 2)} mols`}
                  />
                </LabeledControls.Item>
              </LabeledControls>
            </Flex.Item>
          </Flex>
        </Section>
        <Section title="Rod Statistics" align="center" flexGrow>
          <Flex justify="space-around" grow fill>
            <Flex.Item minWidth="120px" width="100%">
              <LabeledControls wrap justify="space-around">
                <LabeledControls.Item label="Coolant Degredation" align-self>
                  <RoundGauge
                    size={3}
                    value={NGCR_coolant_degrade_mod}
                    minValue={0}
                    maxValue={3}
                    ranges={{
                      blue: [0, 0.5],
                      good: [0.5, 1.3],
                      average: [1.3, 2],
                      bad: [2, 3],
                    }}
                    format={(v) => `${roundToDecimal(v, 2)}x`}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item label="Coolant Efficiency" align-self>
                  <RoundGauge
                    size={3}
                    value={NGCR_coolant_mod}
                    minValue={0}
                    maxValue={3}
                    ranges={{
                      purple: [2.3, 3],
                      blue: [1.3, 2.3],
                      good: [0.9, 1.3],
                      average: [0.6, 0.9],
                      bad: [0, 0.6],
                    }}
                    format={(v) => `${roundToDecimal(v, 2)}x`}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item label="Moderator Degredation" align-self>
                  <RoundGauge
                    size={3}
                    value={NGCR_moderator_degrade_mod}
                    minValue={0}
                    maxValue={3}
                    ranges={{
                      blue: [0, 0.5],
                      good: [0.5, 1.3],
                      average: [1.3, 2],
                      bad: [2, 3],
                    }}
                    format={(v) => `${roundToDecimal(v, 2)}x`}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item label="Moderator Efficiency" align-self>
                  <RoundGauge
                    size={3}
                    value={NGCR_moderator_mod}
                    minValue={0}
                    maxValue={3}
                    ranges={{
                      purple: [2.3, 3],
                      blue: [1.3, 2.3],
                      good: [0.9, 1.3],
                      average: [0.6, 0.9],
                      bad: [0, 0.6],
                    }}
                    format={(v) => `${roundToDecimal(v, 2)}x`}
                  />
                </LabeledControls.Item>
              </LabeledControls>
            </Flex.Item>
          </Flex>
        </Section>
        <Section title="Gas Filters" textAlign="center">
          <Button selected={NGCR_scrub_o2} content="O2" onClick={() => act('toggle_o2')} />
          <Button selected={NGCR_scrub_n2} content="N2" onClick={() => act('toggle_n2')} />
          <Button selected={NGCR_scrub_co2} content="CO2" onClick={() => act('toggle_co2')} />
          <Button selected={NGCR_scrub_toxins} content="Plasma" onClick={() => act('toggle_toxins')} />
          <Button selected={NGCR_scrub_n2o} content="N2O" onClick={() => act('toggle_n2o')} />
          <Button selected={NGCR_scrub_h2} content="H2" onClick={() => act('toggle_h2')} />
          <Button selected={NGCR_scrub_h2o} content="H2O" onClick={() => act('toggle_h2o')} />
        </Section>
        <Section title="Control Panel" textAlign="center">
          <LabeledControls textAlign="center" justify="space-around">
            <Button
              icon={'angle-double-left'}
              iconSize={4}
              verticalAlignContent="middle"
              color="transparent"
              onClick={() =>
                act('set_throttle', {
                  NGCR_throttle: 0,
                })
              }
            />
            <Button
              icon={'angle-left'}
              iconSize={4}
              verticalAlignContent="middle"
              color="transparent"
              onClick={() =>
                act('set_throttle', {
                  NGCR_throttle: NGCR_throttle - 1,
                })
              }
            />
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
            <Button
              icon={'angle-right'}
              iconSize={4}
              verticalAlignContent="middle"
              color="transparent"
              onClick={() =>
                act('set_throttle', {
                  NGCR_throttle: NGCR_throttle + 1,
                })
              }
            />
            <Button
              icon={'angle-double-right'}
              iconSize={4}
              verticalAlignContent="middle"
              color="transparent"
              onClick={() =>
                act('set_throttle', {
                  NGCR_throttle: 100,
                })
              }
            />
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};

import { Box, Button, Flex, LabeledList, NumberInput, ProgressBar, Section } from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Grid } from '../components';
import { Window } from '../layouts';

export const Pacman = (props) => {
  const { act, data } = useBackend();
  const {
    active,
    anchored,
    broken,
    emagged,
    fuel_type,
    fuel_usage,
    fuel_stored, // current fuel level
    fuel_cap, // fuel_capacity
    is_ai,
    tmp_current, // temperature_current
    tmp_max, // temperature_max
    tmp_overheat, // temperature_overheat
    output_max,
    power_gen,
    output_set,
    has_fuel,
  } = data;
  let fuelRatio = fuel_stored / fuel_cap;
  let tmpRatio = tmp_current / tmp_max; // temperature ratio
  let output_watts = output_set * power_gen;
  let fuel_sec = Math.round((fuel_stored / fuel_usage) * 2); // Multiply by two, because one cycle is two seconds.
  let fuel_min = Math.round(fuel_sec / 60);
  let usage = fuel_sec > 120 ? `${fuel_min} minutes` : `${fuel_sec} seconds`;
  return (
    <Window width={500} height={225}>
      <Window.Content>
        {(broken || !anchored) && (
          <Section title="Status">
            {!!broken && <Box color="orange">The generator is malfunctioning!</Box>}
            {!broken && !anchored && (
              <Box color="orange">The generator needs to be anchored to the floor with a wrench.</Box>
            )}
          </Section>
        )}
        {!broken && !!anchored && (
          <div>
            <Section
              title="Status"
              buttons={
                <Button
                  icon={active ? 'power-off' : 'times'}
                  content={active ? 'On' : 'Off'}
                  tooltip="Toggles the generator on/off. Requires fuel."
                  tooltipPosition="left"
                  disabled={!has_fuel}
                  selected={active}
                  onClick={() => act('toggle_power')}
                />
              }
            >
              <Flex direction="row">
                <Flex.Item width="50%" className="ml-1">
                  <LabeledList>
                    <LabeledList.Item label="Power setting">
                      <NumberInput
                        value={output_set}
                        minValue={1}
                        maxValue={output_max * (emagged ? 2.5 : 1)}
                        step={1}
                        className="mt-1"
                        onChange={(value) =>
                          act('change_power', {
                            change_power: value,
                          })
                        }
                      />
                      ({formatPower(output_watts)})
                    </LabeledList.Item>
                  </LabeledList>
                </Flex.Item>
                <Flex.Item width="50%">
                  <LabeledList>
                    <LabeledList.Item label="Temperature">
                      <ProgressBar
                        value={tmpRatio}
                        ranges={{
                          green: [-Infinity, 0.33],
                          orange: [0.33, 0.66],
                          red: [0.66, Infinity],
                        }}
                      >
                        {tmp_current} &#8451;
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Status">
                      {tmp_overheat > 50 && <Box color="red">CRITICAL OVERHEAT!</Box>}
                      {tmp_overheat > 20 && tmp_overheat <= 50 && <Box color="orange">WARNING: Overheating!</Box>}
                      {tmp_overheat > 1 && tmp_overheat <= 20 && <Box color="orange">Temperature High</Box>}
                      {tmp_overheat === 0 && <Box color="green">Optimal</Box>}
                    </LabeledList.Item>
                  </LabeledList>
                </Flex.Item>
              </Flex>
            </Section>
            <Section
              title="Fuel"
              buttons={
                <Button
                  icon="eject"
                  content="Eject Fuel"
                  tooltip="Ejects fuel. Generator needs to be offline."
                  tooltipPosition="left"
                  disabled={active || is_ai || !has_fuel}
                  onClick={() => act('eject_fuel')}
                />
              }
            >
              <Grid>
                <Grid.Column>
                  <LabeledList>
                    <LabeledList.Item label="Type">{fuel_type}</LabeledList.Item>
                    <LabeledList.Item label="Fuel level">
                      <ProgressBar
                        value={fuelRatio}
                        ranges={{
                          red: [-Infinity, 0.33],
                          orange: [0.33, 0.66],
                          green: [0.66, Infinity],
                        }}
                      >
                        {Math.round(fuel_stored / 1000)} dm&sup3;
                      </ProgressBar>
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
                <Grid.Column>
                  <LabeledList>
                    <LabeledList.Item label="Fuel usage">{fuel_usage / 1000} dm&sup3;/s</LabeledList.Item>
                    <LabeledList.Item label="Fuel depletion">
                      {!!has_fuel && (fuel_usage ? usage : 'N/A')}
                      {!has_fuel && <Box color="red">Out of fuel</Box>}
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
              </Grid>
            </Section>
          </div>
        )}
      </Window.Content>
    </Window>
  );
};

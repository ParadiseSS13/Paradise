import { AnimatedNumber, Box, LabeledList, NumberInput, Section } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { round } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const TempGun = (props) => {
  const { act, data } = useBackend();
  const { target_temperature, temperature, max_temp, min_temp } = data;

  return (
    <Window width={250} height={121}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Target Temperature">
              <NumberInput
                animate
                step={10}
                stepPixelSize={6}
                minValue={min_temp}
                maxValue={max_temp}
                value={target_temperature}
                format={(value) => toFixed(value, 2)}
                width="50px"
                onChange={(value) =>
                  act('target_temperature', {
                    target_temperature: value,
                  })
                }
              />
              &deg;C
            </LabeledList.Item>
            <LabeledList.Item label="Current Temperature">
              <Box color={Temp2Color(temperature)} bold={temperature > 500 - 273.15}>
                <AnimatedNumber value={round(temperature, 2)} />
                &deg;C
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Power Cost">
              <Box color={Temp2CostColor(temperature)}>{Temp2Cost(temperature)}</Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

const Temp2Color = (temp) => {
  if (temp <= -100) {
    return 'blue';
  }
  if (temp <= 0) {
    return 'teal';
  }
  if (temp <= 100) {
    return 'green';
  }
  if (temp <= 200) {
    return 'orange';
  }
  return 'red';
};

// These temps are the same as the ones in switch(temperature) for the gun, just - 273.15 for conversion between kelvin and celcius
const Temp2Cost = (temp) => {
  if (temp <= 100 - 273.15) {
    return 'High';
  }
  if (temp <= 250 - 273.15) {
    return 'Medium';
  }
  if (temp <= 300 - 273.15) {
    return 'Low';
  }
  if (temp <= 400 - 273.15) {
    return 'Medium';
  }
  return 'High';
};

const Temp2CostColor = (temp) => {
  if (temp <= 100 - 273.15) {
    return 'red';
  }
  if (temp <= 250 - 273.15) {
    return 'orange';
  }
  if (temp <= 300 - 273.15) {
    return 'green';
  }
  if (temp <= 400 - 273.15) {
    return 'orange';
  }
  return 'red';
};

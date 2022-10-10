import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { LabeledList, NumberInput, Section, AnimatedNumber, Box } from '../components';
import { Window } from '../layouts';
import { round } from 'common/math';

export const TempGun = (props, context) => {
  const { act, data } = useBackend(context);

  const {target_temperature, temperature, max_temp, min_temp, power_cost} = data;

  return (
    <Window>
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
            onDrag={(e, value) =>
              act('target_temperature', {
                target_temperature: value,
              })
            }
          />&deg;C
        </LabeledList.Item>
        <LabeledList.Item
        label="Current Temperature">
        <Box color={Temp2Color(temperature)}
            bold={temperature > 500-273.15}>
            <AnimatedNumber value={(round(temperature, 2))}/>&deg;C
        </Box>
        </LabeledList.Item>
        <LabeledList.Item
        label="Power Cost">
        <Box color={Cost2Color(power_cost)}>
            {power_cost}
        </Box>
        </LabeledList.Item>
        </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
}

const Temp2Color = (temp) => {
  if (temp >= 200) {
    return 'red';
  }
  if (temp >= 100) {
    return 'orange';
  }
  if (temp >= 0) {
    return 'green';
  }
  if (temp >= -100) {
    return 'teal';
  }
  return 'blue';
};

const Cost2Color = (cost) => {
  if (cost === 'High') {
    return 'red';
  }
  if (cost === 'Medium') {
    return 'orange';
  }
  return 'green';
};

import { useBackend } from '../backend';
import { Box, Section, ProgressBar, Button, LabeledList, NumberInput, Flex } from '../components';
import { Window } from '../layouts';

export const GasFreezer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on,
    pressure,
    temperature,
    temperatureCelsius,
    min,
    max,
    target,
    targetCelsius,
  } = data;
  const ratio = (temperature - min) / (max - min);
  return (
    <Window>
      <Window.Content>
        <Section title="Status" buttons={(
          <Button
            icon={on ? 'power-off' : 'times'}
            content={on ? 'On' : 'Off'}
            selected={on}
            onClick={() => act('power')} />
        )}>
          <LabeledList>
            <LabeledList.Item label="Pressure">
              {pressure} kpA
            </LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <Flex direction="row" justify="space-between">
                <Flex.Item width="70%">
                  <ProgressBar
                    value={ratio}
                    ranges={{
                      blue: [-Infinity, 0.5],
                      red: [0.5, Infinity],
                    }}>
                    &nbsp;
                  </ProgressBar>
                </Flex.Item>
                <Flex.Item width="30%">
                  {ratio < 0.5 && (
                    <Box inline color="blue" ml={1}>
                      {temperature} K ({temperatureCelsius}&deg;C)
                    </Box>
                  )}
                  {ratio >= 0.5 && (
                    <Box inline color="red" ml={1}>
                      {temperature} K ({temperatureCelsius}&deg;C)
                    </Box>
                  )}
                </Flex.Item>
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="Target temperature">
              <Flex direction="row">
                <Flex.Item width="70%" justify="end">
                  <ProgressBar value={(target - min) / (max - min)}>
                    &nbsp;
                  </ProgressBar>
                </Flex.Item>
                <Flex.Item width="30%">
                  <Box inline ml={1}>{target} K ({targetCelsius}&deg;C)</Box>
                </Flex.Item>
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="Set target temperature">
              <Button
                icon="fast-backward"
                title="Minimum temperature"
                onClick={() => act('temp', {
                  temp: min,
                })} />
              <NumberInput
                value={Math.round(target)}
                unit="K"
                minValue={Math.round(min)}
                maxValue={Math.round(max)}
                step={5}
                stepPixelSize={3}
                onDrag={(e, value) => act('temp', {
                  temp: value,
                })} />
              <Button
                icon="fast-forward"
                title="Maximum Temperature"
                onClick={() => act('temp', {
                  temp: max,
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

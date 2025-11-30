import { Button, LabeledList, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const AtmosTemperatureGate = (props) => {
  const { act, data } = useBackend();
  const { on, temperature, max_temp, temp_unit, step, inverted } = data;

  return (
    <Window width={330} height={130}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={on ? 'power-off' : 'power-off'}
                content={on ? 'On' : 'Off'}
                color={on ? null : 'red'}
                selected={on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Inverted">
              <Button
                icon={inverted ? 'arrow-up' : 'arrow-down'}
                content={inverted ? 'Yes' : 'No'}
                color={inverted ? null : 'red'}
                selected={inverted}
                onClick={() => act('inverted')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <Button
                icon="fast-backward"
                textAlign="center"
                disabled={temperature === 0}
                width={2.2}
                onClick={() => act('min_temp')}
              />
              <NumberInput
                animated
                unit={temp_unit}
                width={6.1}
                lineHeight={1.5}
                step={step}
                minValue={0}
                maxValue={max_temp}
                value={temperature}
                onChange={(value) =>
                  act('custom_temperature', {
                    temperature: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                textAlign="center"
                disabled={temperature === max_temp}
                width={2.2}
                onClick={() => act('max_temp')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

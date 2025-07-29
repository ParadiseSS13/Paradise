import { Button, LabeledList, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const AtmosPump = (props) => {
  const { act, data } = useBackend();
  const { on, rate, max_rate, gas_unit, step } = data;

  return (
    <Window width={330} height={110}>
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
            <LabeledList.Item label="Rate">
              <Button
                icon="fast-backward"
                textAlign="center"
                disabled={rate === 0}
                width={2.2}
                onClick={() => act('min_rate')}
              />
              <NumberInput
                animated
                unit={gas_unit}
                width={6.1}
                lineHeight={1.5}
                step={step}
                minValue={0}
                maxValue={max_rate}
                value={rate}
                onChange={(value) =>
                  act('custom_rate', {
                    rate: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                textAlign="center"
                disabled={rate === max_rate}
                width={2.2}
                onClick={() => act('max_rate')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

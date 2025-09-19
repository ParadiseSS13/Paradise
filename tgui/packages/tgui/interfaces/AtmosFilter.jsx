import { Button, LabeledList, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const AtmosFilter = (props) => {
  const { act, data } = useBackend();
  const { on, pressure, max_pressure, filter_type, filter_type_list } = data;

  return (
    <Window width={380} height={140}>
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
                disabled={pressure === 0}
                width={2.2}
                onClick={() => act('min_pressure')}
              />
              <NumberInput
                animated
                unit="kPa"
                width={6.1}
                lineHeight={1.5}
                step={10}
                minValue={0}
                maxValue={max_pressure}
                value={pressure}
                tickWhileDragging
                onChange={(value) =>
                  act('custom_pressure', {
                    pressure: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                textAlign="center"
                disabled={pressure === max_pressure}
                width={2.2}
                onClick={() => act('max_pressure')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Filter">
              {filter_type_list.map((filter) => (
                <Button
                  key={filter.label}
                  selected={filter.gas_type === filter_type}
                  content={filter.label}
                  onClick={() =>
                    act('set_filter', {
                      filter: filter.gas_type,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

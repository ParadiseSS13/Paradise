import { Button, LabeledList, NumberInput } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../../backend';

export const pai_radio = (props) => {
  const { act, data } = useBackend();

  const { minFrequency, maxFrequency, frequency, broadcasting } = data.app_data;

  return (
    <LabeledList>
      <LabeledList.Item label="Frequency">
        <NumberInput
          animate
          step={0.2}
          stepPixelSize={6}
          minValue={minFrequency / 10}
          maxValue={maxFrequency / 10}
          value={frequency / 10}
          format={(value) => toFixed(value, 1)}
          onChange={(value) =>
            act('freq', {
              freq: value,
            })
          }
        />
        <Button tooltip="Reset" icon="undo" onClick={() => act('freq', { freq: '145.9' })} />
      </LabeledList.Item>
      <LabeledList.Item label="Broadcast Nearby Speech">
        <Button
          onClick={() => act('toggleBroadcast')}
          selected={broadcasting}
          content={broadcasting ? 'Enabled' : 'Disabled'}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

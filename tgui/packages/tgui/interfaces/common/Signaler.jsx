import { Button, LabeledList, NumberInput, Section } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../../backend';

export const Signaler = (props) => {
  const { act } = useBackend();
  const { code, frequency, minFrequency, maxFrequency } = props.data;
  return (
    <Section>
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
            width="80px"
            onChange={(value) =>
              act('freq', {
                freq: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Code">
          <NumberInput
            animate
            step={1}
            stepPixelSize={6}
            minValue={1}
            maxValue={100}
            value={code}
            width="80px"
            onChange={(value) =>
              act('code', {
                code: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
      <Button mt={1} fluid icon="arrow-up" content="Send Signal" textAlign="center" onClick={() => act('signal')} />
    </Section>
  );
};

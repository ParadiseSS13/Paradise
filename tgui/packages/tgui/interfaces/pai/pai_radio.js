import { useBackend } from "../../backend";
import { toFixed } from 'common/math';
import { LabeledList, NumberInput, Button } from "../../components";

export const pai_radio = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    minFrequency,
    maxFrequency,
    frequency,
    broadcasting,
  } = data.app_data;

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
          format={value => toFixed(value, 1)}
          onChange={(e, value) => act('freq', {
            freq: value,
          })} />
        <Button
          tooltip="Reset"
          icon="undo"
          onClick={() => act('freq', { freq: "145.9" })}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Broadcast Nearby Speech">
        <Button
          onClick={() => act('toggleBroadcast')}
          selected={broadcasting}
          content={broadcasting ? "Enabled" : "Disabled"}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

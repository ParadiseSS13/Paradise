import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, ProgressBar, Section, Tooltip } from '../components';
import { Window } from '../layouts';

export const Tank = (props, context) => {
  const { act, data } = useBackend(context);
  let maskStatus;
  if (!data.has_mask) {
    maskStatus = (
      <LabeledList.Item label="Mask" color="red">
        No Mask Equipped
      </LabeledList.Item>
    );
  } else {
    maskStatus = (
      <LabeledList.Item label="Mask">
        <Button
          icon={data.connected ? "check" : "times"}
          content={data.connected ? "Internals On" : "Internals Off"}
          selected={data.connected}
          onClick={() => act("internals")} />
      </LabeledList.Item>
    );
  }
  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Tank Pressure">
              <ProgressBar
                value={data.tankPressure / 1013}
                ranges={{
                  good: [0.35, Infinity],
                  average: [0.15, 0.35],
                  bad: [-Infinity, 0.15],
                }}>
                {data.tankPressure + ' kPa'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Release Pressure">
              <Button
                icon="fast-backward"
                disabled={data.ReleasePressure === data.minReleasePressure}
                tooltip="Min"
                onClick={() => act('pressure', {
                  pressure: 'min',
                })} />
              <NumberInput
                animated
                value={parseFloat(data.releasePressure)}
                width="65px"
                unit="kPa"
                minValue={data.minReleasePressure}
                maxValue={data.maxReleasePressure}
                onChange={(e, value) => act('pressure', {
                  pressure: value,
                })} />
              <Button
                icon="fast-forward"
                disabled={data.ReleasePressure === data.maxReleasePressure}
                tooltip="Max"
                onClick={() => act('pressure', {
                  pressure: 'max',
                })} />
              <Button
                icon="undo"
                content=""
                disabled={data.ReleasePressure === data.defaultReleasePressure}
                tooltip="Reset"
                onClick={() => act('pressure', {
                  pressure: 'reset',
                })} />
            </LabeledList.Item>
            {maskStatus}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

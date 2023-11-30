import { useBackend } from '../backend';
import { Button, Flex, Slider, Section, LabeledList } from '../components';
import { Window } from '../layouts';

export const SpaceHeater = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content>
        <Section title="Set Temperature">
          <LabeledList.Item label="Temperature">
            <Slider
              animated
              unit="°C"
              width={17.3}
              minValue={0}
              maxValue={90}
              value={data.Temp}
              onChange={(e, value) =>
                act('change_temp', {
                  change_temp: value,
                })
              }
            />
          </LabeledList.Item>
        </Section>
        <Section title="Power Settings">
          <LabeledList.Item label="Power">
            <Button
              icon={data.on ? 'power-off' : 'power-off'}
              content={data.on ? 'On' : 'Off'}
              color={data.on ? null : 'red'}
              selected={data.on}
              onClick={() => act('toggle_power')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Cell">
            <GetCellButtons />
          </LabeledList.Item>
          <LabeledList.Item label="Cell Charge">
            {data.CellPercent}%
          </LabeledList.Item>
        </Section>
      </Window.Content>
    </Window>
  );
};

const GetCellButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { Powercell, open } = data;
  if (Powercell) {
    return (
      <Button
        mt={0.5}
        mb={1}
        disabled={!open}
        content="Uninstall Cell"
        onClick={() => act('remove_cell')}
      />
    );
  } else {
    return (
      <Button
        mt={0.5}
        mb={1}
        disabled={!open}
        content="Install Cell"
        onClick={() => act('add_cell')}
      />
    );
  }
};

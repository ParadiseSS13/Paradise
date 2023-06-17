import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const ParticleAccelerator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    assembled,
    power,
    strength,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Section title="Control Panel"
          buttons={(
            <Button
              icon={"sync"}
              content={"Connect"}
              onClick={() => act('scan')} />
            )}>
          <LabeledList>
            <LabeledList.Item label="Status" mb="5px">
              <Box color={assembled ? "good" : "bad"}>
                {assembled
                  ? "Operational"
                  : "Error: Verify Configuration"}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <Button
                icon={power ? 'power-off' : 'times'}
                content={power ? 'On' : 'Off'}
                selected={power}
                disabled={!assembled}
                onClick={() => act('power')} />
            </LabeledList.Item>
            <LabeledList.Item label="Strength">
              <Button
                icon="backward"
                disabled={!assembled}
                onClick={() => act('remove_strength')} />
              {' '}
              {String(strength).padStart(1, '0')}
              {' '}
              <Button
                icon="forward"
                disabled={!assembled}
                onClick={() => act('add_strength')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

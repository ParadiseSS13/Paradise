import { useBackend } from '../backend';
import { Box, Button, Grid, LabeledList, Section, Stack, Grid } from '../components';
import { GridColumn } from '../components/Grid';
import { Window } from '../layouts';

export const ParticleAccelerator = (props, context) => {
  const { act, data } = useBackend(context);
  const { assembled, power, strength, max_strength, problem_parts, orientation } = data;
  return (
    <Window width={350} height={160}>
      <Window.Content scrollable>
        <Section
          title="Control Panel"
          buttons={<Button icon={'sync'} content={'Connect'} onClick={() => act('scan')} />}
        >
          <LabeledList>
            <LabeledList.Item label="Status" mb="5px">
              <Box color={assembled ? 'good' : 'bad'}>{assembled ? 'Operational' : 'Error: Verify Configuration'}</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <Button
                icon={power ? 'power-off' : 'times'}
                content={power ? 'On' : 'Off'}
                selected={power}
                disabled={!assembled}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Strength">
              <Button
                icon="backward"
                disabled={!assembled || strength === 0}
                onClick={() => act('remove_strength')}
                mr="4px"
              />
              {strength}
              <Button
                icon="forward"
                disabled={!assembled || strength === max_strength}
                onClick={() => act('add_strength')}
                ml="4px"
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={orientation ? 'Chamber Orientation: ' + orientation : 'No Fuel Chamber Detected'} />
        <Grid>
          <GridColumn>
            {problem_parts
              .slice()
              .sort((a, b) => a.name.localeCompare(b.name))
              .map((item) => {
                return (
                  <Stack key={item}>
                    <Stack.Item>{item.name + ': ' + item.issue}</Stack.Item>
                  </Stack>
                );
              })}
          </GridColumn>
          <GridColumn>
            {problem_parts
              .slice()
              .sort((a, b) => a.name.localeCompare(b.name))
              .map((item) => {
                return (
                  <Stack key={item}>
                    <Stack.Item>{item.name + ': ' + item.issue}</Stack.Item>
                  </Stack>
                );
              })}
          </GridColumn>
          <GridColumn>
            {problem_parts
              .slice()
              .sort((a, b) => a.name.localeCompare(b.name))
              .map((item) => {
                return (
                  <Stack key={item}>
                    <Stack.Item>{item.name + ': ' + item.issue}</Stack.Item>
                  </Stack>
                );
              })}
          </GridColumn>
        </Grid>
      </Window.Content>
    </Window>
  );
};

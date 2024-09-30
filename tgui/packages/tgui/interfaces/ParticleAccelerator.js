import { useBackend } from '../backend';
import { Box, Button, Grid, LabeledList, Section, Stack } from '../components';
import { GridColumn } from '../components/Grid';
import { Window } from '../layouts';
import { classes } from 'common/react';

export const ParticleAccelerator = (props, context) => {
  const { act, data } = useBackend(context);
  const { assembled, power, strength, max_strength, layout_1, layout_2, layout_3, orientation } = data;
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
        <Section title={orientation ? 'Chamber Orientation: ' + orientation : 'No Fuel Chamber Detected'}>
          <LabeledList>
            {layout_2.slice().map((item) => {
              return (
                <Stack key={item}>
                  {item.name}: {item.status}, {item.orientation}
                </Stack>
              );
            })}
          </LabeledList>
          <Grid>
            <GridColumn>
              {layout_1.slice().map((item) => (
                <Box
                  key={item.name}
                  fluid
                  textAlign="center"
                  tooltip={item.status}
                  content={
                    <Box className={classes(['particle_accelerator32x32', `${item.orientation}-${item.icon}`])} />
                  }
                  style={{ 'margin-bottom': '5px' }}
                />
              ))}
            </GridColumn>
            <GridColumn>
              {layout_2.slice().map((item) => (
                <Box
                  key={item.name}
                  fluid
                  textAlign="center"
                  tooltip={item.status}
                  content={
                    <Box className={classes(['particle_accelerator32x32', `${item.orientation}-${item.icon}`])} />
                  }
                  style={{ 'margin-bottom': '5px' }}
                />
              ))}
            </GridColumn>
            <GridColumn>
              {layout_3.slice().map((item) => (
                <Box
                  key={item.name}
                  fluid
                  textAlign="center"
                  tooltip={item.status}
                  content={
                    <Box className={classes(['particle_accelerator32x32', `${item.orientation}-${item.icon}`])} />
                  }
                  style={{ 'margin-bottom': '5px' }}
                />
              ))}
            </GridColumn>
          </Grid>
        </Section>
      </Window.Content>
    </Window>
  );
};

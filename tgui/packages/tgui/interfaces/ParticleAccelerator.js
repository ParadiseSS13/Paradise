import { useBackend } from '../backend';
import { Box, Button, Grid, LabeledList, Section, Stack, ImageButton, Flex, Table } from '../components';
import { GridColumn } from '../components/Grid';
import { TableRow } from '../components/Table';
import { Window } from '../layouts';
import { classes } from 'common/react';

const dir2text = (dir) => {
  switch (dir) {
    case 1.0:
      return 'north';
    case 2.0:
      return 'south';
    case 4.0:
      return 'east';
    case 8.0:
      return 'west';
    case 5.0:
      return 'northeast';
    case 6.0:
      return 'southeast';
    case 9.0:
      return 'northwest';
    case 10.0:
      return 'southwest';
  }
  return '';
};

export const ParticleAccelerator = (props, context) => {
  const { act, data } = useBackend(context);
  const { assembled, power, strength, max_strength, icon, layout_1, layout_2, layout_3, orientation } = data;
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
        <Section title="Layout">
          {orientation === 'north' || orientation === 'south' ? (
            <Grid>
              <GridColumn width="40px">
                {layout_1.slice().map((item) => (
                  <ImageButton
                    key={item.name}
                    dmIcon={icon}
                    dmIconState={item.icon_state}
                    direction={item.dir}
                    tooltip={item.name + ': ' + item.status + ', direction: ' + dir2text(item.dir)}
                    style={{
                      'border-style': 'solid',
                      'border-width': '2px',
                      'border-color': item.status === 'good' ? 'green' : 'red',
                      padding: '2px',
                    }}
                  />
                ))}
              </GridColumn>
              <GridColumn width="40px">
                {layout_2.slice().map((item) => (
                  <ImageButton
                    key={item.name}
                    dmIcon={icon}
                    dmIconState={item.icon_state}
                    direction={item.dir}
                    tooltip={item.name + ': ' + item.status + ', direction: ' + dir2text(item.dir)}
                    style={{
                      'border-style': 'solid',
                      'border-width': '2px',
                      'border-color': item.status === 'good' ? 'green' : 'red',
                      padding: '2px',
                    }}
                  />
                ))}
              </GridColumn>
              <GridColumn width="40px">
                {layout_3.slice().map((item) => (
                  <ImageButton
                    key={item.name}
                    dmIcon={icon}
                    dmIconState={item.icon_state}
                    direction={item.dir}
                    tooltip={item.name + ': ' + item.status + ', direction: ' + dir2text(item.dir)}
                    style={{
                      'border-style': 'solid',
                      'border-width': '2px',
                      'border-color': item.status === 'good' ? 'green' : 'red',
                      padding: '2px',
                    }}
                  />
                ))}
              </GridColumn>
            </Grid>
          ) : (
            <Table>
              <TableRow width="40px">
                {layout_1.slice().map((item) => (
                  <Table.Cell key={item.name}>
                    {
                      <ImageButton
                        dmIcon={icon}
                        dmIconState={item.icon_state}
                        direction={item.dir}
                        tooltip={item.name + ': ' + item.status + ', direction: ' + dir2text(item.dir)}
                        style={{
                          'border-style': 'solid',
                          'border-width': '2px',
                          'border-color': item.status === 'good' ? 'green' : 'red',
                          padding: '2px',
                        }}
                      />
                    }
                  </Table.Cell>
                ))}
              </TableRow>
              <TableRow width="40px">
                {layout_2.slice().map((item) => (
                  <Table.Cell key={item.name}>
                    {
                      <ImageButton
                        dmIcon={icon}
                        dmIconState={item.icon_state}
                        direction={item.dir}
                        tooltip={item.name + ': ' + item.status + ', direction: ' + dir2text(item.dir)}
                        style={{
                          'border-style': 'solid',
                          'border-width': '2px',
                          'border-color': item.status === 'good' ? 'green' : 'red',
                          padding: '2px',
                        }}
                      />
                    }
                  </Table.Cell>
                ))}
              </TableRow>
              <TableRow width="40px">
                {layout_3.slice().map((item) => (
                  <Table.Cell key={item.name}>
                    {
                      <ImageButton
                        dmIcon={icon}
                        dmIconState={item.icon_state}
                        direction={item.dir}
                        tooltip={item.name + ': ' + item.status + ', direction: ' + dir2text(item.dir)}
                        style={{
                          'border-style': 'solid',
                          'border-width': '2px',
                          'border-color': item.status === 'good' ? 'green' : 'red',
                          padding: '2px',
                        }}
                      />
                    }
                  </Table.Cell>
                ))}
              </TableRow>
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

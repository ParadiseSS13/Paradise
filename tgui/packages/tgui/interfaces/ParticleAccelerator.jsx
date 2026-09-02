import { Box, Button, ImageButton, LabeledList, Section, Stack, Table, Tooltip } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Grid } from '../components';
import { Window } from '../layouts';

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

export const ParticleAccelerator = (props) => {
  const { act, data } = useBackend();
  const { assembled, power, strength, max_strength, icon, layout_1, layout_2, layout_3, orientation } = data;
  return (
    <Window width={395} height={assembled ? 160 : orientation === 'north' || orientation === 'south' ? 540 : 465}>
      <Window.Content scrollable>
        <Section
          title="Control Panel"
          buttons={<Button dmIcon={'sync'} content={'Connect'} onClick={() => act('scan')} />}
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
        {assembled ? (
          ''
        ) : (
          <Section
            title={
              orientation
                ? 'EM Acceleration Chamber Orientation: ' + capitalize(orientation)
                : 'Place EM Acceleration Chamber Next To Console'
            }
          >
            {orientation === 0 ? (
              ''
            ) : orientation === 'north' || orientation === 'south' ? (
              <LayoutVertical />
            ) : (
              <LayoutHorizontal />
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

const LayoutHorizontal = (props) => {
  const { act, data } = useBackend();
  const { assembled, power, strength, max_strength, icon, layout_1, layout_2, layout_3, orientation } = data;
  return (
    <Table>
      <Table.Row width="40px">
        {(orientation === 'east' ? layout_1 : layout_3).slice().map((item) => (
          <Table.Cell key={item.name}>
            <Tooltip
              content={
                <span style={{ wordWrap: 'break-word' }}>
                  {item.name} <br /> {`Status: ${item.status}`}
                  <br />
                  {`Direction: ${dir2text(item.dir)}`}
                </span>
              }
            >
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor: item.status === 'good' ? 'green' : item.status === 'Incomplete' ? 'orange' : 'red',
                  padding: '2px',
                }}
              />
            </Tooltip>
          </Table.Cell>
        ))}
      </Table.Row>
      <Table.Row width="40px">
        {layout_2.slice().map((item) => (
          <Table.Cell key={item.name}>
            <Tooltip
              content={
                <span style={{ wordWrap: 'break-word' }}>
                  {item.name} <br /> {`Status: ${item.status}`}
                  <br />
                  {`Direction: ${dir2text(item.dir)}`}
                </span>
              }
            >
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor: item.status === 'good' ? 'green' : item.status === 'Incomplete' ? 'orange' : 'red',
                  padding: '2px',
                }}
              />
            </Tooltip>
          </Table.Cell>
        ))}
      </Table.Row>
      <Table.Row width="40px">
        {(orientation === 'east' ? layout_3 : layout_1).slice().map((item) => (
          <Table.Cell key={item.name}>
            <Tooltip
              content={
                <span style={{ wordWrap: 'break-word' }}>
                  {item.name} <br /> {`Status: ${item.status}`}
                  <br />
                  {`Direction: ${dir2text(item.dir)}`}
                </span>
              }
            >
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor: item.status === 'good' ? 'green' : item.status === 'Incomplete' ? 'orange' : 'red',
                  padding: '2px',
                }}
              />
            </Tooltip>
          </Table.Cell>
        ))}
      </Table.Row>
    </Table>
  );
};

const LayoutVertical = (props) => {
  const { act, data } = useBackend();
  const { assembled, power, strength, max_strength, icon, layout_1, layout_2, layout_3, orientation } = data;
  return (
    <Grid>
      <Grid.Column width="40px">
        {(orientation === 'north' ? layout_1 : layout_3).slice().map((item) => (
          <Stack.Item grow key={item.name}>
            <Tooltip
              content={
                <span style={{ wordWrap: 'break-word' }}>
                  {item.name} <br /> {`Status: ${item.status}`}
                  <br />
                  {`Direction: ${dir2text(item.dir)}`}
                </span>
              }
            >
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor: item.status === 'good' ? 'green' : item.status === 'Incomplete' ? 'orange' : 'red',
                  padding: '2px',
                }}
              />
            </Tooltip>
          </Stack.Item>
        ))}
      </Grid.Column>
      <Grid.Column>
        {layout_2.slice().map((item) => (
          <Stack.Item grow key={item.name}>
            <Tooltip
              content={
                <span style={{ wordWrap: 'break-word' }}>
                  {item.name} <br /> {`Status: ${item.status}`}
                  <br />
                  {`Direction: ${dir2text(item.dir)}`}
                </span>
              }
            >
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor: item.status === 'good' ? 'green' : item.status === 'Incomplete' ? 'orange' : 'red',
                  padding: '2px',
                }}
              />
            </Tooltip>
          </Stack.Item>
        ))}
      </Grid.Column>
      <Grid.Column width="40px">
        {(orientation === 'north' ? layout_3 : layout_1).slice().map((item) => (
          <Stack.Item grow key={item.name} tooltip={item.status}>
            <Tooltip
              content={
                <span style={{ wordWrap: 'break-word' }}>
                  {item.name} <br /> {`Status: ${item.status}`}
                  <br />
                  {`Direction: ${dir2text(item.dir)}`}
                </span>
              }
            >
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor: item.status === 'good' ? 'green' : item.status === 'Incomplete' ? 'orange' : 'red',
                  padding: '2px',
                }}
              />
            </Tooltip>
          </Stack.Item>
        ))}
      </Grid.Column>
    </Grid>
  );
};

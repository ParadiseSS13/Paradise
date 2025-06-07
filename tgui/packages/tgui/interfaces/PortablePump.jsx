import { Box, Button, LabeledList, ProgressBar, Section, Slider, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const PortablePump = (props) => {
  const { act, data } = useBackend();
  const { has_holding_tank } = data;

  return (
    <Window width={435} height={330}>
      <Window.Content>
        <Stack fill vertical>
          <PumpSettings />
          <PressureSettings />
          {has_holding_tank ? (
            <HoldingTank />
          ) : (
            <Section fill title="Holding Tank">
              <Box color="average" bold={1} textAlign="center" mt={2.5}>
                No Holding Tank Inserted.
              </Box>
            </Section>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PumpSettings = (props) => {
  const { act, data } = useBackend();
  const { on, direction, port_connected } = data;

  return (
    <Section
      title="Pump Settings"
      buttons={
        <Button
          width={4}
          icon={on ? 'power-off' : 'power-off'}
          content={on ? 'On' : 'Off'}
          color={on ? null : 'red'}
          selected={on}
          onClick={() => act('power')}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Pump Direction">
          <Box>
            <Button
              width={4}
              icon="sign-in-alt"
              content="In"
              selected={!direction}
              onClick={() =>
                act('set_direction', {
                  direction: 0,
                })
              }
            />
            <Button
              width={4}
              icon="sign-out-alt"
              content="Out"
              selected={direction}
              onClick={() =>
                act('set_direction', {
                  direction: 1,
                })
              }
            />
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Port status">
          <Box color={port_connected ? 'green' : 'average'} bold={1} ml={0.5}>
            {port_connected ? 'Connected' : 'Disconnected'}
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const PressureSettings = (props) => {
  const { act, data } = useBackend();
  const { tank_pressure, target_pressure, max_target_pressure } = data;

  const average_pressure = max_target_pressure * 0.7;
  const bad_pressure = max_target_pressure * 0.25;

  return (
    <Section title="Pressure Settings">
      <LabeledList>
        <LabeledList.Item label="Stored pressure">
          <ProgressBar
            value={tank_pressure}
            minValue={0}
            maxValue={max_target_pressure}
            ranges={{
              good: [average_pressure, Infinity],
              average: [bad_pressure, average_pressure],
              bad: [-Infinity, bad_pressure],
            }}
          >
            {tank_pressure} kPa
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
      <Stack mt={1}>
        <Stack.Item grow color="label" mt={0.3}>
          Target pressure:
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="undo"
            mr={0.5}
            width={2.2}
            textAlign="center"
            onClick={() =>
              act('set_pressure', {
                pressure: 101.325,
              })
            }
          />
          <Button
            icon="fast-backward"
            mr={0.5}
            width={2.2}
            textAlign="center"
            onClick={() =>
              act('set_pressure', {
                pressure: 0,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Slider
            animated
            unit="kPa"
            width={16.5}
            stepPixelSize={0.22}
            minValue={0}
            maxValue={max_target_pressure}
            value={target_pressure}
            onChange={(e, value) =>
              act('set_pressure', {
                pressure: value,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="fast-forward"
            ml={0.5}
            width={2.2}
            textAlign="center"
            onClick={() =>
              act('set_pressure', {
                pressure: max_target_pressure,
              })
            }
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const HoldingTank = (props) => {
  const { act, data } = useBackend();
  const { holding_tank, max_target_pressure } = data;

  const average_pressure = max_target_pressure * 0.7;
  const bad_pressure = max_target_pressure * 0.25;

  return (
    <Section
      fill
      title="Holding Tank"
      buttons={
        <Button onClick={() => act('remove_tank')} icon="eject">
          Eject
        </Button>
      }
    >
      <Stack>
        <Stack.Item color="label">Tank Label:</Stack.Item>
        <Stack.Item color="silver" ml={4.5}>
          {holding_tank.name}
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item color="label" mt={2}>
          Tank Pressure:
        </Stack.Item>
        <Stack.Item grow mt={1.5}>
          <ProgressBar
            value={holding_tank.tank_pressure}
            minValue={0}
            maxValue={max_target_pressure}
            ranges={{
              good: [average_pressure, Infinity],
              average: [bad_pressure, average_pressure],
              bad: [-Infinity, bad_pressure],
            }}
          >
            {holding_tank.tank_pressure} kPa
          </ProgressBar>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

import { useBackend } from "../backend";
import { Button, Section, LabeledList, Slider, Box, ProgressBar, Flex } from "../components";
import { Window } from "../layouts";

export const PortableScrubber = (props, context) => {
  const { act, data } = useBackend(context);
  const { has_holding_tank } = data;

  return (
    <Window>
      <Window.Content>
        <PumpSettings />
        <PressureSettings />
        {has_holding_tank ? (
          <HoldingTank />
        ) : (
          <Section title="Holding Tank">
            <Box color="average" bold={1}>
              No Holding Tank Inserted.
            </Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

const PumpSettings = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on,
    port_connected,
  } = data;

  return (
    <Section title="Pump Settings">
      <Flex>
        <Flex.Item
          mb={2.5}
          mt={0.5}
          mr={11.9}
          color="label">
          Power:
        </Flex.Item>
        <Flex.Item>
          <Button
            icon={on ? "power-off" : "power-off"}
            content={on ? "On" : "Off"}
            color={on ? null : "red"}
            selected={on}
            onClick={() => act('power')} />
        </Flex.Item>
      </Flex>
      <Flex>
        <Flex.Item
          mr={6.8}
          color="label">
          Port Status:
        </Flex.Item>
        <Flex.Item
          color={port_connected ? "green" : "average"}
          bold={1}>
          {port_connected ? "Connected" : "Disconnected"}
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const PressureSettings = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    tank_pressure,
    rate,
    max_rate,
  } = data;

  const average_pressure = max_rate * 0.70;
  const bad_pressure = max_rate * 0.25;

  return (
    <Section title="Pressure Settings">
      <LabeledList>
        <LabeledList.Item label="Stored pressure">
          <ProgressBar
            value={tank_pressure}
            minValue={0}
            maxValue={max_rate}
            ranges={{
              good: [average_pressure, Infinity],
              average: [bad_pressure, average_pressure],
              bad: [-Infinity, bad_pressure],
            }}>
            {tank_pressure} kPa
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
      <Flex mt={2}>
        <Flex.Item
          mt={0.4}
          grow={1}
          color="label">
          Target pressure:
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="undo"
            mr={0.5}
            width={2.2}
            textAlign="center"
            onClick={() => act('set_rate', {
              rate: 101.325,
            })} />
          <Button
            icon="fast-backward"
            mr={0.5}
            width={2.2}
            textAlign="center"
            onClick={() => act('set_rate', {
              rate: 0,
            })} />
        </Flex.Item>
        <Flex.Item>
          <Slider
            animated
            unit="kPa"
            width={17.3}
            stepPixelSize={0.22}
            minValue={0}
            maxValue={max_rate}
            value={rate}
            onChange={(e, value) => act('set_rate', {
              rate: value,
            })} />
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="fast-forward"
            ml={0.5}
            width={2.2}
            textAlign="center"
            onClick={() => act('set_rate', {
              rate: max_rate,
            })} />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const HoldingTank = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    holding_tank,
    max_rate,
  } = data;

  const average_pressure = max_rate * 0.70;
  const bad_pressure = max_rate * 0.25;

  return (
    <Section
      title="Holding Tank"
      buttons={
        <Button
          onClick={() => act('remove_tank')}
          icon="eject">
          Eject
        </Button>
      }>
      <Flex>
        <Flex.Item
          color="label"
          mr={7.2}
          mb={2.2}>
          Tank Label:
        </Flex.Item>
        <Flex.Item mb={1} color="silver">
          {holding_tank.name}
        </Flex.Item>
      </Flex>
      <Flex>
        <Flex.Item
          color="label"
          mt={0.5}
          mr={3.8}>
          Tank Pressure:
        </Flex.Item>
        <Flex.Item grow={1}>
          <ProgressBar
            value={holding_tank.tank_pressure}
            minValue={0}
            maxValue={max_rate}
            ranges={{
              good: [average_pressure, Infinity],
              average: [bad_pressure, average_pressure],
              bad: [-Infinity, bad_pressure],
            }}>
            {holding_tank.tank_pressure} kPa
          </ProgressBar>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

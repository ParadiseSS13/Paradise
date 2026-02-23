import { Box, Button, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SatelliteMonitorData {
  satellite_data: {
    name: string;
    // satellite_stats: {
    weight: number;
    fuel_efficiency: number;
    fuel_capacity: number;
    science_multiplier: number;
    passive_power_generation: number;
    active_power_generation: number;
    power_consumption: number;
    power_capacity: number;
    current_power: number;
    current_fuel: number;
    // };
  }[];
  collected_science_data: number;
  inserted_disk: boolean;
  cmagged: boolean;
  current_planet_base64: string;
  current_background_base64: string;
}

export const SatelliteMonitor = (props, context) => {
  const { act, data } = useBackend<SatelliteMonitorData>();

  const { satellite_data, collected_science_data, inserted_disk, cmagged } = data;

  return (
    <Window width={700} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Stack fill height="90%" scrollable>
            <Section title="Satellites" fill scrollable width="60%">
              <SatellitePanel />
            </Section>
            <Section fill width="40%">
              <PlanetPanel />
            </Section>
          </Stack>
          <Section>
            <DiskPanel />
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SatellitePanel = () => {
  const { act, data } = useBackend<SatelliteMonitorData>();

  const { satellite_data, cmagged } = data;

  return satellite_data.map((satellite) => (
    <Stack.Item key={satellite.name}>
      <Stack mb={2} ml={1}>
        <Section title={satellite.name} width="100%" backgroundColor="#4444">
          <Stack>
            <Box width="70%">Data processing power: {satellite.science_multiplier * 100 + '%'}</Box>
            <Box width="30%" align="right">
              weight: {satellite.weight + 'kg'}
            </Box>
          </Stack>
          <Stack>
            <Box width="50%">
              fuel capacity:
              {!cmagged ? satellite.fuel_capacity + 'L' : (satellite.fuel_capacity * 35.19).toPrecision(4) + 'oz'}
            </Box>
            <Box width="50%" align="right">
              fuel efficiency: {(1 - satellite.fuel_efficiency / 100).toPrecision(3) + 'L/s'}
            </Box>
          </Stack>
          <Stack mt={1}>
            <Stack.Item align="center" width="15%">
              Fuel:
            </Stack.Item>
            <Stack.Item width="85%">
              <ProgressBar
                value={satellite.current_fuel / satellite.fuel_capacity}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.5, 0.9],
                  bad: [-Infinity, 0.5],
                }}
              />
            </Stack.Item>
          </Stack>
          <Stack mt={1}>
            <Stack.Item align="center" width="15%">
              Power:
            </Stack.Item>
            <Stack.Item width="85%">
              <ProgressBar
                value={satellite.current_power / satellite.power_capacity}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.5, 0.9],
                  bad: [-Infinity, 0.5],
                }}
              />
            </Stack.Item>
          </Stack>
          <Stack mt={1}>
            {satellite.power_consumption - satellite.passive_power_generation > 0
              ? 'power generation: '
              : 'power consumption: '}

            {Math.abs(satellite.power_consumption - satellite.passive_power_generation) + 'W/s'}
          </Stack>
          <Stack>
            <Box mt={1} width="50%">
              status: {'OK'}
            </Box>
            <Box width="50%" align="right">
              <Button>Controls</Button>
            </Box>
          </Stack>
        </Section>
      </Stack>
    </Stack.Item>
  ));
};

const DiskPanel = () => {
  const { act, data } = useBackend<SatelliteMonitorData>();

  const { collected_science_data, inserted_disk } = data;

  return (
    <Stack>
      <Stack width="50%" align="center">
        Collected Data: {collected_science_data}
      </Stack>
      <Box width="50%" align="right">
        <Button disabled={!inserted_disk} tooltip={!inserted_disk ? 'No disk inserted' : ''}>
          Load Data onto Disk
        </Button>
        <Button disabled={!inserted_disk} tooltip={!inserted_disk ? 'No disk inserted' : ''}>
          Eject Disk
        </Button>
      </Box>
    </Stack>
  );
};

const PlanetPanel = () => {
  const { act, data } = useBackend<SatelliteMonitorData>();

  const { current_planet_base64, current_background_base64 } = data;
  console.log(current_planet_base64);

  const planetZ = 10;
  const backgroundZ = 5;
  return (
    <Box m={-1}>
      <Stack>
        <img
          style={{
            width: '100%',
            height: '100%',
            position: 'absolute',
            zIndex: backgroundZ,
            objectFit: 'cover',
          }}
          src={`data:image/png;base64,${current_background_base64}`}
        />
      </Stack>
      <Box
        mt={'20%'}
        style={{
          alignContent: 'center',
        }}
        height="100%"
        align="center"
      >
        <img
          style={{
            position: 'relative',
            zIndex: planetZ,
          }}
          src={`data:image/png;base64,${current_planet_base64}`}
        />
      </Box>
    </Box>
  );
};

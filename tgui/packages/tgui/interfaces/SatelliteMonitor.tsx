import { Box, Button, Section, Stack } from 'tgui-core/components';

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
    power_generation: number;
    power_consumption: number;
    power_capacity: number;
    // };
  }[];
  collected_science_data: number;
  inserted_disk: boolean;
  cmagged: boolean;
}

export const SatelliteMonitor = (props, context) => {
  const { act, data } = useBackend<SatelliteMonitorData>();

  const { satellite_data, collected_science_data, inserted_disk, cmagged } = data;
  console.log(satellite_data);
  return (
    <Window width={700} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Stack fill height="90%" scrollable>
            <Section title="Satellites" fill scrollable width="60%">
              {satellite_data.map((satellite) => (
                <Stack.Item key={satellite.name}>
                  <Stack>
                    <Box width="50%">
                      name: {satellite.name}
                      weight: {satellite.weight + 'kg'}
                      fuel efficiency: {(10 / satellite.fuel_efficiency).toPrecision(3) + 'L/s'}
                      fuel capacity:{' '}
                      {!cmagged
                        ? satellite.fuel_capacity + 'L'
                        : (satellite.fuel_capacity * 35.19).toPrecision(4) + 'oz'}
                      ; Data processing power: {satellite.science_multiplier * 100 + '%'}; power generation:{' '}
                      {satellite.power_generation + 'W/s'}; power consumption: {satellite.power_consumption + 'W/s'};
                      Power Capacity: {satellite.power_capacity + 'W'}; status: {'OK'}
                    </Box>
                    <Box width="50%" align="right">
                      <Button>Controls</Button>
                    </Box>
                  </Stack>
                </Stack.Item>
              ))}

              {/**
               *
              <Stack.Item>
                Satellite 1 <Button align="left">Controls</Button>
              </Stack.Item>
                */}
            </Section>
            <Section fill width="40%">
              <Stack>planet.png</Stack>
            </Section>
          </Stack>
          <Section>
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

            {/**
             *
            <Stack>
              <Stack.Item left width="50%" align="left">
                <Stack>Collected Science: 1234</Stack>
              </Stack.Item>
              <Stack.Item right align="right">
                <Stack>
                  <Button>Load Data onto Disk</Button>
                  <Button>Eject Disk</Button>
                </Stack>
              </Stack.Item>
            </Stack>
                  */}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

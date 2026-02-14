import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SatelliteMonitorData {
  linked_satellites: {
    name: string;
    satellite_stats: {
      weight: number;
      fuel_efficiency: number;
      fuel_capacity: number;
      science_multiplier: number;
      power_generation: number;
      power_storage: number;
      power_consumption: number;
      power_capacity: number;
    };
    /*
    parts: {
      name: string;
      weight: number;
      fuel_efficiency: number;
      fuel_capacity: number;
      science_multiplier: number;
      power_generation: number;
      power_storage: number;
      power_consumption: number;
      power_capacity: number;
    }[];
    */
  }[];
  collected_science_data: number;
  inserted_disk: boolean;
}

export const SatelliteMonitor = (props, context) => {
  const { act, data } = useBackend<SatelliteMonitorData>();

  const { linked_satellites, collected_science_data, inserted_disk } = data;

  return (
    <Window width={700} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Stack fill height="90%" scrollable>
            <Section title="Satellites" fill scrollable width="60%">
              {linked_satellites.map((satellite) => (
                <Stack.Item key={satellite.name}>
                  name: {satellite.name} weight: {satellite.satellite_stats.weight}
                  <Button align="left">Controls</Button>
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
                Collected Data: 1244
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

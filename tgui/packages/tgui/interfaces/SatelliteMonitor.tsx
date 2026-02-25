import { useState } from 'react';
import { Box, Button, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SatelliteMonitorData {
  satellite_data: Satellite[];
  collected_science_data: number;
  inserted_disk: boolean;
  cmagged: boolean;
  world_time: number;
  current_planet_base64: string;
  current_background_base64: string;
}

interface Satellite {
  UID: any;
  name: string;
  status: string;
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
  orbit_data: {
    apoapsis: number;
    periapsis: number;
    inclination: number;
    period_multiplier: number;
    period: number;
    launch_time: number;
    velocity: number;
    orbit_progress: number;
  };
  // };
}

export const SatelliteMonitor = (props, context) => {
  const { act, data } = useBackend<SatelliteMonitorData>();

  const { satellite_data, collected_science_data, inserted_disk, cmagged } = data;

  const [selectedSatellite, setSelectedSatellite] = useState<Satellite | null>(null);

  return (
    <Window width={900} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack fill scrollable>
            <Section title={selectedSatellite ? selectedSatellite.name : 'Satellites'} fill scrollable width="60%">
              {selectedSatellite ? (
                <ManeuverPanel
                  cmagged={cmagged}
                  selectedSatellite={selectedSatellite}
                  setSelectedSatellite={setSelectedSatellite}
                />
              ) : (
                <SatellitePanel
                  satellite_data={satellite_data}
                  cmagged={cmagged}
                  setSelectedSatellite={setSelectedSatellite}
                />
              )}
            </Section>
            <Section fill width="50%">
              <PlanetPanel
                satellites={satellite_data}
                current_planet_base64={data.current_planet_base64}
                current_background_base64={data.current_background_base64}
              />
            </Section>
          </Stack>
          <Section height="3em">
            <DiskPanel />
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ManeuverPanel = ({ cmagged, selectedSatellite, setSelectedSatellite }) => {
  return (
    <Stack>
      <Stack>normal: {}</Stack>
      <Stack>
        <Button onClick={() => setSelectedSatellite(null)}>Back</Button>
      </Stack>
    </Stack>
  );
};

const SatellitePanel = ({ satellite_data, cmagged, setSelectedSatellite }) => {
  return satellite_data.map((satellite: Satellite) => (
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
              status: {satellite.status}
            </Box>
            <Box width="50%" align="right">
              <Button onClick={() => setSelectedSatellite(satellite)}>Controls</Button>
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
    <Stack fill align="center">
      <Stack.Item width="50%">Collected Data: {collected_science_data}</Stack.Item>
      <Stack.Item width="50%" textAlign="right">
        <Button mr={1} disabled={!inserted_disk} tooltip={!inserted_disk ? 'No disk inserted' : ''}>
          Load Data onto Disk
        </Button>
        <Button disabled={!inserted_disk} tooltip={!inserted_disk ? 'No disk inserted' : ''}>
          Eject Disk
        </Button>
      </Stack.Item>
    </Stack>
  );
};

const PlanetPanel = ({ satellites, current_planet_base64, current_background_base64 }) => {
  const { act, data } = useBackend<SatelliteMonitorData>();

  const planetZ = 10;
  const backgroundZ = 5;
  return (
    <Box m={-1} mt={'-0.7em'}>
      <Stack>
        <img
          draggable={false}
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
      <Box height="100%" backgroundColor="green">
        <img
          draggable={false}
          style={{
            top: '50%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            position: 'absolute',
            zIndex: planetZ,
          }}
          src={`data:image/png;base64,${current_planet_base64}`}
        />
      </Box>
    </Box>
  );
};

import { useState } from 'react';
import { Box, Button, NumberInput, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SatelliteMonitorData {
  satellite_data: Satellite[];
  inserted_disk: boolean;
  cmagged: boolean;
  world_time: number;
  current_planet_base64: string;
  current_background_base64: string;
}

interface Satellite {
  UID: any;
  name: string;
  collected_science_data: number;
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
  fuel_usage: number;
  orbit_data: {
    apoapsis: number;
    periapsis: number;
    inclination: number;
    period_multiplier: number;
    period: number;
    launch_time: number;
    velocity: number;
    orbit_progress: number;
    planned_maneuvers: Maneuver[];
  };
  // };
}

class Maneuver {
  prograde: number = 0;
  normal: number = 0;
  burnTime: number = 0;
  time_to_maneuver: number = 0;
}

export const SatelliteMonitor = (props, context) => {
  const { act, data } = useBackend<SatelliteMonitorData>();

  const { satellite_data, inserted_disk, cmagged, world_time } = data;

  const [selectedSatellite, setSelectedSatellite] = useState<Satellite | null>(null);
  const [plannedManeuver, setPlannedManeuver] = useState<Maneuver>(new Maneuver());

  return (
    <Window width={900} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack fill scrollable>
            <Section title={selectedSatellite ? selectedSatellite.name : 'Satellites'} fill scrollable width="60%">
              {selectedSatellite ? (
                <Box>
                  <ManeuverPanel
                    cmagged={cmagged}
                    selectedSatellite={selectedSatellite}
                    worldTime={world_time}
                    setSelectedSatellite={setSelectedSatellite}
                    plannedManeuver={plannedManeuver}
                    setPlannedManeuver={setPlannedManeuver}
                    act={act}
                  />
                </Box>
              ) : (
                <SatellitePanel satellite_data={satellite_data} setSelectedSatellite={setSelectedSatellite} />
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
            <DiskPanel inserted_disk={inserted_disk} satellite_data={satellite_data} />
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface ManeuverPanelProps {
  cmagged: boolean;
  selectedSatellite: Satellite;
  worldTime: number;
  setSelectedSatellite: any;
  plannedManeuver: Maneuver;
  setPlannedManeuver: any;
  act: any;
}

const ManeuverPanel = ({
  cmagged,
  selectedSatellite,
  worldTime,
  setSelectedSatellite,
  plannedManeuver,
  setPlannedManeuver,
  act,
}: ManeuverPanelProps) => {
  return (
    <Stack vertical>
      <Box width="100%" align="end">
        <Button
          onClick={() => {
            setSelectedSatellite(null);
          }}
        >
          Back
        </Button>
      </Box>
      <Stack fill>
        <Stack vertical width="100%">
          <Stack>
            <Stack width="50%" vertical>
              <Stack>{`Apoapsis: ${selectedSatellite.orbit_data.apoapsis * (cmagged ? 0.6213 : 1)}${cmagged ? 'mi' : 'km'}`}</Stack>
              <Stack>{`Periapsis: ${selectedSatellite.orbit_data.periapsis}km`}</Stack>
              <Stack>{`Inclination: ${selectedSatellite.orbit_data.inclination}`}</Stack>
            </Stack>
            <Stack width="50%" vertical>
              <Stack>{`weight: ${selectedSatellite.weight}kg`}</Stack>
              <Stack>{`fuel usage: ${selectedSatellite.fuel_usage.toPrecision(2)}L/s`}</Stack>
            </Stack>
          </Stack>
          <Section title="Burn configuration">
            <Stack>
              <Stack.Item width="50%">
                {`${plannedManeuver.prograde >= 0 ? 'Prograde' : 'Retrograde'} (${Math.abs(plannedManeuver.prograde ?? 0)}%):`}
              </Stack.Item>
              <NumberInput
                width="3.1em"
                value={plannedManeuver.prograde ?? 0}
                minValue={-100}
                maxValue={100}
                step={1}
                stepPixelSize={4}
                onChange={(value) => {
                  plannedManeuver.prograde = value;
                }}
              />
            </Stack>
            <Stack>
              <Stack.Item width="50%">{`${plannedManeuver.normal >= 0 ? 'Normal' : 'Antinormal'} (${Math.abs(plannedManeuver.normal ?? 0)}%):`}</Stack.Item>
              <NumberInput
                width="3.1em"
                value={plannedManeuver.normal ?? 0}
                minValue={-100}
                maxValue={100}
                step={1}
                stepPixelSize={4}
                onChange={(value) => {
                  plannedManeuver.normal = value;
                }}
              />
            </Stack>
            <Stack>
              <Stack.Item width="50%">{`Burn time: ${plannedManeuver.burnTime}s`}</Stack.Item>
              <NumberInput
                width="3.1em"
                value={plannedManeuver.burnTime ?? 0}
                minValue={0}
                maxValue={999}
                step={1}
                stepPixelSize={4}
                onChange={(value) => {
                  plannedManeuver.burnTime = value;
                }}
              />
            </Stack>
            <Stack>
              <Stack.Item width="50%">{`Time to maneuver (${plannedManeuver.time_to_maneuver ?? 0} minutes): `}</Stack.Item>
              <NumberInput
                width="3.1em"
                value={plannedManeuver.time_to_maneuver ?? 0}
                minValue={0}
                maxValue={60}
                step={1}
                stepPixelSize={6}
                onChange={(value) => {
                  plannedManeuver.time_to_maneuver = value;
                }}
              />
            </Stack>
            <Box mt={2} align="right">
              <Button
                onClick={() => {
                  if (plannedManeuver.burnTime) {
                    act('add_maneuver', {
                      uid: selectedSatellite.UID,
                      prograde: plannedManeuver.prograde,
                      normal: plannedManeuver.normal,
                      burnTime: plannedManeuver.burnTime,
                      timeToManeuver: plannedManeuver.time_to_maneuver,
                    });
                  }
                }}
              >
                Add Maneuver
              </Button>
            </Box>
            <Section title="Planned maneuvers" scrollable>
              <Box textAlign="right">
                {selectedSatellite.orbit_data.planned_maneuvers.length > 0 && (
                  <Button
                    disabled={selectedSatellite.orbit_data.planned_maneuvers.length === 0}
                    onClick={() => {
                      act('delete_all_maneuvers', {
                        uid: selectedSatellite.UID,
                      });
                    }}
                  >
                    Delete all maneuvers
                  </Button>
                )}
              </Box>
              {selectedSatellite.orbit_data.planned_maneuvers.length > 0
                ? selectedSatellite.orbit_data.planned_maneuvers.map((maneuver: Maneuver) => {
                    return (
                      <Stack key={maneuver.time_to_maneuver} scrollable>
                        <Stack>{`Maneuver in ${maneuver.time_to_maneuver} minutes`}</Stack>
                      </Stack>
                    );
                  })
                : selectedSatellite.status === 'OK' && (
                    <Box backgroundColor="red" textAlign="center" height="100%">
                      <Button width="100px" height="100px" textAlign="center">
                        <b>LAUNCH</b>
                      </Button>
                    </Box>
                  )}
            </Section>
          </Section>
        </Stack>
      </Stack>
    </Stack>
  );
};

const SatellitePanel = ({ satellite_data, setSelectedSatellite }) => {
  return satellite_data.map((satellite: Satellite) => (
    <Stack.Item key={satellite.name}>
      <Stack mb={2} ml={1}>
        <Section title={satellite.name} width="100%" backgroundColor="#4444">
          <Stack>
            <Box width="70%">Data processing power: {satellite.science_multiplier * 100 + '%'}</Box>
            <Box width="30%" align="right">
              Collected data: {satellite.collected_science_data}
            </Box>
          </Stack>
          <Stack>
            <Box width="50%">Period: {satellite.orbit_data.period + 'min'}</Box>
            <Box width="50%" align="right">
              fuel efficiency: {(1 / satellite.fuel_efficiency).toPrecision(3) + 'L/s'}
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
            {satellite.passive_power_generation - satellite.power_consumption > 0
              ? 'power generation: '
              : 'power consumption: '}

            {Math.abs(satellite.power_consumption - satellite.passive_power_generation) + 'W/s'}
          </Stack>
          <Stack>
            <Box mt={1} width="50%">
              status: {satellite.status}
            </Box>
            <Box width="50%" align="right">
              <Button
                onClick={() => {
                  console.log(satellite);
                  setSelectedSatellite(satellite);
                }}
              >
                Controls
              </Button>
            </Box>
          </Stack>
        </Section>
      </Stack>
    </Stack.Item>
  ));
};

const DiskPanel = ({ satellite_data, inserted_disk }) => {
  let collected_science_data = 0;
  for (let i = 0; i < satellite_data.length; i++) {
    collected_science_data += satellite_data[i].collected_science_data;
  }

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

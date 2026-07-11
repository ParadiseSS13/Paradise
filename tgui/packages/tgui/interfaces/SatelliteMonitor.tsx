import { useState } from 'react';
import { Box, Button, NumberInput, ProgressBar, Section, Stack } from 'tgui-core/components';

import { resolveAsset } from '../assets'; /* Used to load assets from PNGs from the `code\modules\asset_cache\assets` folder*/
import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SatelliteMonitorData {
  satellite_data: Satellite[];
  inserted_disk: boolean;
  cmagged: boolean;
  world_time: number;
  current_planet_theme: string;
  current_background_base64: string;
  selected_satellite_UID_ui: string;
  weather_nodes: WeatherNode[];
  planet_radius: number;
}

interface WeatherNode {
  position: Vector3;
  node_type: string;
  asset_icon: string;
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
  has_been_launched: number;
  orbit_data: {
    apoapsis: number;
    periapsis: number;
    apoapsis_position: Vector3;
    periapsis_position: Vector3;
    inclination: number;
    period: number;
    launch_time: number;
    // velocity: number;
    // orbit_progress: number;
    planned_maneuvers: Maneuver[];
    planned_orbit: Vector3[];
    position: Vector3;
    velocity: Vector3;
  };
  // };
}

interface Vector3 {
  x: number;
  y: number;
  z: number;
}

class Maneuver {
  prograde: number = 0;
  normal: number = 0;
  burn_time: number = 0;
  time_to_maneuver: number = 0;
}

export const SatelliteMonitor = (props, context) => {
  const { act, data } = useBackend<SatelliteMonitorData>();

  const { satellite_data, inserted_disk, cmagged, world_time, selected_satellite_UID_ui, weather_nodes, planet_radius } = data;

  const [plannedManeuver, setPlannedManeuver] = useState<Maneuver>(new Maneuver());
  let selectedSatellite: Satellite | undefined = satellite_data.find(
    (satellite) => satellite.UID === selected_satellite_UID_ui
  );

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
                    plannedManeuver={plannedManeuver}
                    setPlannedManeuver={setPlannedManeuver}
                    act={act}
                  />
                </Box>
              ) : (
                <SatellitePanel satellite_data={satellite_data} selectedSatellite={selectedSatellite} act={act} />
              )}
            </Section>
            <Section fill width="50%">
              <PlanetPanel
                satellites={satellite_data}
                current_planet_theme={data.current_planet_theme}
                current_background_base64={data.current_background_base64}
                selectedSatellite={selectedSatellite}
                weather_nodes={weather_nodes}
                planet_radius={planet_radius}
              />
            </Section>
          </Stack>
          <Section height="3em">
            <DiskPanel
              inserted_disk={inserted_disk}
              satellite_data={satellite_data}
              act={act} />
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
  plannedManeuver: Maneuver;
  setPlannedManeuver: any;
  act: any;
}

const ManeuverPanel = ({
  cmagged,
  selectedSatellite,
  worldTime,
  plannedManeuver,
  setPlannedManeuver,
  act,
}: ManeuverPanelProps) => {
  const deciseconds_in_minute = 600;
  const deciseconds_in_second = 10;

  return (
    <Stack vertical>
      <Box width="100%" align="end">
        <Button
          onClick={() => {
            act('select_satellite');
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
              <Stack>{`Position: (${selectedSatellite.orbit_data.position?.x}, ${selectedSatellite.orbit_data.position?.y}, ${selectedSatellite.orbit_data.position?.z})`}</Stack>
            </Stack>
            <Stack width="50%" vertical>
              <Stack>{`weight (total): ${Math.round(selectedSatellite.weight + selectedSatellite.current_fuel)}kg`}</Stack>
              <Stack>{`fuel usage: ${selectedSatellite.fuel_usage.toFixed(2)}L/s`}</Stack>
              <Stack>{`Period: ${selectedSatellite.orbit_data.period / deciseconds_in_minute}min`}</Stack>
              {/* <Stack>{`Velocity: ${Math.sqrt(selectedSatellite.orbit_data.velX ** 2 + selectedSatellite.orbit_data.velY ** 2 + selectedSatellite.orbit_data.velZ ** 2)} km/s`}</Stack>*/}
              <Stack>{`Velocity: (${selectedSatellite.orbit_data.velocity?.x}, ${selectedSatellite.orbit_data.velocity?.y}, ${selectedSatellite.orbit_data.velocity?.z})`}</Stack>
            </Stack>
          </Stack>
          <Section title="Burn configuration" mt={3}>
            <Box mb={2} align="right">
              <Button
                onClick={() => {
                  if (plannedManeuver.burn_time) {
                    act('add_maneuver', {
                      uid: selectedSatellite.UID,
                      prograde: plannedManeuver.prograde,
                      normal: plannedManeuver.normal,
                      burnTime: plannedManeuver.burn_time,
                      timeToManeuver: plannedManeuver.time_to_maneuver,
                    });
                  }
                }}
              >
                Add Maneuver
              </Button>
            </Box>
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
              <Stack.Item width="50%">{`Burn time (${plannedManeuver.burn_time}s): `}</Stack.Item>
              <NumberInput
                width="3.1em"
                value={plannedManeuver.burn_time ?? 0}
                minValue={0}
                maxValue={999}
                step={1}
                stepPixelSize={4}
                onChange={(value) => {
                  plannedManeuver.burn_time = value;
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

            <Section title="Planned maneuvers" scrollable mt={3}>
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
              {selectedSatellite.orbit_data.planned_maneuvers.length > 0 ?
                selectedSatellite.orbit_data.planned_maneuvers.map((maneuver: Maneuver) => {
                  let time = maneuver.time_to_maneuver / deciseconds_in_minute; // BYOND handles everything in deciseconds
                  // prettier-ignore
                  let minuteString = (Math.sign(time) === 1 ? '' : '-') + Math.abs(Math.trunc(time)).toString().padStart(2, '0'); // force show sign on 0, force 2 digits
                  // prettier-ignore
                  let secondsString = Math.abs(Math.trunc((time % 1) * 60)).toString().padStart(2, '0'); // remove sign, force 2 digits

                  return (
                    <Stack key={maneuver.time_to_maneuver} scrollable mt={3}>
                      <Stack vertical>
                        <Stack>{`Maneuver in ${minuteString}:${secondsString}`}</Stack>
                        <Stack>{`Prograde: ${maneuver.prograde} Normal: ${maneuver.normal} Burn Time: ${maneuver.burn_time / deciseconds_in_second}s`}</Stack>
                      </Stack>
                    </Stack>
                  );
                })
              : !selectedSatellite.has_been_launched && (
                  <Box backgroundColor="red" textAlign="center" height="100%">
                    <Button width="100px" height="100px" textAlign="center"
                      onClick={() => { act('launch', {
                        uid: selectedSatellite.UID,
                      }); }}>
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

const SatellitePanel = ({ satellite_data, selectedSatellite, act }) => {
  return satellite_data.map((satellite: Satellite) => (
    <Stack.Item key={satellite.name}>
      <Stack mb={2} ml={1}>
        <Section title={satellite.name} width="100%" backgroundColor="#4444">
          <Stack>
            <Box width="50%">Data Processing Power: {Math.round(satellite.science_multiplier * 100) + '%'}</Box>
            <Box width="50%" align="right">
              Collected Data: {Math.round(satellite.collected_science_data)}
            </Box>
          </Stack>
          <Stack>
            <Box width="50%">Period: {satellite.orbit_data.period + 'min'}</Box>
            <Box width="50%" align="right">
              {`Fuel Usage: ${satellite.fuel_usage.toFixed(2)}L/s`}
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
            {`Passive power generation: ${satellite.passive_power_generation}W/s`}
          </Stack>
          <Stack>
            <Box mt={1} width="50%">
              status: {satellite.status}
            </Box>
            <Box width="50%" align="right">
              <Button
                onClick={() => {
                  act('select_satellite', {
                    uid: satellite.UID,
                  });
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

const DiskPanel = ({ satellite_data, inserted_disk, act }) => {
  let collected_science_data = 0;
  for (let i = 0; i < satellite_data.length; i++) {
    collected_science_data += satellite_data[i].collected_science_data;
  }

  return (
    <Stack fill align="center">
      <Stack.Item width="50%">Total Collected Data: {collected_science_data.toFixed(1)}</Stack.Item>
      <Stack.Item width="50%" textAlign="right">
        <Button
          mr={1}
          disabled={!inserted_disk}
          tooltip={!inserted_disk ? 'No disk inserted' : ''}
          onClick={() => { act('load_data_onto_disk'); }}>
          Load Data onto Disk
        </Button>
        <Button
          disabled={!inserted_disk}
          tooltip={!inserted_disk ? 'No disk inserted' : ''}
          onClick={() => { act('eject_disk'); }}>
          Eject Disk
        </Button>
      </Stack.Item>
    </Stack>
  );
};

interface PlanetPanelProps {
  satellites: Satellite[],
  current_planet_theme: string,
  current_background_base64: string,
  selectedSatellite: Satellite | undefined,
  weather_nodes: WeatherNode[],
  planet_radius: number,
}

const PlanetPanel = ({ satellites, current_planet_theme, current_background_base64, selectedSatellite, weather_nodes, planet_radius } : PlanetPanelProps) => {
  class SegmentList {
    segments:Vector3[] = [];
    ownerUID: any;
  }

  const scale = 0.9; // scale is just what looks good with the planet image used
  const satelliteImageSize = 40;
  const viewBox = '-300 -300 600 600';
  const weather_node_size = 40; // based off what looks good

  let frontSegments:SegmentList[] = [];
  let backSegments:SegmentList[] = [];
  let currentSegment:SegmentList;


  for (let i = 0; i < satellites.length; i++) {
    let current_sat:Satellite = satellites[i];
    currentSegment = new SegmentList;
    currentSegment.ownerUID = current_sat.UID;

    for (let j = 0; j < current_sat.orbit_data.planned_orbit.length - 1; j++) {

      let current_element = current_sat.orbit_data.planned_orbit[j];
      let next_element = current_sat.orbit_data.planned_orbit[j + 1];

      if (Math.sign(current_element.z) === Math.sign(next_element.z)) // the planet is at 0,0 so if the segment shares a sign with the next, they must be on the same plane
      {
        currentSegment.segments.push(current_element);
      }
      else
      {
        if(current_element.z > 0)
        {
          frontSegments.push(currentSegment);
        }
        else
        {
          backSegments.push(currentSegment);
        }

        currentSegment = new SegmentList;
        currentSegment.ownerUID = current_sat.UID;
        currentSegment.segments.push(current_element);
      }
    }

    if (currentSegment.segments.length > 0) {
      if(currentSegment.segments[0].z > 0)
      {
        frontSegments.push(currentSegment);
      }
      else
      {
        backSegments.push(currentSegment);
      }
    }
  }

  return (
    <Box m={-1} mt={'-0.7em'}>
      <Stack>
        <img
          draggable={false}
          style={{
            userSelect: 'none',
            width: '100%',
            height: '100%',
            position: 'absolute',
            objectFit: 'cover',
          }}
          src={`data:image/png;base64,${current_background_base64}`}
        />
      </Stack>
      <Box
        width="100%"
        height="100%"
        style={{
          position: 'absolute',
          overflow: 'hidden',
        }}
      >{
        <Stack style={
          {
           width: "100%",
           height: "100%",
           position: "absolute",
          }
        }>
          <svg width={"100%"}
            height={"100%"}
            viewBox={viewBox}
            preserveAspectRatio='xMidYMid meet'
            style={
              {
                height: '100%',
                width: '100%',
                position:'absolute',
                border: "1px solid yellow",
              }
            }>
            <mask id="mask">
            {
              /*
              x and y are set to negative half the width and height as the pivot is in the upper left corner and we need to move it to the corner of the actual svg.
              Width and height are the values of the viewBox added together.
              */
            }
              <rect x="-450" y="-450" width={900} height={900} fill="white" />
              <circle cx="0" cy="0" r={planet_radius} fill="#AAAAAA" />
            </mask>
            { /* Draw all the segments that is not selected behind the planet (some of these will get drawn over by the planet) */
              backSegments.filter((s) => s.ownerUID !== selectedSatellite?.UID).map((segment, index) => {
                return(
                <polyline key={index}
                    points={segment.segments.map(p => `${p.x * scale},${p.y * scale}`).join(" ")}
                    fill="none"
                    stroke={"dimgrey"}
                    strokeWidth={3}
                />);
                })
            }
            { /* Draw segments that belong to the selected satellite so its in front of the other back lines */
              backSegments.filter((s) => s.ownerUID === selectedSatellite?.UID).map((segment, index) => {
                return(
                  <polyline key={index}
                  points={segment.segments.map(p => `${p.x * scale},${p.y * scale}`).join(" ")}
                  fill="none"
                  stroke={"darkgreen"}
                  strokeWidth={3}
                  />
                );
              }
            )}


            { /* Draw the planet */
              <image
              href={resolveAsset(current_planet_theme)}
              x={-planet_radius}
              y={-planet_radius}
              width={planet_radius * 2}
              height={planet_radius * 2}
              />
            }
            { /* Draw all not selected segments thats in front of the planet */
              frontSegments.filter((s) => s.ownerUID !== selectedSatellite?.UID).map((segment, index) => {
                return(
                  <polyline key={index}
                    points={segment.segments.map(p => `${p.x * scale},${p.y * scale}`).join(" ")}
                    fill="none"
                    stroke={"lightgrey"} // color segments if a satellite has been clicked on
                    strokeWidth={3}
                  />
                );
              })
            }
            { /* Draw segments that belong to the selected satellite so its in front of the other front lines */
              frontSegments.filter((s) => s.ownerUID === selectedSatellite?.UID).map((segment, index) => {
                return (
                  <polyline key={index}
                    points={segment.segments.map(p => `${p.x * scale},${p.y * scale}`).join(" ")}
                    fill="none"
                    stroke={"lime"} // color segments if a satellite has been clicked on
                    strokeWidth={3}
                  />
                );
              })
            }
            { /* Apoapsis marker */
              selectedSatellite ? <circle cx={selectedSatellite.orbit_data.apoapsis_position?.x} cy={selectedSatellite.orbit_data.apoapsis_position?.y} r={12} fill="red" /> : null
            }
            {
              selectedSatellite ? <text x={selectedSatellite.orbit_data.apoapsis_position?.x - 12} y={selectedSatellite.orbit_data.apoapsis_position?.y} fill={"white"}>{`Ap`}</text> : null
            }
            { /* Periapsis marker */
              selectedSatellite ? <circle cx={selectedSatellite.orbit_data.periapsis_position?.x} cy={selectedSatellite.orbit_data.periapsis_position?.y} r={8} fill="blue" /> : null
            }
            {
              selectedSatellite ? <text x={selectedSatellite.orbit_data.periapsis_position?.x - 8} y={selectedSatellite.orbit_data.periapsis_position?.y} fill={"white"}>{`Pe`}</text> : null
            }
            {
              weather_nodes.map((node, index) => {
                return(
                  <>
                    <image key={index}
                      href={resolveAsset(node.asset_icon)}
                      x={node.position.x - weather_node_size/2}
                      y={node.position.y - weather_node_size/2}
                      height={weather_node_size}
                      width={weather_node_size}
                    />
                    <text x={node.position.x - weather_node_size/2} y={node.position.y - weather_node_size/2} fill={"white"}>{`${node.node_type.slice(0, 2)}`}</text>
                  </>
                );
              })
            }
            { /* Draw all satellites */
              satellites.map((satellite: Satellite) => {
                return (
                  <image key={satellite.name}
                    href={resolveAsset(current_planet_theme)}
                    x={satellite.orbit_data.position?.x * scale - satelliteImageSize/2}
                    y={satellite.orbit_data.position?.y * scale - satelliteImageSize/2}
                    width={`${satelliteImageSize}px`}
                    height={`${satelliteImageSize}px`}
                    mask={satellite.orbit_data.position?.z > 0? "" : "url(#mask)"} // if the satellite is "behind" the planet, make it semi-transparent
                  />
                );
              })
            }
          </svg>
        </Stack>
      }
      </Box>
    </Box>
  );
};

/**
 * @file
 * @copyright 2022
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */
import { Tooltip } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type FlockPanelData = {
  category: string;
  category_lengths: FlockCategoryLengths;
  drones: FlockDroneInfo[];
  enemies: FlockEnemy[];
  partitions: FlockTraceInfo[];
  stats: FlockStat[];
  structures: FlockStructureInfo[];
  vitals: FlockVitals;
};

type FlockMobInfo = {
  area: string;
  health: number;
  name: string;
  ref: string;
  resources: number;
};

type FlockTraceInfo = FlockMobInfo & {
  host?: string;
};

type FlockDroneInfo = FlockMobInfo & {
  controller_ref?: string;
  task: string;
};

type FlockStructureInfo = {
  area: string;
  compute: number;
  desc: string;
  health: number;
  name: string;
  ref: string;
};

type FlockEnemy = {
  area: string;
  name: string;
  ref: string;
};

type FlockCategoryLengths = {
  drones: number;
  enemies: number;
  structures: number;
  traces: number;
};

type FlockStat = {
  name: string;
  value: number;
};

type FlockVitals = {
  name: string;
};

export const FlockPanel = (props) => {
  const { act, data } = useBackend<FlockPanelData>();
  const [sortBy, setSortBy] = useLocalState('sortBy', 'resources');
  const {
    vitals,
    partitions,
    drones,
    structures,
    enemies,
    stats,
    category_lengths,
    category,
  } = data;

  return (
    <Window
      theme="flock"
      title={'Flockmind ' + vitals.name}
      width={600}
      height={450}
    >
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={category === 'drones'}
            onClick={() => {
              act('change_tab', { tab: 'drones' });
            }}
          >
            Drones {`(${category_lengths['drones']})`}
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'traces'}
            onClick={() => {
              act('change_tab', { tab: 'traces' });
            }}
          >
            Partitions {`(${category_lengths['traces']})`}
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'structures'}
            onClick={() => {
              act('change_tab', { tab: 'structures' });
            }}
          >
            Structures {`(${category_lengths['structures']})`}
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'enemies'}
            onClick={() => {
              act('change_tab', { tab: 'enemies' });
            }}
          >
            Enemies {`(${category_lengths['enemies']})`}
          </Tabs.Tab>
          <Tabs.Tab
            selected={category === 'stats'}
            onClick={() => {
              act('change_tab', { tab: 'stats' });
            }}
          >
            Stats
          </Tabs.Tab>
        </Tabs>

        {category === 'drones' && (
          <Box>
            <Dropdown
              options={['name', 'health', 'resources', 'area']}
              selected="resources"
              onSelected={(value) => setSortBy(value)}
            />
            <FlockDrones drones={drones} sortBy={sortBy} />
          </Box>
        )}
        {category === 'traces' && <FlockPartitions partitions={partitions} />}
        {category === 'structures' && (
          <FlockStructures structures={structures} />
        )}
        {category === 'enemies' && <FlockEnemies enemies={enemies} />}
        {category === 'stats' && <FlockStats stats={stats} />}
      </Window.Content>
    </Window>
  );
};

type FlockPartitionsProps = {
  partitions: FlockTraceInfo[];
};

const FlockPartitions = (props: FlockPartitionsProps) => {
  const { act } = useBackend();
  const { partitions } = props;
  return (
    <Stack vertical>
      {partitions.map((partition) => {
        return (
          <Stack.Item key={partition.ref}>
            <Stack align="center" height="100%">
              {/* name */}
              <Stack.Item width="20%" height="100%">
                <Section align="center" height="100%">
                  {partition.name}
                </Section>
              </Stack.Item>
              {/* show host if they are in one */}
              <Stack.Item height="100%" grow={1}>
                <Section height="100%">
                  {partition.host && (
                    <Stack>
                      <Stack.Item>
                        <Icon name="wifi" size={3} />
                      </Stack.Item>
                      <Stack.Item>
                        <Stack vertical align="center">
                          <Stack.Item>{partition.host}</Stack.Item>
                          <Stack.Item>
                            {partition.health}
                            <Icon name="heart" />
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    </Stack>
                  )}
                </Section>
              </Stack.Item>
              {/* buttons */}
              <Stack.Item height="100%">
                <Section height="100%">
                  <Stack>
                    {partition.host && (
                      <Stack.Item>
                        <Button
                          onClick={() =>
                            act('eject_trace', { origin: partition.ref })
                          }
                        >
                          Eject
                        </Button>
                      </Stack.Item>
                    )}
                    <Stack.Item>
                      <Button
                        onClick={() =>
                          act('promote_trace', { origin: partition.ref })
                        }
                      >
                        Promote sentience
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        onClick={() =>
                          act('delete_trace', { origin: partition.ref })
                        }
                      >
                        Remove sentience
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        onClick={() =>
                          act('jump_to', { origin: partition.ref })
                        }
                      >
                        Jump
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

// basic sorting function for numbers and strings
const compare = function (a, b, sortBy) {
  if (!isNaN(a[sortBy]) && !isNaN(b[sortBy])) {
    return b[sortBy] - a[sortBy];
  }
  return ('' + a[sortBy]).localeCompare(b[sortBy]);
};

// maps drone tasks to icons
const iconLookup = {
  thinking: 'brain',
  shooting: 'bolt',
  rummaging: 'dumpster',
  wandering: 'route',
  building: 'hammer',
  nesting: 'hammer',
  harvesting: 'cogs',
  controlled: 'wifi',
  replicating: 'egg',
  rallying: 'map-marker',
  'opening container': 'box-open',
  butchering: 'recycle',
  repairing: 'tools',
  capturing: 'bars',
  depositing: 'border-style',
  observing: 'eye',
  deconstructing: 'trash',
  hibernating: 'stop-circle',
};
const taskIcon = function (task) {
  let iconString = iconLookup[task];
  if (iconString) {
    return <Icon size={3} name={iconString} />;
  }
  return '';
};

const capitalizeString = function (string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
};

type FlockDronesProps = {
  drones: FlockDroneInfo[];
  sortBy: string;
};

const FlockDrones = (props: FlockDronesProps) => {
  const { act } = useBackend();
  const { drones, sortBy } = props;
  return (
    <Stack vertical>
      {drones
        .sort((a, b) => compare(a, b, sortBy))
        .map((drone) => {
          return (
            <Stack.Item key={drone.ref}>
              <Stack>
                {/* name, health and resources */}
                <Stack.Item width="20%">
                  <Section height="100%">
                    <Stack vertical align="center">
                      <Stack.Item>{drone.name}</Stack.Item>
                      <Stack.Item>
                        {drone.health}
                        <Icon name="heart" /> {drone.resources}
                        <Icon name="cog" />
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
                {/* area and task */}
                <Stack.Item grow={1}>
                  <Section height="100%">
                    <Stack align="center">
                      <Stack.Item width="50px">
                        <Box align="center">{taskIcon(drone.task)}</Box>
                      </Stack.Item>
                      <Stack.Item>
                        <b>{drone.area}</b> <br />{' '}
                        {drone.task && capitalizeString(drone.task)}
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
                {/* buttons */}
                <Stack.Item>
                  <Section height="100%">
                    <Stack>
                      {drone.task === 'controlled' && (
                        <Stack.Item>
                          <Button
                            onClick={() =>
                              act('eject_trace', {
                                origin: drone.controller_ref,
                              })
                            }
                          >
                            Eject Trace
                          </Button>
                        </Stack.Item>
                      )}
                      <Stack.Item>
                        <Button
                          onClick={() => act('rally', { origin: drone.ref })}
                        >
                          Rally
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          onClick={() => act('jump_to', { origin: drone.ref })}
                        >
                          Jump
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          );
        })}
    </Stack>
  );
};

type FlockStructuresProps = {
  structures: FlockStructureInfo[];
};

// TODO: actual structure information (power draw/generation etc.)
const FlockStructures = (props: FlockStructuresProps) => {
  const { act } = useBackend();
  const { structures } = props;
  return (
    <Stack vertical>
      {structures.map((structure) => {
        return (
          <Stack.Item key={structure.ref}>
            <Stack>
              {/* name and health */}
              <Stack.Item width="30%">
                <Tooltip position="bottom" content={structure.desc}>
                  <Section position="relative">
                    <Stack vertical align="center">
                      <Stack.Item>{structure.name}</Stack.Item>
                      <Stack.Item>
                        {structure.health} <Icon name="heart" />
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Tooltip>
              </Stack.Item>
              <Stack.Item grow={1}>
                <Section height="100%">
                  {structure.compute > 0 &&
                    'Bandwidth Provided: ' + structure.compute}
                  {structure.compute < 0 &&
                    'Bandwidth Cost: ' + -structure.compute}
                </Section>
              </Stack.Item>
              {/* buttons */}
              <Stack.Item>
                <Section height="100%">
                  <Stack>
                    {structure.name === 'Construction Tealprint' && (
                      <Stack.Item>
                        <Button
                          onClick={() =>
                            act('cancel_tealprint', { origin: structure.ref })
                          }
                        >
                          Cancel
                        </Button>
                      </Stack.Item>
                    )}
                    <Stack.Item>
                      <Button
                        onClick={() =>
                          act('jump_to', { origin: structure.ref })
                        }
                      >
                        Jump
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

type FlockEnemiesProps = {
  enemies: FlockEnemy[];
};

const FlockEnemies = (props: FlockEnemiesProps) => {
  const { act } = useBackend();
  const { enemies } = props;
  return (
    <Stack vertical>
      {enemies.map((enemy) => {
        return (
          <Stack.Item key={enemy.ref}>
            <Stack>
              {/* name and remove button */}
              <Stack.Item width="30%">
                <Section height="100%">{enemy.name}</Section>
              </Stack.Item>
              {/* area and jump button */}
              <Stack.Item grow={1}>
                <Section height="100%">
                  <Stack>
                    <Stack.Item grow={1}>
                      <b>{enemy.area}</b>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section height="100%">
                  <Stack>
                    <Stack.Item>
                      <Button
                        icon="times"
                        onClick={() =>
                          act('remove_enemy', { origin: enemy.ref })
                        }
                      >
                        Remove
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        onClick={() => act('jump_to', { origin: enemy.ref })}
                      >
                        Jump
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

type FlockStatsProps = {
  stats: FlockStat[];
};

const FlockStats = (props: FlockStatsProps) => {
  const { stats } = props;
  return (
    <Stack vertical>
      {stats.map((stat) => {
        return (
          <Stack.Item key={stat.name}>
            <Stack>
              <Stack.Item width="100%">
                <Section height="100%">
                  <Stack vertical align="left">
                    <Stack.Item>
                      {stat.name} {stat.value}
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

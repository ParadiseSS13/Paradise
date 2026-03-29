// code\modules\mob\living\silicon\robot\drone\drone_console.dm
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Flex,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const DroneConsole = (props) => {
  return (
    <Window width={420} height={500}>
      <Window.Content scrollable>
        <Fabricator />
        <DroneList />
      </Window.Content>
    </Window>
  );
};

const Fabricator = (props) => {
  const { act, data } = useBackend();
  const { drone_fab, fab_power, drone_prod, drone_progress } = data;

  let FabDetected = () => {
    if (drone_fab) {
      return (
        <LabeledList>
          <LabeledList.Item label="External Power">
            <Box color={fab_power ? 'good' : 'bad'}>[ {fab_power ? 'Online' : 'Offline'} ]</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Drone Production">
            <ProgressBar
              value={drone_progress / 100}
              ranges={{
                good: [0.7, Infinity],
                average: [0.4, 0.7],
                bad: [-Infinity, 0.4],
              }}
            />
          </LabeledList.Item>
        </LabeledList>
      );
    } else {
      return (
        <NoticeBox textAlign="center" danger={1}>
          <Flex inline={1} direction="column">
            <Flex.Item>FABRICATOR NOT DETECTED.</Flex.Item>
            <Flex.Item>
              <Button icon="search" content="Search" onClick={() => act('find_fab')} />
            </Flex.Item>
          </Flex>
        </NoticeBox>
      );
    }
  };

  return (
    <Section
      title="Drone Fabricator"
      buttons={
        <Button
          icon="power-off"
          content={drone_prod ? 'Online' : 'Offline'}
          color={drone_prod ? 'green' : 'red'}
          onClick={() => act('toggle_fab')}
        />
      }
    >
      {FabDetected()}
    </Section>
  );
};

const DroneList = (props) => {
  const { act, data } = useBackend();
  const { drones, area_list, selected_area, ping_cd } = data;

  let status = (stat, client) => {
    let box_color;
    let text;
    if (stat === 2) {
      // Dead
      box_color = 'bad';
      text = 'Disabled';
    } else if (stat === 1 || !client) {
      // Unconscious or SSD
      box_color = 'average';
      text = 'Inactive';
    } else {
      // Alive
      box_color = 'good';
      text = 'Active';
    }
    return <Box color={box_color}>{text}</Box>;
  };

  const Divide = () => {
    if (drones.length) {
      return (
        <Box py={0.2}>
          <Divider />
        </Box>
      );
    }
  };

  return (
    <Section title="Maintenance Units">
      <Flex>
        <Flex.Item>Request Drone presence in area:&nbsp;</Flex.Item>
        <Flex.Item>
          <Dropdown
            options={area_list}
            selected={selected_area}
            width="125px"
            onSelected={(value) =>
              act('set_area', {
                area: value,
              })
            }
          />
        </Flex.Item>
      </Flex>
      <Button
        content="Send Ping"
        icon="broadcast-tower"
        disabled={ping_cd || !drones.length}
        title={drones.length ? null : 'No active drones!'}
        fluid
        textAlign="center"
        py={0.4}
        mt={0.6}
        onClick={() => act('ping')}
      />

      <Divide />

      {drones.map((drone) => (
        <Section
          key={drone.name}
          title={toTitleCase(drone.name)}
          buttons={
            <Stack>
              <Stack.Item>
                <Button
                  icon="sync"
                  content="Resync"
                  disabled={drone.stat === 2 || drone.sync_cd}
                  onClick={() =>
                    act('resync', {
                      uid: drone.uid,
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item>
                <Button.Confirm
                  icon="power-off"
                  content="Recall"
                  disabled={drone.stat === 2 || drone.pathfinding}
                  tooltip={drone.pathfinding ? 'This drone is currently pathfinding, please wait.' : null}
                  tooltipPosition="left"
                  color="bad"
                  onClick={() =>
                    act('recall', {
                      uid: drone.uid,
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Status">{status(drone.stat, drone.client)}</LabeledList.Item>
            <LabeledList.Item label="Integrity">
              <ProgressBar
                value={drone.health}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.4, 0.7],
                  bad: [-Infinity, 0.4],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Charge">
              <ProgressBar
                value={drone.charge}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.4, 0.7],
                  bad: [-Infinity, 0.4],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Location">{drone.location}</LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </Section>
  );
};

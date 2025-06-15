import { useState } from 'react';
import { Box, Button, LabeledList, ProgressBar, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NanoMap } from '../components';
import { Window } from '../layouts';

export const SatelliteControl = (props) => {
  const { act, data } = useBackend();
  const [tabIndex, setTabIndexInternal] = useState(data.tabIndex);
  const setTabIndex = (index) => {
    setTabIndexInternal(index);
    act('set_tab_index', { tab_index: index });
  };
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <SatelliteControlSatellitesList />;
      case 1:
        return <SatelliteControlMapView />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={800} height={600}>
      <Window.Content>
        <Stack fill vertical scrollable>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab key="Satellites" icon="table" selected={0 === tabIndex} onClick={() => setTabIndex(0)}>
                Satellites
              </Tabs.Tab>
              <Tabs.Tab key="MapView" icon="map-marked-alt" selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
                Map View
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          {decideTab(tabIndex)}
          <SatelliteControlFooter />
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const SatelliteControlSatellitesList = (props) => {
  const { act, data } = useBackend();
  const { satellites } = data;
  return (
    <Section title="Satellite Network Control">
      <LabeledList>
        {satellites.map((sat) => (
          <LabeledList.Item key={sat.id} label={'#' + sat.id}>
            {sat.mode}{' '}
            <Button
              content={sat.active ? 'Deactivate' : 'Activate'}
              icon={'arrow-circle-right'}
              onClick={() => act('toggle', { id: sat.id })}
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

export const SatelliteControlMapView = (props) => {
  const { act, data } = useBackend();
  const { satellites, has_goal, defended, collisions, fake_meteors, zoom, offsetX, offsetY } = data;
  let i = 0;
  return (
    <Box height="100vh" mb="0.5rem" overflow="hidden">
      <NanoMap
        zoom={zoom}
        offsetX={offsetX}
        offsetY={offsetY}
        onZoom={(zoom) => act('set_zoom', { zoom })}
        onOffsetChange={(e, state) =>
          act('set_offset', {
            offset_x: state.offsetX,
            offset_y: state.offsetY,
          })
        }
      >
        {satellites.map((sat) => (
          <NanoMap.MarkerIcon
            key={i++}
            x={sat.x}
            y={sat.y}
            icon="satellite"
            tooltip={sat.active ? 'Shield Satellite' : 'Inactive Shield Satellite'}
            color={sat.active ? 'white' : 'grey'}
            onClick={() => act('toggle', { id: sat.id })}
          />
        ))}
        {has_goal &&
          defended.map((meteor) => (
            <NanoMap.MarkerIcon
              key={i++}
              x={meteor.x}
              y={meteor.y}
              icon="circle"
              tooltip="Successful Defense"
              color="blue"
            />
          ))}
        {has_goal &&
          collisions.map((meteor) => (
            <NanoMap.MarkerIcon key={i++} x={meteor.x} y={meteor.y} icon="x" tooltip="Meteor Hit" color="red" />
          ))}
        {has_goal &&
          fake_meteors.map((meteor) => (
            <NanoMap.MarkerIcon
              key={i++}
              x={meteor.x}
              y={meteor.y}
              icon="meteor"
              tooltip="Incoming Meteor"
              color="white"
            />
          ))}
      </NanoMap>
    </Box>
  );
};

export const SatelliteControlFooter = (props) => {
  const { act, data } = useBackend();
  const { notice, notice_color, has_goal, coverage, coverage_goal, testing } = data;

  return (
    <>
      {has_goal && (
        <Stack.Item>
          <Section title="Station Shield Coverage">
            <Stack fill>
              <Stack.Item grow={1}>
                <ProgressBar color={coverage >= coverage_goal ? 'good' : 'average'} value={coverage} maxValue={100}>
                  {coverage}%
                </ProgressBar>
              </Stack.Item>
              <Stack.Item>
                <Button content="Check coverage" disabled={testing} onClick={() => act('begin_test')} />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
      <Stack.Item color={notice_color}>{notice}</Stack.Item>
    </>
  );
};

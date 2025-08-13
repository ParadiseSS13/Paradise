import { filter, sortBy } from 'common/collections';
import { useState } from 'react';
import { Button, ByondUi, Input, NoticeBox, Section, Stack, Tabs } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { NanoMap } from '../components';
import { Window } from '../layouts';

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
const prevNextCamera = (cameras, activeCamera) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex((camera) => camera.name === activeCamera.name);
  return [cameras[index - 1]?.name, cameras[index + 1]?.name];
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
const selectCameras = (cameras, searchText = '') => {
  let queriedCameras = filter(cameras, (camera) => !!camera.name);
  if (searchText) {
    const testSearch = createSearch(searchText, (camera) => camera.name);
    queriedCameras = filter(queriedCameras, testSearch);
  }
  queriedCameras = sortBy(queriedCameras, (camera) => camera.name);

  return queriedCameras;
};

export const CameraConsole220 = (props) => {
  return (
    <Window width={1170} height={775}>
      <Window.Content>
        <CameraContent />
      </Window.Content>
    </Window>
  );
};

export const CameraContent = (props) => {
  const [searchText, setSearchText] = useState('');
  const [tab, setTab] = useState('Map');
  const decideTab = (tab) => {
    switch (tab) {
      case 'List':
        return <CameraListSelector searchText={searchText} setSearchText={setSearchText} />;
      case 'Map':
        return <CameraMapSelector />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Stack fill g={0}>
      <Stack.Item grow minWidth={0}>
        <Stack fill vertical g={0}>
          <Stack.Item textAlign="center">
            <Tabs fluid>
              <Tabs.Tab key="Map" icon="map-marked-alt" selected={tab === 'Map'} onClick={() => setTab('Map')}>
                Карта
              </Tabs.Tab>
              <Tabs.Tab key="List" icon="table" selected={tab === 'List'} onClick={() => setTab('List')}>
                Список
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{decideTab(tab)}</Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow={tab === 'Map' ? 1.5 : 3}>
        <CameraControls searchText={searchText} />
      </Stack.Item>
    </Stack>
  );
};

export const CameraMapSelector = (props) => {
  const { act, data } = useBackend();
  const cameras = selectCameras(data.cameras);
  const [zoom, setZoom] = useState(1);
  const { mapRef, activeCamera, stationLevel } = data;
  const [prevCameraName, nextCameraName] = prevNextCamera(cameras, activeCamera);

  return (
    <NanoMap onZoom={setZoom}>
      {cameras
        .filter((cam) => cam.z === stationLevel)
        .map((cm) => (
          <NanoMap.NanoButton
            activeCamera={activeCamera}
            key={cm.ref}
            x={cm.x}
            y={cm.y}
            zoom={zoom}
            icon="circle"
            tooltip={cm.name}
            name={cm.name}
            color={'blue'}
            status={cm.status}
          />
        ))}
    </NanoMap>
  );
};

const CameraListSelector = (props) => {
  const { act, data, config } = useBackend();
  const { mapRef, activeCamera } = data;
  const [searchText, setSearchText] = useState('');
  const cameras = selectCameras(data.cameras, searchText);

  return (
    <Stack fill vertical>
      <Stack.Item mt={1}>
        <Input
          autoFocus
          expensive
          fluid
          placeholder="Search for a camera"
          onChange={setSearchText}
          value={searchText}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {cameras.map((camera) => (
            // We're not using the component here because performance
            // would be absolutely abysmal (50+ ms for each re-render).
            <div
              key={camera.name}
              title={camera.name}
              className={classes([
                'Button',
                'Button--fluid',
                'Button--color--transparent',
                'Button--ellipsis',
                activeCamera?.name === camera.name ? 'Button--selected' : 'candystripe',
              ])}
              onClick={() =>
                act('switch_camera', {
                  name: camera.name,
                })
              }
            >
              {camera.name}
            </div>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const CameraControls = (props) => {
  const { act, data } = useBackend();
  const { activeCamera, can_spy, mapRef } = data;
  const { searchText } = props;

  const cameras = selectCameras(data.cameras, searchText);
  const [prevCamera, nextCamera] = prevNextCamera(cameras, activeCamera);

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <Stack fill>
            <Stack.Item grow>
              {activeCamera?.status ? (
                <NoticeBox info>{activeCamera.name}</NoticeBox>
              ) : (
                <NoticeBox danger>No input signal</NoticeBox>
              )}
            </Stack.Item>
            <Stack.Item>
              {!!can_spy && (
                <Button icon="magnifying-glass" tooltip="Track Person" onClick={() => act('start_tracking')} />
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="chevron-left"
                disabled={!prevCamera}
                onClick={() =>
                  act('switch_camera', {
                    name: prevCamera,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="chevron-right"
                disabled={!nextCamera}
                onClick={() =>
                  act('switch_camera', {
                    name: nextCamera,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <ByondUi
            height="100%"
            width="100%"
            params={{
              id: mapRef,
              type: 'map',
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

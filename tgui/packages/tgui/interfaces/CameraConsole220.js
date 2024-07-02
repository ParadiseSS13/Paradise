import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, ByondUi, Input, Section, Stack, NanoMap, Tabs, Icon, Box } from '../components';
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
  const testSearch = createSearch(searchText, (camera) => camera.name);
  return flow([
    // Null camera filter
    filter((camera) => camera?.name),
    // Optional search term
    searchText && filter(testSearch),
    // Slightly expensive, but way better than sorting in BYOND
    sortBy((camera) => camera.name),
  ])(cameras);
};

export const CameraConsole220 = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <CameraConsoleMapContent />;
      case 1:
        return <CameraConsoleOldContent />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={1170} height={755}>
      <Window.Content>
        <Stack>
          <Box fillPositionedParent>
            <Stack.Item width={tabIndex === 1 ? '222px' : '475px'} textAlign="center">
              <Tabs fluid ml={tabIndex === 1 ? 1 : 0} mt={tabIndex === 1 ? 1 : 0}>
                <Tabs.Tab key="Map" selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
                  <Icon name="map-marked-alt" /> Карта
                </Tabs.Tab>
                <Tabs.Tab key="List" selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
                  <Icon name="table" /> Список
                </Tabs.Tab>
              </Tabs>
            </Stack.Item>
            {decideTab(tabIndex)}
          </Box>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const CameraConsoleMapContent = (props, context) => {
  const { act, data } = useBackend(context);
  const cameras = selectCameras(data.cameras);
  const [zoom, setZoom] = useLocalState(context, 'zoom', 1);
  const { mapRef, activeCamera, stationLevel } = data;
  const [prevCameraName, nextCameraName] = prevNextCamera(cameras, activeCamera);
  return (
    <Stack fill>
      <Stack.Item
        height="100%"
        style={{
          flex: '0 0 474px',
        }}
      >
        <NanoMap onZoom={(v) => setZoom(v)}>
          {cameras
            .filter((cam) => cam.z === stationLevel)
            .map((cm) => (
              <NanoMap.NanoButton
                activeCamera={activeCamera}
                key={cm.ref}
                x={cm.x}
                y={cm.y}
                context={context}
                zoom={zoom}
                icon="circle"
                tooltip={cm.name}
                name={cm.name}
                color={'blue'}
                status={cm.status}
              />
            ))}
        </NanoMap>
      </Stack.Item>
      <Stack.Item height="100%" m={0.1} className="CameraConsole__right_map">
        <div className="CameraConsole__header">
          <div className="CameraConsole__toolbar">
            <b>Камера: </b>
            {(activeCamera && activeCamera.name) || '—'}
          </div>
          <div className="CameraConsole__toolbarRight">
            <Button
              icon="chevron-left"
              disabled={!prevCameraName}
              onClick={() =>
                act('switch_camera', {
                  name: prevCameraName,
                })
              }
            />
            <Button
              icon="chevron-right"
              disabled={!nextCameraName}
              onClick={() =>
                act('switch_camera', {
                  name: nextCameraName,
                })
              }
            />
          </div>
        </div>
        <ByondUi
          className="CameraConsole__map"
          overflow="hidden"
          params={{
            id: mapRef,
            type: 'map',
          }}
        />
      </Stack.Item>
    </Stack>
  );
};

export const CameraConsoleOldContent = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { mapRef, activeCamera } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const cameras = selectCameras(data.cameras, searchText);
  const [prevCameraName, nextCameraName] = prevNextCamera(cameras, activeCamera);
  return (
    <Stack.Item>
      <div className="CameraConsole__left">
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item>
              <Input width="215px" placeholder="Найти камеру" onInput={(e, value) => setSearchText(value)} />
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
                      camera.status ? 'Button--color--transparent' : 'Button--color--danger',
                      'Button--ellipsis',
                      activeCamera && camera.name === activeCamera.name && 'Button--selected',
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
        </Window.Content>
      </div>
      <div className="CameraConsole__right">
        <div className="CameraConsole__toolbar">
          <b>Камера: </b>
          {(activeCamera && activeCamera.name) || '—'}
        </div>
        <div className="CameraConsole__toolbarRight">
          <Button
            icon="chevron-left"
            disabled={!prevCameraName}
            onClick={() =>
              act('switch_camera', {
                name: prevCameraName,
              })
            }
          />
          <Button
            icon="chevron-right"
            disabled={!nextCameraName}
            onClick={() =>
              act('switch_camera', {
                name: nextCameraName,
              })
            }
          />
        </div>
        <ByondUi
          className="CameraConsole__map"
          params={{
            id: mapRef,
            type: 'map',
          }}
        />
      </div>
    </Stack.Item>
  );
};

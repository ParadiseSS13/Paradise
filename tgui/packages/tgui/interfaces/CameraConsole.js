import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, ByondUi, Input, Section, Box, NanoMap, Tabs, Icon } from '../components';
import { refocusLayout, Window } from '../layouts';

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
const prevNextCamera = (cameras, activeCamera) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex(camera => (
    camera.name === activeCamera.name
  ));
  return [
    cameras[index - 1]?.name,
    cameras[index + 1]?.name,
  ];
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
const selectCameras = (cameras, searchText = '') => {
  const testSearch = createSearch(searchText, camera => camera.name);
  return flow([
    // Null camera filter
    filter(camera => camera?.name),
    // Optional search term
    searchText && filter(testSearch),
    // Slightly expensive, but way better than sorting in BYOND
    sortBy(camera => camera.name),
  ])(cameras);
};

export const CameraConsole = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = index => {
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
    <Window resizable>
      <Window.Content>
        <Box fillPositionedParent overflow="hidden">
          <Tabs>
            <Tabs.Tab
              key="Map"
              selected={0 === tabIndex}
              onClick={() => setTabIndex(0)}>
              <Icon name="map-marked-alt" /> Map
            </Tabs.Tab>
            <Tabs.Tab
              key="List"
              selected={1 === tabIndex}
              onClick={() => setTabIndex(1)}>
              <Icon name="table" /> List
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

export const CameraConsoleMapContent = (props, context) => {
  const { act, data, config } = useBackend(context);
  const cameras = selectCameras(data.cameras);
  const [zoom, setZoom] = useLocalState(context, 'zoom', 1);
  const { mapRef, activeCamera, stationLevel } = data;
  const [
    prevCameraName,
    nextCameraName,
  ] = prevNextCamera(cameras, activeCamera);

  return (
    <Box height="100%" display="flex">
      <Box height="100%" flex="0 0 500px" display="flex">
        <NanoMap onZoom={v => setZoom(v)}>
          {cameras.filter(cam => cam.z === stationLevel).map(cm => (
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
              color={"blue"}
              status={cm.status}
            />
          ))}
        </NanoMap>
      </Box>
      <Box height="100%" resizable className="CameraConsole__new__right">
        <div className="CameraConsole__header">
          <div className="CameraConsole__title">
            <b>Camera: </b>
            {activeCamera
              && activeCamera.name
              || '—'}
          </div>
          <div className="CameraConsole__toolbarRight">
            <Button
              icon="chevron-left"
              disabled={!prevCameraName}
              onClick={() => act('switch_camera', {
                name: prevCameraName,
              })} />
            <Button
              icon="chevron-right"
              disabled={!nextCameraName}
              onClick={() => act('switch_camera', {
                name: nextCameraName,
              })} />
          </div>
        </div>
        <ByondUi resizable
          className="CameraConsole__map"
          overflow="hidden"
          params={{
            id: mapRef,
            parent: config.window,
            type: 'map',
          }} />
      </Box>
    </Box>
  );
};

export const CameraConsoleOldContent = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { mapRef, activeCamera } = data;
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const cameras = selectCameras(data.cameras, searchText);
  const [
    prevCameraName,
    nextCameraName,
  ] = prevNextCamera(cameras, activeCamera);
  return (
    <Box>
      <div className="CameraConsole__left">
        <Window.Content scrollable>
          <Fragment>
            <Input
              fluid
              mb={1}
              placeholder="Search for a camera"
              onInput={(e, value) => setSearchText(value)} />
            <Section>
              {cameras.map(camera => (
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
                    activeCamera
                    && camera.name === activeCamera.name
                    && 'Button--selected',
                  ])}
                  onClick={() => {
                    refocusLayout();
                    act('switch_camera', {
                      name: camera.name,
                    });
                  }}>
                  {camera.name}
                </div>
              ))}
            </Section>
          </Fragment>
        </Window.Content>
      </div>
      <div className="CameraConsole__right">
        <div className="CameraConsole__toolbar">
          <b>Camera: </b>
          {activeCamera
            && activeCamera.name
            || '—'}
        </div>
        <div className="CameraConsole__toolbarRight">
          <Button
            icon="chevron-left"
            disabled={!prevCameraName}
            onClick={() => act('switch_camera', {
              name: prevCameraName,
            })} />
          <Button
            icon="chevron-right"
            disabled={!nextCameraName}
            onClick={() => act('switch_camera', {
              name: nextCameraName,
            })} />
        </div>
        <ByondUi
          className="CameraConsole__map"
          params={{
            id: mapRef,
            parent: config.window,
            type: 'map',
          }} />
      </div>
    </Box>
  );
};

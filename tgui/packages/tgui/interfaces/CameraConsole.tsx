import { filter, sort, sortBy } from 'common/collections';
import { useState } from 'react';
import { Button, ByondUi, Input, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

/**
 * A crutch which, after selecting a camera in the list,
 * allows you to scroll further,
 * as the focus does not shift to the button using overflow.
 * Please, delete that shit if there's a better way.
 */
String.prototype.trimLongStr = function (length: number) {
  return this.length > length ? this.substring(0, length) + '...' : this;
};

type Data = {
  mapRef: string;
  activeCamera: Camera;
  cameras: Camera[];
};

type Camera = {
  name: string;
};

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
const prevNextCamera = (cameras: Camera[], activeCamera: Camera) => {
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
const selectCameras = (cameras: Camera[], searchText = ''): Camera[] => {
  let queriedCameras = filter(cameras, (camera: Camera) => !!camera.name);
  if (searchText) {
    const testSearch = createSearch(searchText, (camera: Camera) => camera.name);
    queriedCameras = filter(queriedCameras, testSearch);
  }
  queriedCameras = sortBy(queriedCameras, (camera: Camera) => camera.name);

  return queriedCameras;
};

export const CameraConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const { mapRef, activeCamera } = data;
  const cameras = selectCameras(data.cameras);
  const [prevCameraName, nextCameraName] = prevNextCamera(cameras, activeCamera);
  return (
    <Window width={870} height={708}>
      <div className="CameraConsole__left">
        <Window.Content>
          <Stack fill vertical>
            <CameraConsoleContent />
          </Stack>
        </Window.Content>
      </div>
      <div className="CameraConsole__right">
        <div className="CameraConsole__toolbar">
          <b>Camera: </b>
          {(activeCamera && activeCamera.name) || '—'}
        </div>
        <div className={classes(['CameraConsole__toolbar', 'CameraConsole__toolbar--right'])}>
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
    </Window>
  );
};

export const CameraConsoleContent = (props) => {
  const { act, data } = useBackend<Data>();
  const [searchText, setSearchText] = useState('');
  const { activeCamera } = data;
  const cameras = selectCameras(data.cameras, searchText);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input fluid placeholder="Search for a camera" onChange={(value) => setSearchText(value)} />
      </Stack.Item>
      <Stack.Item grow m={0}>
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
                activeCamera && camera.name === activeCamera.name ? 'Button--selected' : 'Button--color--transparent',
              ])}
              onClick={() =>
                act('switch_camera', {
                  name: camera.name,
                })
              }
            >
              {camera.name.trimLongStr(23)}
            </div>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

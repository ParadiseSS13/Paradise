import { useState } from 'react';
import { Box, Button, Icon, Table, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NanoMap } from '../components';
import { Window } from '../layouts';

const getStatus = (level) => {
  if (level === 0) {
    return <Box color="green">Good</Box>;
  }
  if (level === 1) {
    return (
      <Box color="orange" bold>
        Warning
      </Box>
    );
  }
  if (level === 2) {
    return (
      <Box color="red" bold>
        DANGER
      </Box>
    );
  }
};

const getStatusColour = (level) => {
  if (level === 0) {
    return 'green';
  }
  if (level === 1) {
    return 'orange';
  }
  if (level === 2) {
    return 'red';
  }
};

export const AtmosControl = (props) => {
  const { act, data } = useBackend();
  const [tabIndex, setTabIndex] = useState(0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <AtmosControlDataView />;
      case 1:
        return <AtmosControlMapView />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={800} height={600}>
      <Window.Content scrollable={tabIndex === 0}>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab key="DataView" selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
              <Icon name="table" /> Data View
            </Tabs.Tab>
            <Tabs.Tab key="MapView" selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
              <Icon name="map-marked-alt" /> Map View
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

const AtmosControlDataView = (_properties) => {
  const { act, data } = useBackend();
  const { alarms } = data;
  return (
    <Box>
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Status</Table.Cell>
          <Table.Cell>Access</Table.Cell>
        </Table.Row>
        {alarms.map((a) => (
          <Table.Row key={a.name}>
            <Table.Cell>{a.name}</Table.Cell>
            <Table.Cell>{getStatus(a.danger)}</Table.Cell>
            <Table.Cell>
              <Button
                icon="cog"
                content="Access"
                onClick={() =>
                  act('open_alarm', {
                    aref: a.ref,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Box>
  );
};

const AtmosControlMapView = (_properties) => {
  const { act, data } = useBackend();
  const { alarms } = data;
  return (
    <Box height="526px" mb="0.5rem" overflow="hidden">
      <NanoMap>
        {alarms
          .filter((a) => a.z === 2)
          .map((aa) => (
            // The AA means air alarm, and nothing else
            <NanoMap.MarkerIcon
              key={aa.ref}
              x={aa.x}
              y={aa.y}
              icon="circle"
              tooltip={aa.name}
              color={getStatusColour(aa.danger)}
              onClick={() => act('open_alarm', { aref: aa.ref })}
            />
          ))}
      </NanoMap>
    </Box>
  );
};

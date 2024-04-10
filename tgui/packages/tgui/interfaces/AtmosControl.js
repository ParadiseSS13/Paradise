import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon, NanoMap, Table, Tabs } from '../components';
import { TableCell } from '../components/Table';
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

export const AtmosControl = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
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

const AtmosControlDataView = (_properties, context) => {
  const { act, data } = useBackend(context);
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
            <TableCell>{a.name}</TableCell>
            <TableCell>{getStatus(a.danger)}</TableCell>
            <TableCell>
              <Button
                icon="cog"
                content="Access"
                onClick={() =>
                  act('open_alarm', {
                    aref: a.ref,
                  })
                }
              />
            </TableCell>
          </Table.Row>
        ))}
      </Table>
    </Box>
  );
};

const AtmosControlMapView = (_properties, context) => {
  const { data } = useBackend(context);
  const [zoom, setZoom] = useLocalState(context, 'zoom', 1);
  const { alarms } = data;
  return (
    <Box height="526px" mb="0.5rem" overflow="hidden">
      <NanoMap onZoom={(v) => setZoom(v)}>
        {alarms
          .filter((a) => a.z === 2)
          .map((aa) => (
            // The AA means air alarm, and nothing else
            <NanoMap.Marker
              key={aa.ref}
              x={aa.x}
              y={aa.y}
              zoom={zoom}
              icon="circle"
              tooltip={aa.name}
              color={getStatusColour(aa.danger)}
            />
          ))}
      </NanoMap>
    </Box>
  );
};

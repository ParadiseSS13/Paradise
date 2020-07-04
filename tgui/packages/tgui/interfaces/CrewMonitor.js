import { sortBy } from 'common/collections';
import { useBackend, useLocalState } from "../backend";
import { Window } from "../layouts";
import { NanoMap, Box, Table, Button, Tabs, Icon, NumberInput } from "../components";
import { TableCell } from '../components/Table';

export const CrewMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const crew = sortBy(
    cm => cm.name,
  )(data.crewmembers || []);
  const [
    mapZoom,
    setZoom,
  ] = useLocalState(context, 'number', 1);
  let body;
  // Data view
  if (tabIndex === 0) {
    body = (
      <Table>
        <Table.Row header>
          <Table.Cell>
            Name
          </Table.Cell>
          <Table.Cell>
            Status
          </Table.Cell>
          <Table.Cell>
            Location
          </Table.Cell>
        </Table.Row>
        {crew.map(cm => (
          <Table.Row key={cm.name}>
            <TableCell>
              {cm.name} ({cm.assignment})
            </TableCell>
            <TableCell>
              <Box inline
                color={cm.dead ? 'red' : 'green'}>
                {cm.dead ? 'Deceased' : 'Living'}
              </Box>
              {cm.sensor_type >= 2 ? (
                <Box inline>
                  {'('}
                  <Box inline
                    color="red">
                    {cm.brute}
                  </Box>
                  {'|'}
                  <Box inline
                    color="orange">
                    {cm.fire}
                  </Box>
                  {'|'}
                  <Box inline
                    color="green">
                    {cm.tox}
                  </Box>
                  {'|'}
                  <Box inline
                    color="blue">
                    {cm.oxy}
                  </Box>
                  {')'}
                </Box>
              ) : null}
            </TableCell>
            <TableCell>
              {cm.sensor_type === 3 ? (
                data.isAI ? (
                  <Button fluid
                    content={cm.area + " ("
                      + cm.x + ", " + cm.y + ")"}
                    onClick={() => act('track', {
                      track: cm.ref,
                    })} />
                ) : (
                  cm.area + " (" + cm.x + ", " + cm.y + ")"
                )
              ) : "Not Available"}
            </TableCell>
          </Table.Row>
        ))}
      </Table>
    );
  // Map view
  } else if (tabIndex === 1) {
    body = (
      (
        <Box textAlign="center">
          Zoom Level:
          <NumberInput
            animated
            width="40px"
            step={0.5}
            stepPixelSize={5}
            value={mapZoom}
            minValue={1}
            maxValue={8}
            onDrag={(e, value) => setZoom(value)} />
          <NanoMap zoom={mapZoom}>
            {crew.filter(x => x.sensor_type === 3).map(cm => (
              <NanoMap.Marker
                key={cm.ref}
                x={cm.x}
                y={cm.y}
                zoom={mapZoom}
                icon="circle"
                tooltip={cm.name}
                color={cm.dead ? 'red' : 'green'}
              />
            ))}
          </NanoMap>
        </Box>
      )
    );
  } else {
    body = "ERROR";
  }
  return (
    <Window resizable>
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            key="DataView"
            selected={0 === tabIndex}
            onClick={() => setTabIndex(0)}>
            <Icon name="table" /> Data View
          </Tabs.Tab>
          <Tabs.Tab
            key="MapView"
            selected={1 === tabIndex}
            onClick={() => setTabIndex(1)}>
            <Icon name="map-marked-alt" /> Map View
          </Tabs.Tab>
        </Tabs>
        <Box m={2}>
          {body}
        </Box>
      </Window.Content>
    </Window>
  );
};


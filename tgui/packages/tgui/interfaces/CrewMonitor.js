import { sortBy } from 'common/collections';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Icon, Input, NanoMap, Table, Tabs } from "../components";
import { TableCell } from '../components/Table';
import { COLORS } from '../constants.js';
import { Window } from "../layouts";

const getStatText = cm => {
  if (cm.dead) {
    return "Deceased";
  }
  if (parseInt(cm.stat, 10) === 1) { // Unconscious
    return "Unconscious";
  }
  return "Living";
};

const getStatColor = cm => {
  if (cm.dead) {
    return "red";
  }
  if (parseInt(cm.stat, 10) === 1) { // Unconscious
    return "orange";
  }
  return "green";
};

export const CrewMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = index => {
    switch (index) {
      case 0:
        return <CrewMonitorDataView />;
      case 1:
        return <CrewMonitorMapView />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window resizable>
      <Window.Content>
        <Box fillPositionedParent>
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
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

const CrewMonitorDataView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const crew = sortBy(
    cm => cm.name,
  )(data.crewmembers || []);
  const [
    search,
    setSearch,
  ] = useLocalState(context, 'search', '');
  const searcher = createSearch(search, cm => {
    return cm.name + "|" + cm.assignment + "|" + cm.area;
  });
  return (
    <Box>
      <Input
        placeholder="Search by name, assignment or location.."
        width="100%"
        onInput={(_e, value) => setSearch(value)}
      />
      <Table m="0.5rem">
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
        {crew.filter(searcher).map(cm => (
          <Table.Row key={cm.name} bold={!!cm.is_command}>
            <TableCell>
              {cm.name} ({cm.assignment})
            </TableCell>
            <TableCell>
              <Box inline
                color={getStatColor(cm)}>
                {getStatText(cm)}
              </Box>
              {cm.sensor_type >= 2 ? (
                <Box inline>
                  {'('}
                  <Box inline
                    color={COLORS.damageType.oxy}>
                    {cm.oxy}
                  </Box>
                  {'|'}
                  <Box inline
                    color={COLORS.damageType.toxin}>
                    {cm.tox}
                  </Box>
                  {'|'}
                  <Box inline
                    color={COLORS.damageType.burn}>
                    {cm.fire}
                  </Box>
                  {'|'}
                  <Box inline
                    color={COLORS.damageType.brute}>
                    {cm.brute}
                  </Box>
                  {')'}
                </Box>
              ) : null}
            </TableCell>
            <TableCell>
              {cm.sensor_type === 3 ? (
                data.isAI ? (
                  <Button fluid
                    icon="location-arrow"
                    content={
                      cm.area + " (" + cm.x + ", " + cm.y + ")"
                    }
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
    </Box>
  );
};

const CrewMonitorMapView = (_properties, context) => {
  const { data } = useBackend(context);
  const [zoom, setZoom] = useLocalState(context, 'zoom', 1);
  return (
    <Box height="526px" mb="0.5rem" overflow="hidden">
      <NanoMap onZoom={v => setZoom(v)}>
        {data.crewmembers.filter(x => x.sensor_type === 3).map(cm => (
          <NanoMap.Marker
            key={cm.ref}
            x={cm.x}
            y={cm.y}
            zoom={zoom}
            icon="circle"
            tooltip={cm.name + " (" + cm.assignment + ")"}
            color={getStatColor(cm)}
          />
        ))}
      </NanoMap>
    </Box>
  );
};

import { sortBy } from 'common/collections';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Icon, Input, NanoMap, Table, Tabs } from "../components";
import { TableCell } from '../components/Table';
import { COLORS } from '../constants.js';
import { Window } from "../layouts";

const getStatText = (cm, critThreshold) => {
  if (cm.dead) {
    return "Deceased";
  }
  if (parseInt(cm.health, 10) <= critThreshold) { // Critical
    return "Critical";
  }
  if (parseInt(cm.stat, 10) === 1) { // Unconscious
    return "Unconscious";
  }
  return "Living";
};

const getStatColor = (cm, critThreshold) => {
  if (cm.dead) {
    return "red";
  }
  if (parseInt(cm.health, 10) <= critThreshold) { // Critical
    return "orange";
  }
  if (parseInt(cm.stat, 10) === 1) { // Unconscious
    return "blue";
  }
  return "green";
};

export const CrewMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', data.isBS ? 0 : 1);
  const decideTab = index => {
    switch (index) {
      case 0:
        return <ComCrewMonitorDataView />;
      case 1:
        return <CrewMonitorDataView />;
      case 2:
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
            {data.isBS
              ? (
                <Tabs.Tab
                  key="ComDataView"
                  selected={0 === tabIndex}
                  onClick={() => setTabIndex(0)}>
                  <Icon name="table" /> Command Data View
                </Tabs.Tab>
              )
              : null}
            <Tabs.Tab
              key="DataView"
              selected={1 === tabIndex}
              onClick={() => setTabIndex(1)}>
              <Icon name="table" /> Data View
            </Tabs.Tab>
            <Tabs.Tab
              key="MapView"
              selected={2 === tabIndex}
              onClick={() => setTabIndex(2)}>
              <Icon name="map-marked-alt" /> Map View
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

const CrewMonitorTable = ({ crewData, context }) => {
  const { act, data } = useBackend(context);
  const crew = sortBy(
    cm => cm.name,
  )(crewData || []);
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
                color={getStatColor(cm, data.critThreshold)}>
                {getStatText(cm, data.critThreshold)}
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

const CrewMonitorDataView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const crew = data.crewmembers || [];
  return (
    <CrewMonitorTable
      crewData={crew}
      context={context}
    />
  );
};

const ComCrewMonitorDataView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const commandCrew = data.crewmembers.filter(cm => cm.is_command) || [];
  return (
    <CrewMonitorTable
      crewData={commandCrew}
      context={context}
    />
  );
};

const CrewMonitorMapView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const [zoom, setZoom] = useLocalState(context, 'zoom', 1);
  const getIcon = cm => {
    return cm.is_command && data.isBS ? "square" : "circle";
  };
  const getSize = cm => {
    return cm.is_command && data.isBS ? 10 : 6;
  };
  const getExtendedStatColor = (cm, critThreshold) => {
    if (!cm.is_command || !data.isBS) {
      return getStatColor(cm, critThreshold);
    }

    if (cm.dead) {
      return "red";
    }
    if (parseInt(cm.health, 10) <= critThreshold) { // Critical
      return "orange";
    }
    if (parseInt(cm.stat, 10) === 1) { // Unconscious
      return "blue";
    }
    return "violet";
  };
  return (
    <Box height="526px" mb="0.5rem" overflow="hidden">
      <NanoMap onZoom={v => setZoom(v)}>
        {data.crewmembers.filter(x => x.sensor_type === 3).map(cm => (
          <NanoMap.Marker
            key={cm.ref}
            x={cm.x}
            y={cm.y}
            zoom={zoom}
            icon={getIcon(cm)}
            size={getSize(cm)}
            tooltip={cm.name + " (" + cm.assignment + ")"}
            color={getExtendedStatColor(cm, data.critThreshold)}
            onClick={() => {
              if (data.isAI) {
                act('track', {
                  track: cm.ref,
                });
              }
            }}
          />
        ))}
      </NanoMap>
    </Box>
  );
};

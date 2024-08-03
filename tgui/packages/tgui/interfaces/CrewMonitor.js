import { sortBy } from 'common/collections';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Input, NanoMap, Section, Stack, Table, Tabs } from '../components';
import { TableCell } from '../components/Table';
import { COLORS } from '../constants';
import { Window } from '../layouts';
import { ButtonCheckbox } from '../components/Button';

const getStatText = (cm, critThreshold) => {
  if (cm.dead) {
    return 'Deceased';
  }
  if (parseInt(cm.health, 10) <= critThreshold) {
    // Critical
    return 'Critical';
  }
  if (parseInt(cm.stat, 10) === 1) {
    // Unconscious
    return 'Unconscious';
  }
  return 'Living';
};

const getStatColor = (cm, critThreshold) => {
  if (cm.dead) {
    return 'red';
  }
  if (parseInt(cm.health, 10) <= critThreshold) {
    // Critical
    return 'orange';
  }
  if (parseInt(cm.stat, 10) === 1) {
    // Unconscious
    return 'blue';
  }
  return 'green';
};

export const CrewMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndexInternal] = useLocalState(context, 'tabIndex', data.tabIndex);
  const setTabIndex = (index) => {
    setTabIndexInternal(index);
    act('set_tab_index', { tab_index: index });
  };
  const decideTab = (index) => {
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
    <Window width={800} height={600}>
      <Window.Content>
        <Stack fill vertical fillPositionedParent>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab key="DataView" icon="table" selected={0 === tabIndex} onClick={() => setTabIndex(0)}>
                Data View
              </Tabs.Tab>
              <Tabs.Tab key="MapView" icon="map-marked-alt" selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
                Map View
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          {decideTab(tabIndex)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CrewMonitorDataView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const crew = sortBy((cm) => cm.name)(data.crewmembers || []);
  const { possible_levels, viewing_current_z_level, is_advanced, highlightedNames } = data;
  const [search, setSearch] = useLocalState(context, 'search', '');
  const searcher = createSearch(search, (cm) => {
    return cm.name + '|' + cm.assignment + '|' + cm.area;
  });
  return (
    <Section fill scrollable backgroundColor="transparent">
      <Stack>
        <Stack.Item width="100%" ml="5px">
          <Input
            placeholder="Search by name, assignment or location.."
            width="100%"
            onInput={(_e, value) => setSearch(value)}
          />
        </Stack.Item>
        <Stack.Item>
          {is_advanced ? (
            <Dropdown
              mr="5px"
              width="50px"
              options={possible_levels}
              selected={viewing_current_z_level}
              onSelected={(val) => act('switch_level', { new_level: val })}
            />
          ) : null}
        </Stack.Item>
      </Stack>
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>
            <Button tooltip="Clear highlights" icon="square-xmark" onClick={() => act('clear_highlighted_names')} />
          </Table.Cell>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Status</Table.Cell>
          <Table.Cell>Location</Table.Cell>
        </Table.Row>
        {crew.filter(searcher).map((cm) => {
          const highlighted = highlightedNames.includes(cm.name);
          return (
            <Table.Row key={cm.name} bold={!!cm.is_command}>
              <TableCell>
                <ButtonCheckbox
                  checked={highlighted}
                  tooltip="Mark on map"
                  onClick={() =>
                    act(highlighted ? 'remove_highlighted_name' : 'add_highlighted_name', { name: cm.name })
                  }
                />
              </TableCell>
              <TableCell>
                {cm.name} ({cm.assignment})
              </TableCell>
              <TableCell>
                <Box inline color={getStatColor(cm, data.critThreshold)}>
                  {getStatText(cm, data.critThreshold)}
                </Box>
                {cm.sensor_type >= 2 || data.ignoreSensors ? (
                  <Box inline ml={1}>
                    {'('}
                    <Box inline color={COLORS.damageType.oxy}>
                      {cm.oxy}
                    </Box>
                    {'|'}
                    <Box inline color={COLORS.damageType.toxin}>
                      {cm.tox}
                    </Box>
                    {'|'}
                    <Box inline color={COLORS.damageType.burn}>
                      {cm.fire}
                    </Box>
                    {'|'}
                    <Box inline color={COLORS.damageType.brute}>
                      {cm.brute}
                    </Box>
                    {')'}
                  </Box>
                ) : null}
              </TableCell>
              <TableCell>
                {cm.sensor_type === 3 || data.ignoreSensors ? (
                  data.isAI || data.isObserver ? (
                    <Button
                      fluid
                      icon="location-arrow"
                      content={cm.area + ' (' + cm.x + ', ' + cm.y + ')'}
                      onClick={() =>
                        act('track', {
                          track: cm.ref,
                        })
                      }
                    />
                  ) : (
                    cm.area + ' (' + cm.x + ', ' + cm.y + ')'
                  )
                ) : (
                  <Box inline color="grey">
                    Not Available
                  </Box>
                )}
              </TableCell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

const HighlightedMarker = (props, context) => {
  const { color, ...rest } = props;
  return (
    <NanoMap.Marker {...rest}>
      <span class={`highlighted-marker color-border-${color}`} />
    </NanoMap.Marker>
  );
};

const CrewMonitorMapView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { highlightedNames } = data;
  return (
    <Box height="526px" mb="0.5rem" overflow="hidden">
      <NanoMap
        zoom={data.zoom}
        offsetX={data.offsetX}
        offsetY={data.offsetY}
        onZoom={(zoom) => act('set_zoom', { zoom })}
        onOffsetChange={(e, state) =>
          act('set_offset', {
            offset_x: state.offsetX,
            offset_y: state.offsetY,
          })
        }
      >
        {data.crewmembers
          .filter((x) => x.sensor_type === 3 || data.ignoreSensors)
          .map((cm) => {
            const color = getStatColor(cm, data.critThreshold);
            const highlighted = highlightedNames.includes(cm.name);
            const onClick = () =>
              data.isObserver
                ? act('track', {
                    track: cm.ref,
                  })
                : null;
            const onDblClick = () =>
              act(highlighted ? 'remove_highlighted_name' : 'add_highlighted_name', { name: cm.name });
            const tooltip = cm.name + ' (' + cm.assignment + ')';
            if (highlighted) {
              return (
                <HighlightedMarker
                  key={cm.ref}
                  x={cm.x}
                  y={cm.y}
                  tooltip={tooltip}
                  color={color}
                  onClick={onClick}
                  onDblClick={onDblClick}
                />
              );
            } else {
              return (
                <NanoMap.MarkerIcon
                  key={cm.ref}
                  x={cm.x}
                  y={cm.y}
                  icon="circle"
                  tooltip={tooltip}
                  color={color}
                  onClick={onClick}
                  onDblClick={onDblClick}
                />
              );
            }
          })}
      </NanoMap>
    </Box>
  );
};

import { Box, Button, DmIcon, Dropdown, Flex, Icon, LabeledList, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const SelectableTile = (props) => {
  const { act, data } = useBackend();
  const { icon_state, direction, isSelected, onSelect } = props;

  return (
    <DmIcon
      icon={data.icon}
      icon_state={icon_state}
      direction={direction}
      onClick={onSelect}
      style={{
        borderStyle: (isSelected && 'solid') || 'none',
        borderWidth: '2px',
        borderColor: 'orange',
        padding: (isSelected && '0px') || '2px',
      }}
    />
  );
};

const Dir = {
  NORTH: 1,
  SOUTH: 2,
  EAST: 4,
  WEST: 8,
};

export const FloorPainter = (props) => {
  const { act, data } = useBackend();
  const { availableStyles, selectedStyle, selectedDir, wideMode } = data;
  return (
    <Window width={405} height={475}>
      <Window.Content scrollable>
        <Section title="Floor setup">
          <Stack>
            <Stack.Item>
              <Button icon="chevron-left" onClick={() => act('cycle_style', { offset: -1 })} />
            </Stack.Item>
            <Stack.Item>
              <Dropdown
                options={availableStyles}
                selected={selectedStyle}
                width="150px"
                height="20px"
                ml="2px"
                mr="2px"
                nochevron
                onSelected={(val) => act('select_style', { style: val })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button icon="chevron-right" onClick={() => act('cycle_style', { offset: 1 })} />
            </Stack.Item>
            <Stack.Item>
              <Button icon="eraser" color={wideMode ? 'green' : 'transparent'} onClick={() => act('wide_mode')}>
                Wide mode
              </Button>
            </Stack.Item>
          </Stack>

          <Box mt="5px" mb="5px">
            <Flex
              overflowY="auto" // scroll
              maxHeight="239px" // a bit more than half of all tiles fit in this box at once.
              wrap="wrap"
            >
              {availableStyles.map((style) => (
                <Flex.Item key={style}>
                  <SelectableTile
                    icon_state={style}
                    isSelected={selectedStyle === style}
                    onSelect={() => act('select_style', { style: style })}
                  />
                </Flex.Item>
              ))}
            </Flex>
          </Box>

          <LabeledList>
            <LabeledList.Item label="Direction">
              <Table style={{ display: 'inline' }}>
                {[Dir.NORTH, null, Dir.SOUTH].map((latitude) => (
                  <Table.Row key={latitude}>
                    {[latitude + Dir.WEST, latitude, latitude + Dir.EAST].map((dir) => (
                      <Table.Cell
                        key={dir}
                        style={{
                          verticalAlign: 'middle',
                          textAlign: 'center',
                        }}
                      >
                        {dir === null ? (
                          <Icon name="arrows-alt" size={3} />
                        ) : (
                          <SelectableTile
                            icon_state={selectedStyle}
                            direction={dir}
                            isSelected={dir === selectedDir}
                            onSelect={() => act('select_direction', { direction: dir })}
                          />
                        )}
                      </Table.Cell>
                    ))}
                  </Table.Row>
                ))}
              </Table>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

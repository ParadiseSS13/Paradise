import { useBackend, useLocalState } from '../backend';
import { Button, DmIcon, LabeledList, Section, Table, Dropdown, Flex, Icon, Box } from '../components';
import { Window } from '../layouts';

const SelectableTile = (props, context) => {
  const { act, data } = useBackend(context);
  const { icon_state, direction, isSelected, onSelect } = props;

  return (
    <DmIcon
      icon={data.icon}
      icon_state={icon_state}
      direction={direction}
      onClick={onSelect}
      style={{
        'border-style': (isSelected && 'solid') || 'none',
        'border-width': '2px',
        'border-color': 'orange',
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

export const FloorPainter = (props, context) => {
  const { act, data } = useBackend(context);
  const { availableStyles, selectedStyle, selectedDir } = data;
  return (
    <Window width={405} height={475}>
      <Window.Content scrollable>
        <Section title="Decal setup">
          <Flex>
            <Flex.Item>
              <Button icon="chevron-left" onClick={() => act('cycle_style', { offset: -1 })} />
            </Flex.Item>
            <Flex.Item>
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
            </Flex.Item>
            <Flex.Item>
              <Button icon="chevron-right" onClick={() => act('cycle_style', { offset: 1 })} />
            </Flex.Item>
          </Flex>

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
                          'vertical-align': 'middle',
                          'text-align': 'center',
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

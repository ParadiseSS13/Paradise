import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Section, Table, Dropdown, Flex, Icon, Box } from '../components';
import { Window } from '../layouts';

const SelectableTile = (props, context) => {
  const { act, data } = useBackend(context);
  const { image, isSelected, onSelect } = props;
  return (
    <img
      src={`data:image/jpeg;base64,${image}`}
      style={{
        'border-style': (isSelected && 'solid') || 'none',
        'border-width': '2px',
        'border-color': 'orange',
        padding: (isSelected && '2px') || '4px',
      }}
      onClick={onSelect}
    />
  );
};

export const FloorPainter = (props, context) => {
  const { act, data } = useBackend(context);
  const { availableStyles, selectedStyle, selectedDir, directionsPreview, allStylesPreview } = data;
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
              maxHeight="220px" // a bit more than half of all tiles fit in this box at once.
              wrap="wrap"
            >
              {availableStyles.map((style) => (
                <Flex.Item key="{style}">
                  <SelectableTile
                    image={allStylesPreview[style]}
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
                {['north', '', 'south'].map((latitude) => (
                  <Table.Row key={latitude}>
                    {[latitude + 'west', latitude, latitude + 'east'].map((dir) => (
                      <Table.Cell
                        key={dir}
                        style={{
                          'vertical-align': 'middle',
                          'text-align': 'center',
                        }}
                      >
                        {dir === '' ? (
                          <Icon name="arrows-alt" size={3} />
                        ) : (
                          <SelectableTile
                            image={directionsPreview[dir]}
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

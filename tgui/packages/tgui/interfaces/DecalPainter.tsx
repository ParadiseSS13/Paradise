import { Box, Button, Flex, Icon, Section, Stack, Table, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BooleanLike, classes } from 'tgui-core/react';
import { createContext, useContext } from 'react';

const Dir = {
  NORTH: 1,
  SOUTH: 2,
  EAST: 4,
  WEST: 8,
};

type DecalPainterStyle = {
  color: string;
  icon_state: string;
  typepath: string;
};

type DecalPainterData = {
  categories: string[];
  availableStyles: { string: DecalPainterStyle[] };
  selectedDecalType: string;
  selectedDir: number;
  selectedCategory: string;
  removalMode: BooleanLike;
};

type DecalPainterContextType = {
  categoryStyles: DecalPainterStyle[];
  removalMode: BooleanLike;
};

const DecalPainterContext = createContext<DecalPainterContextType>({
  categoryStyles: [],
  removalMode: null,
});

const SelectableTile = (props) => {
  const { decal_typepath, direction, isSelected, onSelect } = props;
  const className = `${decal_typepath.replace(/\//g, '_')}_${direction}`;

  return (
    <Box
      m={`2px`}
      className={classes(['decal_painter32x32', className])}
      onClick={onSelect}
      style={{
        outlineStyle: (isSelected && 'solid') || 'none',
        outlineWidth: '2px',
        outlineColor: 'orange',
      }}
    />
  );
};

const DecalPainterNavigation = () => {
  const { act, data } = useBackend<DecalPainterData>();
  const { selectedCategory, categories } = data;

  return (
    <Stack vertical>
      <Stack.Item>
        <Tabs>
          {categories.map((category) => (
            <Tabs.Tab selected={category == selectedCategory} onClick={() => act('set_category', { category })}>
              {category}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
    </Stack>
  );
};

const DecalPainterSection = () => {
  const { act, data } = useBackend<DecalPainterData>();
  const { selectedDecalType, removalMode } = data;
  const { categoryStyles } = useContext<DecalPainterContextType>(DecalPainterContext);

  return (
    <Section>
      <Box>
        <Flex wrap="wrap">
          {categoryStyles.map((style) => (
            <Flex.Item key={style.typepath}>
              <SelectableTile
                decal_typepath={style.typepath}
                direction={Dir.SOUTH}
                isSelected={selectedDecalType === style.typepath && !removalMode}
                onSelect={() => act('set_decal_type', { decal_type: style.typepath })}
              />
            </Flex.Item>
          ))}
        </Flex>
      </Box>
    </Section>
  );
};

const DecalPainterDirSelector = () => {
  const { act, data } = useBackend<DecalPainterData>();
  const { selectedDecalType, selectedDir, removalMode } = data;

  return (
    <Table style={{ display: 'inline' }}>
      {[Dir.NORTH, 0, Dir.SOUTH].map((latitude) => (
        <Table.Row key={latitude}>
          {[latitude + Dir.WEST, latitude, latitude + Dir.EAST].map((dir) => (
            <Table.Cell
              key={dir}
              style={{
                verticalAlign: 'middle',
                textAlign: 'center',
              }}
            >
              {dir === 0 ? (
                <Icon name="arrows-alt" size={3} />
              ) : (
                <SelectableTile
                  decal_typepath={selectedDecalType}
                  direction={dir}
                  isSelected={dir === selectedDir && !removalMode}
                  onSelect={() => act('set_direction', { direction: dir })}
                />
              )}
            </Table.Cell>
          ))}
        </Table.Row>
      ))}
    </Table>
  );
};

export const DecalPainter = () => {
  const { act, data } = useBackend<DecalPainterData>();
  const { availableStyles, removalMode, selectedCategory } = data;

  const categoryStyles = availableStyles[selectedCategory];

  return (
    <Window width={650} height={565}>
      <Window.Content scrollable>
        <DecalPainterContext.Provider value={{ categoryStyles, removalMode }}>
          <Stack fill>
            <Stack.Item>
              <Section title="Preview">
                <DecalPainterDirSelector />
                <Button
                  icon="eraser"
                  color={removalMode ? 'green' : 'transparent'}
                  onClick={() => act('toggle_removal_mode')}
                >
                  Remove decals
                </Button>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Decals">
                <DecalPainterNavigation />
                <DecalPainterSection />
              </Section>
            </Stack.Item>
          </Stack>
        </DecalPainterContext.Provider>
      </Window.Content>
    </Window>
  );
};

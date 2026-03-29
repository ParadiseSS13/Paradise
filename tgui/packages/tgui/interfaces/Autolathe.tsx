import { filter, sortBy } from 'common/collections';
import { Box, Button, Input, LabeledList, Section, Stack } from 'tgui-core/components';
import { Dropdown } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { createSearch, toTitleCase } from 'tgui-core/string';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

const canBeMade = (recipe: Recipe, mavail: number, gavail: number, multi: number) => {
  if (recipe.requirements === null) {
    return true;
  }
  if (recipe.requirements['metal'] * multi > mavail) {
    return false;
  }
  if (recipe.requirements['glass'] * multi > gavail) {
    return false;
  }
  return true;
};

type QueuedItem = [string, number];

type Recipe = {
  name: string;
  category: string[];
  requirements: { [key: string]: number };
  hacked: BooleanLike;
  uid: string;
  max_multiplier: number;
  image: string;
};

type AutolatheData = {
  total_amount: number;
  max_amount: number;
  metal_amount: number;
  glass_amount: number;
  busyname: string;
  busyamt: number;
  showhacked: BooleanLike;
  buildQueue: QueuedItem[];
  buildQueueLen: number;
  recipes: Recipe[];
  categories: string[];
  fill_percent: number;
};

export const Autolathe = (props) => {
  const { act, data } = useBackend<AutolatheData>();
  const {
    total_amount,
    max_amount,
    metal_amount,
    glass_amount,
    busyname,
    busyamt,
    showhacked,
    buildQueue,
    buildQueueLen,
    recipes,
    categories,
    fill_percent,
  } = data;

  let [category, setCategory] = useSharedState('category', 'Tools');

  let metalReadable = metal_amount.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,'); // add thousands seperator
  let glassReadable = glass_amount.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
  let totalReadable = total_amount.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');

  const [searchText, setSearchText] = useSharedState('searchText', '');

  let buildQueueItems: React.JSX.Element[] = [];
  if (buildQueueLen > 0) {
    buildQueueItems = buildQueue.map((queue_item, i) => {
      return (
        <Box key={i}>
          <Button
            fluid
            key={i}
            icon="times"
            color="transparent"
            content={queue_item[0]}
            onClick={() =>
              act('remove_from_queue', {
                remove_from_queue: i + 1,
              })
            }
          />
        </Box>
      );
    });
  }

  const selectRecipes = (recipes: Recipe[], searchText = ''): Recipe[] => {
    let queriedRecipes = filter(
      recipes,
      (recipe) => (recipe.category.indexOf(category) > -1 || !!searchText) && (!!showhacked || !recipe.hacked)
    );
    if (searchText) {
      const testSearch = createSearch(searchText, (recipe: Recipe) => recipe.name);
      queriedRecipes = filter(queriedRecipes, testSearch);
    }
    queriedRecipes = sortBy(queriedRecipes, (recipe) => recipe.name.toLowerCase());
    return queriedRecipes;
  };
  const queriedRecipes = selectRecipes(recipes, searchText);

  let rText = 'Build';
  if (searchText) {
    rText = "Results for: '" + searchText + "':";
  } else if (category) {
    rText = 'Build (' + category + ')';
  }
  return (
    <Window width={750} height={525}>
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item width="70%">
            <Section
              fill
              scrollable
              title={rText}
              buttons={
                <Dropdown
                  width="150px"
                  options={categories}
                  selected={category}
                  onSelected={(val) => setCategory(val)}
                />
              }
            >
              <Input
                fluid
                mb={1}
                placeholder="Search for..."
                onChange={(value) => setSearchText(value)}
                value={searchText}
              />
              {queriedRecipes.map((recipe) => (
                <Stack.Item grow key={recipe.uid}>
                  <img
                    src={`data:image /jpeg;base64,${recipe.image}`}
                    style={{
                      verticalAlign: 'middle',
                      width: '32px',
                      margin: '0px',
                    }}
                  />
                  <Button
                    mr={1}
                    icon="hammer"
                    selected={busyname === recipe.name && busyamt === 1}
                    disabled={!canBeMade(recipe, metal_amount, glass_amount, 1)}
                    onClick={() =>
                      act('make', {
                        make: recipe.uid,
                        multiplier: 1,
                      })
                    }
                  >
                    {recipe.name}
                  </Button>
                  {recipe.max_multiplier >= 10 && (
                    <Button
                      mr={1}
                      icon="hammer"
                      selected={busyname === recipe.name && busyamt === 10}
                      disabled={!canBeMade(recipe, metal_amount, glass_amount, 10)}
                      onClick={() =>
                        act('make', {
                          make: recipe.uid,
                          multiplier: 10,
                        })
                      }
                    >
                      10x
                    </Button>
                  )}
                  {recipe.max_multiplier >= 25 && (
                    <Button
                      mr={1}
                      icon="hammer"
                      selected={busyname === recipe.name && busyamt === 25}
                      disabled={!canBeMade(recipe, metal_amount, glass_amount, 25)}
                      onClick={() =>
                        act('make', {
                          make: recipe.uid,
                          multiplier: 25,
                        })
                      }
                    >
                      25x
                    </Button>
                  )}
                  {recipe.max_multiplier > 25 && (
                    <Button
                      mr={1}
                      icon="hammer"
                      selected={busyname === recipe.name && busyamt === recipe.max_multiplier}
                      disabled={!canBeMade(recipe, metal_amount, glass_amount, recipe.max_multiplier)}
                      onClick={() =>
                        act('make', {
                          make: recipe.uid,
                          multiplier: recipe.max_multiplier,
                        })
                      }
                    >
                      {recipe.max_multiplier}x
                    </Button>
                  )}
                  {(recipe.requirements &&
                    Object.keys(recipe.requirements)
                      .map((mat) => toTitleCase(mat) + ': ' + recipe.requirements[mat])
                      .join(', ')) || <Box>No resources required.</Box>}
                </Stack.Item>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item width="30%">
            <Section title="Materials">
              <LabeledList>
                <LabeledList.Item label="Metal">{metalReadable}</LabeledList.Item>
                <LabeledList.Item label="Glass">{glassReadable}</LabeledList.Item>
                <LabeledList.Item label="Total">{totalReadable}</LabeledList.Item>
                <LabeledList.Item label="Storage">{fill_percent}% Full</LabeledList.Item>
              </LabeledList>
            </Section>
            <Section title="Building">
              <Box color={busyname ? 'green' : ''}>{busyname ? busyname : 'Nothing'}</Box>
            </Section>
            <Section title="Build Queue" height={23.7}>
              {buildQueueItems}
              <Button
                mt={0.5}
                fluid
                icon="times"
                content="Clear All"
                color="red"
                disabled={!buildQueueLen}
                onClick={() => act('clear_queue')}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

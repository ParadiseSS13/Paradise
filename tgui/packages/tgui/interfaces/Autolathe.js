import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState } from "../backend";
import { Box, Button, Flex, Input, LabeledList, Section, Dropdown } from "../components";
import { Window } from "../layouts";
import { createSearch, toTitleCase } from 'common/string';

const canBeMade = (recipe, mavail, gavail, multi) => {
  if (recipe.requirements === null) {
    return true;
  }
  if ((recipe.requirements["metal"] * multi) > mavail) {
    return false;
  }
  if ((recipe.requirements["glass"] * multi) > gavail) {
    return false;
  }
  return true;
};

export const Autolathe = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    total_amount,
    max_amount,
    metal_amount,
    glass_amount,
    busyname,
    showhacked,
    buildQueue,
    buildQueueLen,
    recipes,
    categories,
  } = data;

  let [category, setCategory] = useSharedState(context, "category", 0);

  if (category === 0) {
    category = "Tools";
  }

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, "search_text", "");

  const testSearch = createSearch(searchText, recipe => recipe.name);

  let buildQueueItems = "None";
  if (buildQueueLen > 0) {
    buildQueueItems = buildQueue.map((a, i) => {
      return (
        <Button
          key={a}
          icon="times"
          selected={i === 0}
          content={buildQueue[i][0]}
          onClick={() => act('remove_from_queue',
            { remove_from_queue: buildQueue.indexOf(a) + 1 })} />
      );
    });
  }

  const recipesToShow = flow([
    filter(recipe => (recipe.category.indexOf(category) > -1 || searchText)
      && (data.showhacked || !recipe.hacked)),
    searchText && filter(testSearch),
    sortBy(recipe => recipe.name.toLowerCase()),
  ])(recipes);

  let rText = "Build";
  if (searchText) {
    rText = "Results for: '" + searchText + "':";
  } else if (category) {
    rText = "Build (" + category + ")";
  }
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Materials">
          Metal: {data.metal_amount
            ? data.metal_amount
            : 0},
          Glass: {data.glass_amount
            ? data.glass_amount
            : 0},
          Total: {data.total_amount
            ? data.total_amount
            : 0}
        </Section>
        <Section
          title="Queue"
          buttons={(
            <Button
              icon="times"
              content="Clear Queue"
              disabled={!data.buildQueueLen}
              onClick={() => act('clear_queue')} />
          )}>
          {buildQueueItems}
        </Section>
        <Section
          title={rText}
          buttons={
            <Dropdown
              width="190px"
              options={categories}
              selected={category}
              onSelected={val => setCategory(val)} />
          }>
          <Input
            fluid
            placeholder="Search for..."
            onInput={(e, v) => setSearchText(v)}
            mb={1} />
          {recipesToShow.map(recipe => (
            <Flex justify="space-between" align="center" key={recipe.ref}>
              <Flex.Item>
                <img
                  src={`data:image/jpeg;base64,${recipe.image}`}
                  style={{
                    'vertical-align': 'middle',
                    width: '32px',
                    margin: '0px',
                    'margin-left': '0px',
                  }} />
                <Button
                  color={recipe.hacked && "red" || null}
                  icon="hammer"
                  iconSpin={data.busyname === recipe.name}
                  disabled={
                    !canBeMade(recipe,
                      data.metal_amount, data.glass_amount, 1)
                  }
                  onClick={() => act("make", {
                    make: recipe.uid, multiplier: 1 })}>
                  {toTitleCase(recipe.name)}

                </Button>
                {recipe.max_multiplier >= 10 && (
                  <Button
                    color={recipe.hacked && "red" || null}
                    icon="hammer"
                    iconSpin={data.busyname === recipe.name}
                    disabled={
                      !canBeMade(recipe,
                        data.metal_amount, data.glass_amount, 10)
                    }
                    onClick={() => act("make", {
                      make: recipe.uid, multiplier: 10,
                    })}>
                    10x
                  </Button>
                )}
                {recipe.max_multiplier >= 25 && (
                  <Button
                    color={recipe.hacked && "red" || null}
                    icon="hammer"
                    iconSpin={data.busyname === recipe.name}
                    disabled={
                      !canBeMade(recipe,
                        data.metal_amount, data.glass_amount, 25)
                    }
                    onClick={() => act("make", {
                      make: recipe.uid, multiplier: 25,
                    })}>
                    25x
                  </Button>
                )}
              </Flex.Item>
              <Flex.Item>
                {recipe.requirements && (
                  Object
                    .keys(recipe.requirements)
                    .map(mat => toTitleCase(mat)
                      + ": " + recipe.requirements[mat])
                    .join(", ")
                ) || (
                  <Box>
                    No resources required.
                  </Box>
                )}
              </Flex.Item>
            </Flex>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};



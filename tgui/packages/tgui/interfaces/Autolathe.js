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
    busyamt,
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
  let metalReadable = metal_amount.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,'); // add thousands seperator
  let glassReadable = glass_amount.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
  let totalReadable = total_amount.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, "search_text", "");

  const testSearch = createSearch(searchText, recipe => recipe.name);

  let buildQueueItems = "";
  if (buildQueueLen > 0) {
    buildQueueItems = buildQueue.map((a, i) => {
      return (
        <Box key={i}>
          <Button
            key={a}
            icon="times"
            content={buildQueue[i][0]}
            onClick={() => act('remove_from_queue',
              { remove_from_queue: buildQueue.indexOf(a) + 1 })} />
        </Box>
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
  const styleLeftDiv = {
    float: 'left',
    width: '68%',
  };
  const styleRightDiv = {
    float: 'right',
    width: '30%',
  };
  return (
    <Window resizable>
      <Window.Content scrollable>
        <div style={styleLeftDiv}>
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
                    icon="hammer"
                    selected={data.busyname === recipe.name
                      && data.busyamt === 1}
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
                      icon="hammer"
                      selected={data.busyname === recipe.name
                        && data.busyamt === 10}
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
                      icon="hammer"
                      selected={data.busyname === recipe.name
                        && data.busyamt === 25}
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
                  {recipe.max_multiplier > 25 && (
                    <Button
                      icon="hammer"
                      selected={data.busyname === recipe.name
                        && data.busyamt === recipe.max_multiplier}
                      disabled={
                        !canBeMade(recipe,
                          data.metal_amount,
                          data.glass_amount, recipe.max_multiplier)
                      }
                      onClick={() => act("make", {
                        make: recipe.uid, multiplier: recipe.max_multiplier,
                      })}>
                      {recipe.max_multiplier}x
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
        </div>
        <div style={styleRightDiv}>
          <Section title="Materials">
            <LabeledList>
              <LabeledList.Item label="Metal">
                {metalReadable}
              </LabeledList.Item>
              <LabeledList.Item label="Glass">
                {glassReadable}
              </LabeledList.Item>
              <LabeledList.Item label="Total">
                {totalReadable}
              </LabeledList.Item>
              <LabeledList.Item label="Storage">
                {data.fill_percent}% Full
              </LabeledList.Item>
            </LabeledList>
          </Section>
          <Section title="Building">
            <Box color={busyname ? "green" : ""}>
              {busyname ? busyname : "Nothing"}
            </Box>
          </Section>
          <Section title="Build Queue">
            {buildQueueItems}
            <div align="right">
              <Button
                icon="times"
                content="Clear All"
                disabled={!data.buildQueueLen}
                onClick={() => act('clear_queue')} />
            </div>
          </Section>
        </div>

      </Window.Content>
    </Window>
  );
};



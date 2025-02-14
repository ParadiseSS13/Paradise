import { useBackend, useLocalState } from '../backend';
import { filter, sortBy, map, reduce } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch } from 'common/string';
import { Window } from '../layouts';
import { Box, Section, NoticeBox, Collapsible, Input, ImageButton, Button } from '../components';

export const StackCraft = () => {
  return (
    <Window width={350} height={500}>
      <Window.Content>
        <Recipes />
      </Window.Content>
    </Window>
  );
};

const Recipes = (props, context) => {
  const { data } = useBackend(context);
  const { amount, recipes } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const filteredRecipes = filterRecipeList(recipes, createSearch(searchText));
  const [searchActive, setSearchActive] = useLocalState(context, '', false);

  return (
    <Section
      fill
      scrollable
      title={'Amount: ' + amount}
      buttons={
        <>
          {searchActive && (
            <Input
              width={12.5}
              value={searchText}
              placeholder={'Find recipe'}
              onInput={(e, value) => setSearchText(value)}
            />
          )}
          <Button
            ml={0.5}
            tooltip="Search"
            tooltipPosition="bottom-end"
            icon="magnifying-glass"
            selected={searchActive}
            onClick={() => setSearchActive(!searchActive)}
          />
        </>
      }
    >
      {filteredRecipes ? <RecipeListBox recipes={filteredRecipes} /> : <NoticeBox>No recipes found!</NoticeBox>}
    </Section>
  );
};

/**
 * Filter recipe list by keys, resursing into subcategories.
 * Returns the filtered list, or undefined, if there is no list left.
 * @param recipeList the recipe list to filter
 * @param titleFilter the filter function for recipe title
 */
const filterRecipeList = (recipeList, titleFilter) => {
  const filteredList = flow([
    map((entry) => {
      const [title, recipe] = entry;

      if (isRecipeList(recipe)) {
        // If category name matches, return the whole thing.
        if (titleFilter(title)) {
          return entry;
        }

        // otherwise, filter sub-entries.
        return [title, filterRecipeList(recipe, titleFilter)];
      }

      return titleFilter(title) ? entry : [title, undefined];
    }),
    filter(([title, recipe]) => recipe !== undefined),
    sortBy(([title, recipe]) => title),
    sortBy(([title, recipe]) => !isRecipeList(recipe)),
    reduce((obj, [title, recipe]) => {
      obj[title] = recipe;
      return obj;
    }, {}),
  ])(Object.entries(recipeList));

  return Object.keys(filteredList).length ? filteredList : undefined;
};

/**
 * Check whether recipe is recipe list or plain recipe.
 * Returns true if the recipe is recipe list, false othewise
 * @param recipe recipe to check
 */
const isRecipeList = (recipe) => {
  return recipe['uid'] === undefined;
};

/**
 * Calculates maximum possible multiplier for recipe to be made.
 * Returns number of times, recipe can be made.
 * @param recipe recipe to calculate multiplier for
 * @param amount available amount of resource used in passed recipe
 */
const calculateMultiplier = (recipe, amount) => {
  if (recipe.required_amount > amount) {
    return 0;
  }

  return Math.floor(amount / recipe.required_amount);
};

const Multipliers = (props, context) => {
  const { act } = useBackend(context);

  const { recipe, max_possible_multiplier } = props;

  const max_available_multiplier = Math.min(
    max_possible_multiplier,
    Math.floor(recipe.max_result_amount / recipe.result_amount)
  );

  const multipliers = [5, 10, 25];

  const finalResult = [];

  for (const multiplier of multipliers) {
    if (max_available_multiplier >= multiplier) {
      finalResult.push(
        <Button
          bold
          translucent
          fontSize={0.85}
          width={'32px'}
          content={multiplier * recipe.result_amount + 'x'}
          onClick={() =>
            act('make', {
              recipe_uid: recipe.uid,
              multiplier: multiplier,
            })
          }
        />
      );
    }
  }

  if (multipliers.indexOf(max_available_multiplier) === -1) {
    finalResult.push(
      <Button
        bold
        translucent
        fontSize={0.85}
        width={'32px'}
        content={max_available_multiplier * recipe.result_amount + 'x'}
        onClick={() =>
          act('make', {
            recipe_uid: recipe.uid,
            multiplier: max_available_multiplier,
          })
        }
      />
    );
  }

  return <>{finalResult.map((x) => x)}</>;
};

const RecipeListBox = (props, context) => {
  const { recipes } = props;

  return Object.entries(recipes).map((entry) => {
    const [title, recipe] = entry;
    if (isRecipeList(recipe)) {
      return (
        <Collapsible
          key={title}
          title={title}
          contentStyle={{
            'margin-top': '0',
            'padding-bottom': '0.5em',
            'background-color': 'rgba(62, 97, 137, 0.15)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            'border-top': 'none',
          }}
        >
          <Box p={1} pb={0.25}>
            <RecipeListBox recipes={recipe} />
          </Box>
        </Collapsible>
      );
    } else {
      return <RecipeBox key={title} title={title} recipe={recipe} />;
    }
  });
};

const RecipeBox = (props, context) => {
  const { act, data } = useBackend(context);
  const { amount } = data;
  const { title, recipe } = props;
  const { result_amount, required_amount, max_result_amount, uid, icon, icon_state, image } = recipe;

  const resAmountLabel = result_amount > 1 ? `${result_amount}x ` : '';
  const sheetSuffix = required_amount > 1 ? 's' : '';
  const buttonName = `${resAmountLabel}${title}`;
  const tooltipContent = `${required_amount} sheet${sheetSuffix}`;

  const max_possible_multiplier = calculateMultiplier(recipe, amount);

  return (
    <ImageButton
      fluid
      base64={image} /* Use base64 image if we have it. DmIcon cannot paint grayscale images yet */
      dmIcon={icon}
      dmIconState={icon_state}
      imageSize={32}
      disabled={!max_possible_multiplier}
      tooltip={tooltipContent}
      buttons={
        max_result_amount > 1 &&
        max_possible_multiplier > 1 && <Multipliers recipe={recipe} max_possible_multiplier={max_possible_multiplier} />
      }
      onClick={() =>
        act('make', {
          recipe_uid: uid,
          multiplier: 1,
        })
      }
    >
      {buttonName}
    </ImageButton>
  );
};

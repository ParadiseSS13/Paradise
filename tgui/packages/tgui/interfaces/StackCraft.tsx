import { useState } from 'react';
import { Box, Button, Collapsible, ImageButton, Input, NoticeBox, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const StackCraft = () => {
  return (
    <Window width={350} height={500}>
      <Window.Content>
        <Recipes />
      </Window.Content>
    </Window>
  );
};

type Recipe = {
  uid: string;
  required_amount: number;
  result_amount: number;
  max_result_amount: number;
  icon: string;
  icon_state: string;
  image: string;
};

// A key-value pair in a recipe list is either the name of a recipe
// and the details, or the name of a category of recipes and a nested
// key-value pair of the same
type RecipeList = {
  [key: string]: Recipe | RecipeList;
};

type RecipesData = {
  amount: number;
  recipes: RecipeList;
};

type RecipeBoxProps = {
  title: string;
  recipe: Recipe;
};

// RecipeList converted via Object.entries() for filterRecipeList
type RecipeListFilterableEntry = [string, RecipeList | Recipe];

const Recipes = (props) => {
  const { data } = useBackend<RecipesData>();
  const { amount, recipes } = data;
  const [searchText, setSearchText] = useState('');

  const filteredRecipes = filterRecipeList(recipes, createSearch(searchText));
  const [searchActive, setSearchActive] = useState<BooleanLike>(false);

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
              onChange={(value) => setSearchText(value)}
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
const filterRecipeList = (recipeList: RecipeList, titleFilter: (title: string) => boolean): RecipeList | undefined => {
  const filteredList = Object.fromEntries(
    Object.entries(recipeList)
      .flatMap((entry): RecipeListFilterableEntry[] => {
        const [title, recipe] = entry;

        // If category name matches, return the whole thing.
        if (titleFilter(title)) {
          return [entry];
        }

        if (isRecipeList(recipe)) {
          // otherwise, filter sub-entries.
          const subEntries = filterRecipeList(recipe, titleFilter);
          if (subEntries !== undefined) {
            return [[title, subEntries]];
          }
        }

        return [];
      })

      // Sort items so that lists are on top and recipes underneath.
      // Plus everything is in alphabetical order.
      .sort(([aKey, aValue], [bKey, bValue]) =>
        isRecipeList(aValue) !== isRecipeList(bValue) ? (isRecipeList(aValue) ? -1 : 1) : aKey.localeCompare(bKey)
      )
  );

  return Object.keys(filteredList).length ? filteredList : undefined;
};

/**
 * Check whether recipe is recipe list or plain recipe.
 * Returns true if the recipe is recipe list, false othewise
 * @param recipe recipe to check
 */
const isRecipeList = (recipe: Recipe | RecipeList): recipe is RecipeList => {
  return recipe.uid === undefined;
};

/**
 * Calculates maximum possible multiplier for recipe to be made.
 * Returns number of times, recipe can be made.
 * @param recipe recipe to calculate multiplier for
 * @param amount available amount of resource used in passed recipe
 */
const calculateMultiplier = (recipe: Recipe, amount: number) => {
  if (recipe.required_amount > amount) {
    return 0;
  }

  return Math.floor(amount / recipe.required_amount);
};

type MultipliersProps = {
  recipe: Recipe;
  max_possible_multiplier: number;
};

const Multipliers = (props: MultipliersProps) => {
  const { act } = useBackend();

  const { recipe, max_possible_multiplier } = props;

  const max_available_multiplier = Math.min(
    max_possible_multiplier,
    Math.floor(recipe.max_result_amount / recipe.result_amount)
  );

  const multipliers = [5, 10, 25];

  const finalResult: React.JSX.Element[] = [];

  for (const multiplier of multipliers) {
    if (max_available_multiplier >= multiplier) {
      finalResult.push(
        <Button
          bold
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

type RecipeListProps = {
  recipes: RecipeList;
};

const RecipeListBox = (props: RecipeListProps) => {
  const { recipes } = props;

  return Object.entries(recipes).map((entry) => {
    const [title, recipe] = entry;
    if (isRecipeList(recipe)) {
      return (
        <Collapsible
          key={title}
          title={title}
          child_mt={0}
          childStyles={{
            padding: '0.5em',
            backgroundColor: 'rgba(62, 97, 137, 0.15)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            borderTop: 'none',
            borderRadius: '0 0 0.33em 0.33em',
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

const RecipeBox = (props: RecipeBoxProps) => {
  const { act, data } = useBackend<RecipesData>();
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

import { useBackend, useLocalState } from '../../backend';
import { createSearch, decodeHtmlEntities } from 'common/string';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { Box, Button, Input, Section, Stack } from '../../components';

export const pda_cookbook = (props, context) => {
  const { act, data } = useBackend(context);
  const { recipes } = data;

  const [recipeList, setRecipeList] = useLocalState(context, 'recipeList', recipes);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const SelectRecipes = (cookbook, searchText = '') => {
    const RecipeSearch = createSearch(searchText, (recipe) => {
      return recipe.name + '|' + recipe.container + '|' + recipe.instructions.toString();
    });

    return flow([
      filter((recipe) => recipe?.name),
      searchText && filter(RecipeSearch),
      sortBy((recipe) => recipe?.name),
    ])(cookbook);
  };

  const handleSearch = (value) => {
    setSearchText(value);
    if (value === '') {
      setRecipeList(recipes);
    }
    setRecipeList(SelectRecipes(recipes, value));
  };

  return (
    <Box>
      <Section
        title={'Recipe Search'}
        buttons={
          <Input
            width="200px"
            placeholder="Search Recipes"
            onInput={(e, value) => {
              handleSearch(value);
            }}
            value={searchText}
          />
        }
      >
        <Stack vertical>
          {recipeList.map((recipe, i) => (
            <Stack.Item key={i}>
              <Section title={decodeHtmlEntities(recipe.name)}>
                {recipe.container}:
                <ol>
                  {recipe.instructions.map((instruction, j) => (
                    <li key={`${i}-${j}`}>{instruction}</li>
                  ))}
                </ol>
              </Section>
            </Stack.Item>
          ))}
        </Stack>

        {/* {JSON.stringify(recipeList)} */}
        {/* {recipeList.map((r) => (
        <Box key={r}>{r.name}</Box>
      ))} */}
        {/* {JSON.stringify(recipes)} */}
      </Section>
    </Box>
  );
};

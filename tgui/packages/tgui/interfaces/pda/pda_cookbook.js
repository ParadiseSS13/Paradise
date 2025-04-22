import { useBackend, useLocalState } from '../../backend';
import { createSearch, decodeHtmlEntities } from 'common/string';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { Box, Button, Input, Section, Stack } from '../../components';

export const pda_cookbook = (props) => {
  const { act, data } = useBackend();
  const { categories, current_category, recipes, search_text } = data;

  const [recipeList, setRecipeList] = useLocalState('recipeList', recipes);
  const [searchText, setSearchText] = useLocalState('searchText', search_text);

  return (
    <Box>
      {categories.sort().map((category, i) => (
        <Button key={i} onClick={() => act('set_category', { name: category, search_text: searchText })}>
          {category}
        </Button>
      ))}
      {current_category && (
        <Section
          title={current_category}
          buttons={
            <Input
              width="200px"
              placeholder={`Search ${current_category}`}
              onInput={(e, value) => setSearchText(value)}
              value={searchText}
            />
          }
        >
          <Stack vertical>
            {recipes
              .filter(
                createSearch(searchText, (recipe) => {
                  return recipe.name + '|' + recipe.container + '|' + recipe.instructions.toString();
                })
              )
              .sort((a, b) => a?.name.localeCompare(b?.name))
              .map((recipe, i) => (
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
        </Section>
      )}
    </Box>
  );
};

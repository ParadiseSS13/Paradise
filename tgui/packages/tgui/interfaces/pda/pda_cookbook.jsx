import { useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';
import { createSearch, decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../../backend';

export const pda_cookbook = (props) => {
  const { act, data } = useBackend();
  const { categories, current_category, recipes, search_text } = data;

  const [recipeList, setRecipeList] = useState(recipes);
  const [searchText, setSearchText] = useState(search_text);

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
              value={searchText}
              onChange={(value) => setSearchText(value)}
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

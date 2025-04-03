import { useBackend, useLocalState } from '../../backend';
import { createSearch, decodeHtmlEntities } from 'common/string';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { Box, Button, Input, Section, Stack } from '../../components';

export const pda_cookbook = (props, context) => {
  const { act, data } = useBackend(context);
  const { categories, current_category, procedures, search_text } = data;

  const [procedureList, setprocedureList] = useLocalState(context, 'procedureList', procedures);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', search_text);

  return (
    <Box>
      <div className="JobGuide__left">
        {' '}
        {categories.sort().map((category, i) => (
          <Button key={i} onClick={() => act('set_category', { name: category, search_text: searchText })}>
            {category}
          </Button>
        ))}
      </div>
      <div className="JobGuide__right">
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
              {procedures
                .filter(
                  createSearch(searchText, (procedure) => {
                    return procedure.name + '|' + procedure.instructions.toString();
                  })
                )
                .sort((a, b) => a?.name.localeCompare(b?.name))
                .map((procedure, i) => (
                  <Stack.Item key={i}>
                    <Section title={decodeHtmlEntities(procedure.name)}>
                      {procedure.container}:
                      <ol>
                        {procedure.instructions.map((instruction, j) => (
                          <li key={`${i}-${j}`}>{instruction}</li>
                        ))}
                      </ol>
                    </Section>
                  </Stack.Item>
                ))}
            </Stack>
          </Section>
        )}
      </div>
    </Box>
  );
};

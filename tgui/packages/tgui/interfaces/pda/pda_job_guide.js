import { useBackend, useLocalState } from '../../backend';
import { createSearch, decodeHtmlEntities } from 'common/string';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { Box, Button, Input, Section, Stack, Tabs, Dropdown } from '../../components';

export const pda_job_guide = (props, context) => {
  const { act, data } = useBackend(context);
  const { categories, current_category, procedures, search_text, job_list, job } = data;
  const [procedureList, setprocedureList] = useLocalState(context, 'procedureList', procedures);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', search_text);

  return (
    <Box>
      <Stack horizontal>
        Role:
        <Dropdown
          width="215px"
          options={job_list}
          selected={job}
          onSelected={(val) =>
            act('select_job', {
              job: val,
            })
          }
        />
        Category:
        <Dropdown
          width="215px"
          options={categories}
          selected={current_category}
          onSelected={(category) => act('set_category', { name: category, search_text: searchText })}
        />
      </Stack>
      {current_category && (
        <Section
          title={
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
    </Box>
  );
};

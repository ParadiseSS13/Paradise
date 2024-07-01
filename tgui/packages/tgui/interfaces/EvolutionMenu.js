import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack, Tabs, Input } from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';

export const EvolutionMenu = (props, context) => {
  return (
    <Window width={480} height={580} theme="changeling">
      <Window.Content>
        <Stack fill vertical>
          <EvolutionPoints />
          <Abilities />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const EvolutionPoints = (props, context) => {
  const { act, data } = useBackend(context);
  const { evo_points, can_respec } = data;
  return (
    <Stack.Item>
      <Section title="Evolution Points" height={5.5}>
        <Stack>
          <Stack.Item mt={0.5} color="label">
            Points remaining:
          </Stack.Item>
          <Stack.Item mt={0.5} ml={2} bold color="#1b945c">
            {evo_points}
          </Stack.Item>
          <Stack.Item>
            <Button ml={2.5} disabled={!can_respec} content="Readapt" icon="sync" onClick={() => act('readapt')} />
            <Button
              tooltip="By transforming a humanoid into a husk, \
              we gain the ability to readapt our chosen evolutions."
              tooltipPosition="bottom"
              icon="question-circle"
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const Abilities = (props, context) => {
  const { act, data } = useBackend(context);
  const { evo_points, ability_tabs, purchased_abilities, view_mode } = data;
  const [selectedTab, setSelectedTab] = useLocalState(context, 'selectedTab', ability_tabs[0]);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [abilities, setAbilities] = useLocalState(context, 'ability_tabs', ability_tabs[0].abilities);

  const selectAbilities = (abilities, searchText = '') => {
    if (!abilities || abilities.length === 0) {
      return [];
    }

    const AbilitySearch = createSearch(searchText, (ability) => {
      return ability.name + '|' + ability.description;
    });

    return flow([filter((ability) => ability?.name), filter(AbilitySearch), sortBy((ability) => ability?.name)])(
      abilities
    );
  };

  const handleSearch = (value) => {
    setSearchText(value);
    if (value === '') {
      return setAbilities(selectedTab.abilities);
    }

    setAbilities(selectAbilities(ability_tabs.map((ability_entry) => ability_entry.abilities).flat(), value));
  };

  const handleTabChange = (selectedTab) => {
    setSelectedTab(selectedTab);
    setAbilities(selectedTab.abilities);
    setSearchText('');
  };

  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title="Abilities"
        buttons={
          <>
            <Input
              width="200px"
              placeholder="Search Abilities"
              onInput={(e, value) => {
                handleSearch(value);
              }}
              value={searchText}
            />
            <Button
              icon={!view_mode ? 'check-square-o' : 'square-o'}
              selected={!view_mode}
              content="Compact"
              onClick={() =>
                act('set_view_mode', {
                  mode: 0,
                })
              }
            />
            <Button
              icon={view_mode ? 'check-square-o' : 'square-o'}
              selected={view_mode}
              content="Expanded"
              onClick={() =>
                act('set_view_mode', {
                  mode: 1,
                })
              }
            />
          </>
        }
      >
        <Tabs>
          {ability_tabs.map((tab) => (
            <Tabs.Tab
              key={tab}
              selected={searchText === '' && selectedTab === tab}
              onClick={() => {
                handleTabChange(tab);
              }}
            >
              {tab.category}
            </Tabs.Tab>
          ))}
        </Tabs>
        {abilities.map((ability, i) => (
          <Box key={i} p={0.5} mx={-1} className="candystripe">
            <Stack align="center">
              <Stack.Item ml={0.5} color="#dedede">
                {ability.name}
              </Stack.Item>
              {purchased_abilities.includes(ability.power_path) && (
                <Stack.Item ml={2} bold color="#1b945c">
                  (Purchased)
                </Stack.Item>
              )}
              <Stack.Item mr={3} textAlign="right" grow={1}>
                <Box as="span" color="label">
                  Cost:{' '}
                </Box>
                <Box as="span" bold color="#1b945c">
                  {ability.cost}
                </Box>
              </Stack.Item>
              <Stack.Item textAlign="right">
                <Button
                  mr={0.5}
                  disabled={ability.cost > evo_points || purchased_abilities.includes(ability.power_path)}
                  content="Evolve"
                  onClick={() =>
                    act('purchase', {
                      power_path: ability.power_path,
                    })
                  }
                />
              </Stack.Item>
            </Stack>
            {!!view_mode && (
              <Stack color="#8a8a8a" my={1} ml={1.5} width="95%">
                {ability.description + ' ' + ability.helptext}
              </Stack>
            )}
          </Box>
        ))}
      </Section>
    </Stack.Item>
  );
};

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, LabeledList, Tabs, Icon, Input } from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { createSearch, capitalize } from 'common/string';

export const AugmentMenu = (props, context) => {
  return (
    <Window width={700} height={700} theme="malfunction">
      <Window.Content>
        <Box scrollable>
          <Abilities />
        </Box>
      </Window.Content>
    </Window>
  );
};

const Abilities = (props, context) => {
  const { act, data } = useBackend(context);
  const { usable_swarms, ability_tabs, known_abilities } = data;

  const [selectedTab, setSelectedTab] = useLocalState(context, 'selectedTab', ability_tabs[0]);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [abilities, setAbilities] = useLocalState(context, 'abilities', selectedTab.abilities);

  const selectAbilities = (abilities, searchText = '') => {
    if (!abilities || abilities.length === 0) {
      return [];
    }

    const AbilitySearch = createSearch(searchText, (ability) => {
      return ability.name + '|' + ability.desc;
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

  const handleTabChange = (tab) => {
    setSelectedTab(tab);
    if (tab.category_name === 'Upgrades') {
      setSearchText('');
      return;
    }
    const abilitiesToDisplay = tab.abilities.filter((ability) => ability.stage <= tab.category_stage);
    setAbilities(abilitiesToDisplay);
    setSearchText('');
  };

  return (
    <Section
      title={'Swarms: ' + usable_swarms}
      buttons={
        <Input
          width="200px"
          placeholder="Search Abilities"
          onInput={(e, value) => {
            handleSearch(value);
          }}
          value={searchText}
        />
      }
    >
      <Tabs mb={2}>
        {ability_tabs.map((tab) => (
          <Tabs.Tab key={tab.category_name} selected={selectedTab === tab} onClick={() => handleTabChange(tab)}>
            {capitalize(tab.category_name)}
          </Tabs.Tab>
        ))}
        <Tabs.Tab
          key="upgrades"
          selected={selectedTab.category_name === 'Upgrades'}
          onClick={() => handleTabChange({ category_name: 'Upgrades' })}
        >
          Upgrades
        </Tabs.Tab>
      </Tabs>
      {selectedTab.category_name === 'Upgrades' ? (
        <Upgrades />
      ) : (
        abilities.map((ability) => (
          <Box key={ability.name} direction="row" align="left">
            <Box>
              <Button
                height="20px"
                width="35px"
                mb={1}
                mr="1rem"
                textAlign="center"
                content={ability.cost}
                disabled={ability.cost > usable_swarms}
                tooltip="Purchase this ability?"
                onClick={() => act('purchase', { ability_path: ability.ability_path })}
              />
              <Box as="span" fontSize="1.4rem">
                {ability.name}
              </Box>
              <br />
              <Box as="span" fontSize="1.1rem">
                {ability.desc}
              </Box>
              <hr color="gray" />
            </Box>
          </Box>
        ))
      )}
    </Section>
  );
};

const Upgrades = (props, context) => {
  const { act, data } = useBackend(context);
  const { usable_swarms, known_abilities } = data;
  return (
    <Box>
      {known_abilities.map(
        (ability, i) =>
          ability.current_level < ability.max_level && (
            <Box key={ability.name} direction="row" align="left">
              <Button
                height="20px"
                width="35px"
                mb={1}
                mr="1rem"
                content={ability.cost}
                disabled={ability.cost > usable_swarms}
                tooltip="Upgrade this ability?"
                onClick={() => act('purchase', { ability_path: ability.ability_path })}
              />
              <Box as="span" fontSize="1.4rem">
                {ability.name}
              </Box>
              <br />
              <Box as="span" fontSize="1.1rem">
                {ability.upgrade_text}
              </Box>
              <Box color="green">
                Level: {ability.current_level} / {ability.max_level}
              </Box>
              <hr color="gray" />
            </Box>
          )
      )}
    </Box>
  );
};

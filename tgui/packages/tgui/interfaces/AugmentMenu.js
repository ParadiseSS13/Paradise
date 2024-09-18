import { useBackend, useLocalState } from '../backend';
import { Stack, Button, Section, Tabs, Input } from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { createSearch, capitalize } from 'common/string';

export const AugmentMenu = (props, context) => {
  return (
    <Window width={700} height={660} theme="malfunction">
      <Window.Content>
        <Stack vertical>
          <Abilities />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Abilities = (props, context) => {
  const { act, data } = useBackend(context);
  const { usable_swarms, ability_tabs } = data;
  const [selectedTab, setSelectedTab] = useLocalState(context, 'selectedTab', ability_tabs[0]);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [abilities, setAbilities] = useLocalState(context, 'abilities', selectedTab.abilities);

  const selectAbilities = (abilities) => {
    if (!abilities) return [];
    return flow([filter((ability) => ability?.name), sortBy((ability) => ability?.name)])(abilities);
  };

  const handleSearch = (value) => {
    setSearchText(value);
    const abilitiesToDisplay = value
      ? selectAbilities(
          ability_tabs
            .flatMap((tab) => tab.abilities)
            .filter((ability) => ability.name.toLowerCase().includes(value.toLowerCase()))
        )
      : selectedTab.abilities;
    setAbilities(abilitiesToDisplay);
  };

  const handleTabChange = (tab) => {
    setSelectedTab(tab);
    setSearchText('');
    const abilitiesToDisplay =
      tab.category_name === 'Upgrades' ? [] : tab.abilities.filter((ability) => ability.stage <= tab.category_stage);
    setAbilities(abilitiesToDisplay);
  };

  return (
    <Section
      title={`Swarms: ${usable_swarms}`}
      buttons={
        <Input
          width="200px"
          placeholder="Search Abilities"
          onInput={(e, value) => handleSearch(value)}
          value={searchText}
        />
      }
    >
      <Tabs>
        {ability_tabs.map((tab) => (
          <Tabs.Tab
            key={tab.category_name}
            selected={selectedTab.category_name === tab.category_name}
            onClick={() => handleTabChange(tab)}
          >
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
        <Stack vertical>
          {abilities.map((ability) => (
            <Stack.Item key={ability.name} direction="row">
              <Stack>
                <Button
                  height="20px"
                  width="35px"
                  mb={1}
                  textAlign="center"
                  content={ability.cost}
                  disabled={ability.cost > usable_swarms}
                  tooltip="Purchase this ability?"
                  onClick={() => act('purchase', { ability_path: ability.ability_path })}
                />
                <Stack.Item fontSize="16px">{ability.name}</Stack.Item>
              </Stack>
              <Stack.Item>
                <Stack vertical>
                  <Stack.Item fontSize="13px">{ability.desc}</Stack.Item>
                  <Stack.Divider />
                </Stack>
              </Stack.Item>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const Upgrades = (props, context) => {
  const { act, data } = useBackend(context);
  const { usable_swarms, known_abilities } = data;

  return (
    <Stack vertical>
      {known_abilities.map(
        (ability) =>
          ability.current_level < ability.max_level && (
            <Stack.Item key={ability.name} direction="row">
              <Stack>
                <Button
                  height="20px"
                  width="35px"
                  mb={1}
                  textAlign="center"
                  content={ability.cost}
                  disabled={ability.cost > usable_swarms}
                  tooltip="Upgrade this ability?"
                  onClick={() => act('purchase', { ability_path: ability.ability_path })}
                />
                <Stack.Item fontSize="16px">{ability.name}</Stack.Item>
              </Stack>
              <Stack.Item>
                <Stack vertical>
                  <Stack.Item fontSize="13px">{ability.upgrade_text}</Stack.Item>
                  <Stack.Item color="green" fontSize="13px">
                    Level: {ability.current_level} / {ability.max_level}
                  </Stack.Item>
                  <Stack.Divider />
                </Stack>
              </Stack.Item>
            </Stack.Item>
          )
      )}
    </Stack>
  );
};

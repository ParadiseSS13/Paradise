import { useBackend, useLocalState } from '../backend';
import { Stack, Button, Section, Tabs, Input } from '../components';
import { Window } from '../layouts';
import { capitalize } from 'common/string';

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
  const { usable_swarms, ability_tabs, known_abilities } = data; // Include known_abilities
  const [selectedTab, setSelectedTab] = useLocalState(context, 'selectedTab', ability_tabs[0]);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const getFilteredAbilities = () => {
    const currentTab = ability_tabs.find((tab) => tab.category_name === selectedTab.category_name);
    if (!currentTab) return [];

    return currentTab.abilities.filter(
      (ability) =>
        ability.stage <= currentTab.category_stage &&
        (!searchText || ability.name.toLowerCase().includes(searchText.toLowerCase()))
    );
  };

  const handleSearch = (value) => {
    setSearchText(value);
  };

  const handleTabChange = (tab) => {
    setSelectedTab(tab);
    setSearchText('');
  };

  const abilities = getFilteredAbilities();

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
          {abilities.map((ability) => {
            const knownAbility = known_abilities.find((a) => a.ability_path === ability.ability_path);
            const currentCost = knownAbility ? knownAbility.cost : ability.cost;

            return (
              <Stack.Item key={ability.name} direction="row">
                <Stack>
                  <Button
                    height="20px"
                    width="35px"
                    mb={1}
                    textAlign="center"
                    content={currentCost} // Show the current cost from known_abilities
                    disabled={currentCost > usable_swarms}
                    tooltip="Purchase this ability?"
                    onClick={() => {
                      act('purchase', { ability_path: ability.ability_path });
                      setSelectedTab(selectedTab); // Refresh to update ability costs
                    }}
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
            );
          })}
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

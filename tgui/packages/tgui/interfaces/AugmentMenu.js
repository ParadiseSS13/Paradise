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
  const { usable_swarms, ability_tabs, known_abilities } = data;
  const [selectedTab, setSelectedTab] = useLocalState(context, 'selectedTab', ability_tabs[0]);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const currentTab = ability_tabs.find((tab) => tab.category_name === selectedTab.category_name) || {};
  const { abilities = [], category_stage } = currentTab;

  const filteredAbilities = abilities.filter((ability) => {
    const isWithinStage = ability.stage <= Math.min(category_stage, 4);
    const matchesSearch = !searchText || ability.name.toLowerCase().includes(searchText.toLowerCase());
    return isWithinStage && matchesSearch;
  });

  const handleSearch = (value) => setSearchText(value);
  const handleTabChange = (tab) => {
    setSelectedTab(tab);
    setSearchText('');
  };

  const showStage = ['intruder', 'destroyer'].includes(selectedTab.category_name.toLowerCase());

  const renderAbilityButton = (ability, currentCost, knownAbility) => (
    <Button
      height="20px"
      width="35px"
      mb={1}
      textAlign="center"
      content={currentCost}
      disabled={currentCost > usable_swarms || (knownAbility && knownAbility.current_level === knownAbility.max_level)}
      tooltip="Purchase this ability?"
      onClick={() => {
        act('purchase', { ability_path: ability.ability_path });
        setSelectedTab(selectedTab);
      }}
    />
  );

  return (
    <Section
      title={
        <Stack vertical>
          <span>Swarms: {usable_swarms}</span>
          {showStage && <span>Stage: {Math.min(category_stage, 4)}</span>}
        </Stack>
      }
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
          selected={selectedTab.category_name === 'upgrades'}
          onClick={() => handleTabChange({ category_name: 'upgrades' })}
        >
          Upgrades
        </Tabs.Tab>
      </Tabs>
      {selectedTab.category_name === 'upgrades' ? (
        <Upgrades />
      ) : (
        <Stack vertical>
          {filteredAbilities.map((ability) => {
            const knownAbility = known_abilities.find((a) => a.ability_path === ability.ability_path);
            const currentCost = knownAbility ? knownAbility.cost : ability.cost;

            return (
              <Stack.Item key={ability.name} direction="row">
                <Stack>
                  {renderAbilityButton(ability, currentCost, knownAbility)}
                  <Stack.Item fontSize="16px">{ability.name}</Stack.Item>
                </Stack>
                <Stack.Item>
                  <Stack vertical>
                    <Stack.Item fontSize="13px">{ability.desc}</Stack.Item>
                    <Stack.Item color="green">
                      Level: {knownAbility?.current_level || 0} / {ability.max_level}
                    </Stack.Item>
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

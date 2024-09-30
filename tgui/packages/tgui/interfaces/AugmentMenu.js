import { useBackend, useLocalState } from '../backend';
import { Stack, Button, Section, Tabs, Input } from '../components';
import { Window } from '../layouts';
import { capitalize } from 'common/string';

export const AugmentMenu = (props, context) => {
  return (
    <Window width={700} height={660} theme="malfunction">
      <Window.Content>
        <Stack vertical>
          <Abilities context={context} />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Abilities = ({ context }) => {
  const { act, data } = useBackend(context);
  const { usable_swarms, ability_tabs, known_abilities } = data;
  const [selectedTab, setSelectedTab] = useLocalState(context, 'selectedTab', ability_tabs[0]);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const getFilteredAbilities = () => {
    const currentTab = ability_tabs.find((tab) => tab.category_name === selectedTab.category_name);
    if (!currentTab) return [];

    const maxStage = Math.min(currentTab.category_stage, 4);
    return currentTab.abilities
      .filter(
        (ability) =>
          ability.stage <= maxStage && (!searchText || ability.name.toLowerCase().includes(searchText.toLowerCase()))
      )
      .sort((a, b) =>
        ['intruder', 'destroyer'].includes(selectedTab.category_name.toLowerCase()) ? a.stage - b.stage : 0
      );
  };

  const abilities = getFilteredAbilities();
  const currentTab = ability_tabs.find((tab) => tab.category_name === selectedTab.category_name);
  const showStage = ['intruder', 'destroyer'].includes(selectedTab.category_name.toLowerCase());

  const renderAbility = (ability) => {
    const knownAbility = known_abilities.find((a) => a.ability_path === ability.ability_path);
    const currentCost = knownAbility ? knownAbility.cost : ability.cost;
    const levelInfo =
      knownAbility && knownAbility.current_level > 0
        ? `${knownAbility.current_level} / ${knownAbility.max_level}`
        : `0 / ${ability.max_level}`;

    return (
      <Stack.Item key={ability.name} direction="row">
        <Stack>
          <Button
            height="20px"
            width="35px"
            mb={1}
            textAlign="center"
            content={currentCost}
            disabled={
              currentCost > usable_swarms || (knownAbility && knownAbility.current_level === knownAbility.max_level)
            }
            tooltip="Purchase this ability?"
            onClick={() => {
              act('purchase', { ability_path: ability.ability_path });
              setSelectedTab(selectedTab);
            }}
          />
          <Stack.Item fontSize="16px">{ability.name}</Stack.Item>
        </Stack>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item fontSize="13px">{ability.desc}</Stack.Item>
            <Stack.Item color="green">
              Level: {levelInfo}
              {showStage && ability.stage > 0 && <span> (Stage: {ability.stage})</span>}
            </Stack.Item>
            <Stack.Divider />
          </Stack>
        </Stack.Item>
      </Stack.Item>
    );
  };

  return (
    <Section
      title={
        <div style={{ display: 'flex', alignItems: 'center' }}>
          <Stack vertical style={{ marginRight: '10px' }}>
            <span>Swarms: {usable_swarms}</span>
            {showStage && currentTab && <span>Category Stage: {Math.min(currentTab.category_stage, 4)}</span>}
          </Stack>
          <div className="Section__buttons">
            <Input
              width="200px"
              placeholder="Search Abilities"
              onInput={(e, value) => setSearchText(value)}
              value={searchText}
            />
          </div>
        </div>
      }
    >
      <Tabs>
        {ability_tabs.map((tab) => (
          <Tabs.Tab
            key={tab.category_name}
            selected={selectedTab.category_name === tab.category_name}
            onClick={() => {
              setSelectedTab(tab);
              setSearchText('');
            }}
          >
            {capitalize(tab.category_name)}
          </Tabs.Tab>
        ))}
        <Tabs.Tab
          key="upgrades"
          selected={selectedTab.category_name === 'upgrades'}
          onClick={() => setSelectedTab({ category_name: 'upgrades' })}
        >
          Upgrades
        </Tabs.Tab>
      </Tabs>
      {selectedTab.category_name === 'upgrades' ? (
        <Upgrades act={act} abilityTabs={ability_tabs} knownAbilities={known_abilities} usableSwarms={usable_swarms} />
      ) : (
        <Stack vertical>{abilities.map(renderAbility)}</Stack>
      )}
    </Section>
  );
};

const Upgrades = ({ act, abilityTabs, knownAbilities, usableSwarms }) => {
  const relevantAbilities = abilityTabs
    .flatMap((tab) =>
      tab.abilities.filter((ability) =>
        knownAbilities.some(
          (known) => known.ability_path === ability.ability_path && known.current_level < known.max_level
        )
      )
    )
    .sort((a, b) => a.stage - b.stage);

  const renderAbility = (ability) => {
    const knownAbility = knownAbilities.find((a) => a.ability_path === ability.ability_path);

    return (
      <Stack.Item key={ability.name} direction="row">
        <Stack>
          <Button
            height="20px"
            width="35px"
            mb={1}
            textAlign="center"
            content={ability.cost}
            disabled={ability.cost > usableSwarms}
            tooltip="Upgrade this ability?"
            onClick={() => act('purchase', { ability_path: ability.ability_path })}
          />
          <Stack.Item fontSize="16px">{ability.name}</Stack.Item>
        </Stack>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item fontSize="13px">{ability.desc}</Stack.Item>
            <Stack.Item color="green" fontSize="13px">
              Level: {knownAbility.current_level} / {knownAbility.max_level}
              {ability.stage > 0 && <span> (Stage: {ability.stage})</span>}
            </Stack.Item>
            <Stack.Divider />
          </Stack>
        </Stack.Item>
      </Stack.Item>
    );
  };

  return <Stack vertical>{relevantAbilities.map(renderAbility)}</Stack>;
};

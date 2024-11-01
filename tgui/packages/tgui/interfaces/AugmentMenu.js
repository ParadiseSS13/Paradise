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
            <Stack.Item fontSize="13px">{ability.desc || 'Description not available'}</Stack.Item>
            <Stack.Item>
              Level: <span style={{ color: 'green' }}>{levelInfo}</span>
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
            <span>
              Swarms: <span style={{ color: 'green' }}>{usable_swarms}</span>
            </span>
            {showStage && currentTab && (
              <span>
                Category Stage: <span style={{ color: 'green' }}>{Math.min(currentTab.category_stage, 4)}</span>
              </span>
            )}
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
  const relevantAbilities = knownAbilities.filter((known) => known.current_level < known.max_level);
  const renderAbility = (knownAbility) => {
    const currentAbility = abilityTabs
      .flatMap((tab) => tab.abilities)
      .find((ability) => ability.ability_path === knownAbility.ability_path);

    return (
      <Stack.Item key={knownAbility.name} direction="row">
        <Stack>
          <Button
            height="20px"
            width="35px"
            mb={1}
            textAlign="center"
            content={knownAbility.cost}
            disabled={knownAbility.cost > usableSwarms}
            tooltip="Upgrade this ability?"
            onClick={() => act('purchase', { ability_path: knownAbility.ability_path })}
          />
          <Stack.Item fontSize="16px">{knownAbility.name}</Stack.Item>
        </Stack>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item fontSize="13px">{knownAbility.upgrade_text}</Stack.Item>
            <Stack.Item>
              Level:{' '}
              <span style={{ color: 'green' }}>{`${knownAbility.current_level} / ${knownAbility.max_level}`}</span>
              {currentAbility && currentAbility.stage > 0 && <span> (Stage: {currentAbility.stage})</span>}
            </Stack.Item>
            <Stack.Divider />
          </Stack>
        </Stack.Item>
      </Stack.Item>
    );
  };
  return <Stack vertical>{relevantAbilities.map(renderAbility)}</Stack>;
};

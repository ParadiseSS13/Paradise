import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, LabeledList, Tabs, Icon, Stack, Input} from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { createSearch } from 'common/string';
/*
* Abandon all hope ye who enter here whom know what good javascript looks like
*/
export const AugmentMenu = (props, context) => {
  return (
    <Window width={700} height={700} theme="changeling">
      <Window.Content>
        <Stack fill vertical>
          <Abilities/>
          <Upgrades // Not sure if I'll be lazy and keep upgrades down here, or move them into a separate tab
          />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Abilities = (props, context) => {
  const { act, data } = useBackend(context);
  const {usable_swarms, ability_tabs, known_abilities} = data;

  const [selectedTab, setSelectedTab] = useLocalState(context, 'selectedTab', ability_tabs[0]);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [abilities, setAbilities] = useLocalState(context, 'abilities', ability_tabs[0].abilities);
  const newCategory = ability_tabs[0].abilities;

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
  }

  const handleTabChange = (selectedTab) => {
    setSelectedTab(selectedTab);
    setAbilities(selectedTab.abilities);
    setSearchText('');
  };

  return(
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title={"Swarms: " + usable_swarms}
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
    <Tabs>
    {ability_tabs.map((tab) => (
      <Tabs.Tab
        key={tab.category_name}
        selected={searchText === '' && selectedTab === tab}
        onClick={() => {
          handleTabChange(tab);
        }}
      >
        {tab.category_name}
      </Tabs.Tab>
    ))}
    </Tabs>
    {abilities.map((ability, i) => {
    return (
          <Stack.Item p={1}
            key = {i}
            textAlign = "left"
            grow = {1}>
              <Box>
                <Stack allign = "center">
                  <Stack.Item mr = {8}>
                    {ability.name}
                  </Stack.Item>
                {ability.desc}
                <Stack.Item textAlign = "right">
                  <Button
                    content = {ability.cost}
                    icon = "minus"
                    disabled = {ability.cost > usable_swarms}
                    tooltip = "Purchase this ability?"
                    onClick={() => act("purchase", {ability_path: ability.ability_path}
                      )}
                    textAlign = "right"/>
                  </Stack.Item>
                </Stack>
          </Box>
        </Stack.Item>
    );
  })}
    </Section>
  </Stack.Item>
  );
}
const Upgrades = (props, context) => {
  const { act, data } = useBackend(context);
  const {usable_swarms, known_abilities} = data;
  return(
    <Stack.Item grow>
      <Section
      fill
      scrollable
      title = "Potential Upgrades">
      {known_abilities.map((ability, i) =>{
        return(
          ability.current_level < ability.max_level && // Putting this logic expression here means itll only render if this is true
        <Box
        key = {i}>
          <Stack>
            <Stack.Item
            bold>
              {ability.name}
            </Stack.Item>
            <Stack.Item
            fontSize = {1.2}
            >
              {ability.upgrade_text}
            </Stack.Item>
            <Stack.Item>
              <Box>
              CURRENT LEVEL: {ability.current_level} MAX LEVEL:{ability.max_level}
              <Button
                content = {ability.cost}
                  icon = "minus"
                  disabled = {ability.cost > usable_swarms}
                  tooltip = "Upgrade this ability?"
                  onClick={() => act("purchase", {ability_path: ability.ability_path}
                      )}
                  textAlign = "right"/>
                </Box>
            </Stack.Item>
          </Stack>
        </Box>
      );
      })}
      </Section>
    </Stack.Item>
  );
}

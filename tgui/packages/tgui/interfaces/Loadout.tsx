import { useBackend, useLocalState } from '../backend';
import { Box, ImageButton, Button, Input, Section, Tabs, ProgressBar, Stack, Icon, Tooltip } from '../components';
import { Window } from '../layouts';

type Data = {
  user_tier: number;
  gear_slots: number;
  max_gear_slots: number;
  selected_gears: string[];
  gears: Record<string, Gear[]>;
};

type Gear = {
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
  category: string;
  cost: number;
  gear_tier: number;
  allowed_roles: string[];
  tweaks_display_type: Record<string, string>;
};

const TweakDisplay = (display_type: string, metadata: string) => {
  switch (display_type) {
    case 'color':
      return <Icon name="circle" color={metadata ? metadata : 'white'} />;
    case 'edit':
      return (
        <Tooltip content={metadata} position="top">
          <Icon name="pen-to-square" />
        </Tooltip>
      );
    default:
      return <Icon name="bug" color="red" />;
  }
};

const filterGears = (gears: Record<string, Gear[]>, searchText: string, selectedCategory: string) => {
  return Object.entries(gears).flatMap(([key, gearList]) =>
    gearList
      .filter((gear: Gear) =>
        searchText ? gear.name.toLowerCase().includes(searchText.toLowerCase()) : gear.category === selectedCategory
      )
      .map((gear: Gear) => ({ ...gear, key }))
  );
};

const getCategories = (gears: Record<string, Gear[]>): string[] => {
  return Array.from(
    new Set(
      Object.values(gears)
        .flat()
        .map((gear) => gear.category)
    )
  );
};

export const Loadout = (props, context) => {
  const [search, setSearch] = useLocalState(context, 'search', false);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [selectedCategory, setSelectedCategory] = useLocalState(context, 'selectedCategory', 'Accessories');

  return (
    <Window width={975} height={650}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <LoadoutCategories selectedCategory={selectedCategory} setSelectedCategory={setSelectedCategory} />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item basis="25%">
                <LoadoutEquipped />
              </Stack.Item>
              <Stack.Item basis="75%">
                <LoadoutGears
                  selectedCategory={selectedCategory}
                  search={search}
                  setSearch={setSearch}
                  searchText={searchText}
                  setSearchText={setSearchText}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const LoadoutCategories = ({ selectedCategory, setSelectedCategory }, context) => {
  const { data } = useBackend<Data>(context);
  const { gears } = data;
  const categories = getCategories(gears);

  return (
    <Tabs fluid textAlign="center" styles={{ 'flex-wrap': 'wrap-reverse' }}>
      {categories.map((category) => (
        <Tabs.Tab key={category} selected={category === selectedCategory} onClick={() => setSelectedCategory(category)}>
          {category}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};

const LoadoutGears = ({ selectedCategory, search, setSearch, searchText, setSearchText }, context) => {
  const { act, data } = useBackend<Data>(context);
  const { gears, selected_gears } = data;
  const filteredGears = filterGears(gears, searchText, selectedCategory);

  return (
    <Section
      fill
      scrollable
      title={selectedCategory}
      buttons={
        <>
          {search && (
            <Input
              width={20}
              placeholder="Search..."
              value={searchText}
              onInput={(e) => setSearchText(e.target.value)}
            />
          )}
          <Button
            icon="magnifying-glass"
            selected={search}
            tooltip="Toggle search field"
            tooltipPosition="bottom-end"
            onClick={() => {
              setSearch(!search);
              setSearchText('');
            }}
          />
        </>
      }
    >
      {filteredGears.map((gear) => (
        <ImageButton
          key={gear.key}
          m={0.5}
          imageSize={84}
          dmIcon={gear.icon}
          dmIconState={gear.icon_state}
          tooltip={
            gear.name.length > 12 || gear.gear_tier > 0 ? (
              <Box>
                {gear.name.length > 12 && <Box>{gear.name}</Box>}
                {gear.gear_tier > 0 && (
                  <Box mt={1.5} textColor="red">
                    That gear is only available at a higher donation tier than you are on.
                  </Box>
                )}
              </Box>
            ) : (
              ''
            )
          }
          tooltipPosition={'bottom'}
          selected={Object.keys(selected_gears).includes(gear.key)}
          disabled={gear.gear_tier > 0}
          buttons={
            <>
              {gear.allowed_roles && (
                <Button
                  width="22px"
                  color="transparent"
                  icon="user"
                  tooltip={
                    <Section m={-1} title="Allowed Roles">
                      {gear.allowed_roles.map((role) => (
                        <Box key={role}>{role}</Box>
                      ))}
                    </Section>
                  }
                  tooltipPosition="left"
                />
              )}
              {Object.keys(gear.tweaks_display_type).map((tweak) => (
                <Button
                  key={tweak}
                  width="22px"
                  color="transparent"
                  onClick={() => {
                    act('set_tweak', { gear: gear.key, tweak: tweak });
                  }}
                >
                  {TweakDisplay(
                    gear.tweaks_display_type[tweak],
                    Object.keys(selected_gears).includes(gear.key)
                      ? Object.keys(selected_gears[gear.key]).includes(tweak)
                        ? selected_gears[gear.key][tweak]
                        : null
                      : null
                  )}
                </Button>
              ))}
              {/* Place here other tooltip buttons */}
              <Button width="22px" color="transparent" icon="info" tooltip={gear.desc} tooltipPosition="top" />
            </>
          }
          buttonsAlt={
            gear.gear_tier > 0 && (
              <Box lineHeight={1.75} style={{ 'text-shadow': '0 0 3px 6px rgba(0, 0, 0, 0.5)' }}>
                Tier {gear.gear_tier}
              </Box>
            )
          }
          onClick={() => act('toggle_gear', { gear: gear.key })}
        >
          {gear.name}
        </ImageButton>
      ))}
    </Section>
  );
};

const LoadoutEquipped = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { gears, selected_gears } = data;

  const filteredGears = Object.entries(gears).flatMap(([key, gearList]) =>
    gearList.filter(() => Object.keys(selected_gears).includes(key)).map((gear) => ({ ...gear, key }))
  );

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={'Selected Equipment'}
          buttons={
            <Button.Confirm
              icon="trash"
              tooltip={'Clear Loadout'}
              tooltipPosition={'bottom-end'}
              onClick={() => act('clear_loadout')}
            />
          }
        >
          {filteredGears.map((gear) => (
            <ImageButton
              key={gear.key}
              fluid
              imageSize={32}
              dmIcon={gear.icon}
              dmIconState={gear.icon_state}
              buttons={
                <Button
                  translucent
                  icon="times"
                  iconColor="red"
                  width="32px"
                  onClick={() => act('toggle_gear', { gear: gear.key })}
                />
              }
            >
              {gear.name}
            </ImageButton>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <ProgressBar value={data.gear_slots} maxValue={data.max_gear_slots} styles={{ textAlign: 'center' }}>
            <Box textAlign="center">
              Used points {data.gear_slots}/{data.max_gear_slots}
            </Box>
          </ProgressBar>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

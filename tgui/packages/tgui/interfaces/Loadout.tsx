import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Dimmer, ImageButton, Button, Input, Section, Tabs, ProgressBar, Stack, LabeledList } from '../components';
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
  tweaks: Record<string, Tweak[]>;
};

type Tweak = {
  name: string;
  icon: string;
  tooltip: string;
};

const filterGears = (gears: Record<string, Gear[]>, searchText: string, selectedCategory: string) => {
  const searching = createSearch<Gear>(searchText, (gear) => gear.name);

  return Object.entries(gears).flatMap(([key, gearList]) =>
    gearList
      .filter((gear) => (searchText ? searching(gear) : gear.category === selectedCategory))
      .map((gear) => ({ ...gear, key }))
  );
};

const getGearTweaks = (gear: Gear) => {
  return Object.entries(gear.tweaks).flatMap(([key, tweaks]) => tweaks.map((tweak) => ({ ...tweak, key })));
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
  const [tweakedGears, setTweakedGears] = useLocalState(context, 'tweakedGears', '');
  return (
    <Window width={975} height={650}>
      {tweakedGears && <GearTweak tweakedGears={tweakedGears} setTweakedGears={setTweakedGears} />}
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <LoadoutCategories selectedCategory={selectedCategory} setSelectedCategory={setSelectedCategory} />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item basis="25%">
                <LoadoutEquipped tweakedGears={tweakedGears} setTweakedGears={setTweakedGears} />
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

const LoadoutCategories = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { selectedCategory, setSelectedCategory } = props;
  const categories = getCategories(data.gears);
  return (
    <Tabs fluid textAlign="center" style={{ 'flex-wrap': 'wrap-reverse' }}>
      {categories.map((category) => (
        <Tabs.Tab
          key={category}
          selected={category === selectedCategory}
          style={{
            'white-space': 'nowrap',
          }}
          onClick={() => setSelectedCategory(category)}
        >
          {category}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};

const LoadoutGears = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { selectedCategory, search, setSearch, searchText, setSearchText } = props;
  const filteredGears = filterGears(data.gears, searchText, selectedCategory);
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
                  <Box mt={gear.name.length > 12 && 1.5} textColor="red">
                    That gear is only available at a higher donation tier than you are on.
                  </Box>
                )}
              </Box>
            ) : (
              ''
            )
          }
          tooltipPosition={'bottom'}
          selected={Object.keys(data.selected_gears).includes(gear.key)}
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
              {getGearTweaks(gear).length > 0 &&
                getGearTweaks(gear).map((tweak) => (
                  <Button
                    key={tweak.name}
                    width="22px"
                    color="transparent"
                    icon={tweak.icon}
                    tooltip={tweak.tooltip}
                    tooltipPosition="top"
                  />
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
  const { tweakedGears, setTweakedGears } = props;

  const filteredGears = Object.entries(data.gears).flatMap(([key, gearList]) =>
    gearList.filter(() => Object.keys(data.selected_gears).includes(key)).map((gear) => ({ ...gear, key }))
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
                <>
                  {getGearTweaks(gear).length > 0 && (
                    <Button
                      translucent
                      icon="gears"
                      iconColor="gray"
                      width="33px"
                      onClick={() => setTweakedGears(gear)}
                    />
                  )}
                  <Button
                    translucent
                    icon="times"
                    iconColor="red"
                    width="32px"
                    onClick={() => act('toggle_gear', { gear: gear.key })}
                  />
                </>
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

const GearTweak = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { tweakedGears, setTweakedGears } = props;

  return (
    <Dimmer>
      <Box className={'Loadout-Modal__background'}>
        <Section
          fill
          scrollable
          width={20}
          height={20}
          title={tweakedGears.name}
          buttons={
            <Button
              color="red"
              icon="times"
              tooltip="Close"
              tooltipPosition="top"
              onClick={() => setTweakedGears('')}
            />
          }
        >
          <LabeledList>
            {getGearTweaks(tweakedGears).map((tweak) => {
              const tweakInfo = data.selected_gears[tweakedGears.key][tweak.key];

              return (
                <LabeledList.Item
                  key={tweak.name}
                  label={tweak.name}
                  buttons={
                    <Button
                      color="transparent"
                      icon={'pen'}
                      onClick={() => act('set_tweak', { gear: tweakedGears.key, tweak: tweak.key })}
                    />
                  }
                >
                  {tweakInfo ? tweakInfo : 'Default'}
                  <Box
                    inline
                    ml={1}
                    width={1}
                    height={1}
                    verticalAlign={'middle'}
                    style={{ 'background-color': `${tweakInfo}` }}
                  />
                </LabeledList.Item>
              );
            })}
          </LabeledList>
        </Section>
      </Box>
    </Dimmer>
  );
};

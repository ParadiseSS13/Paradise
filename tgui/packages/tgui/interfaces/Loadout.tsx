import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Dimmer,
  Dropdown,
  ImageButton,
  Button,
  Input,
  Section,
  Tabs,
  ProgressBar,
  Stack,
  LabeledList,
} from '../components';
import { Window } from '../layouts';

type Data = {
  user_tier: number;
  gear_slots: number;
  max_gear_slots: number;
  selected_gears: string[];
  gears: Record<string, Record<string, Gear>>;
};

type Gear = {
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
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

const sortTypes = {
  'Default': (a, b) => a.gear.gear_tier - b.gear.gear_tier,
  'Alphabetical': (a, b) => a.gear.name.toLowerCase().localeCompare(b.gear.name.toLowerCase()),
  'Cost': (a, b) => a.gear.cost - b.gear.cost,
};

export const Loadout = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [search, setSearch] = useLocalState(context, 'search', false);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [category, setCategory] = useLocalState(context, 'category', Object.keys(data.gears)[0]);
  const [tweakedGear, setTweakedGear] = useLocalState(context, 'tweakedGear', '');

  return (
    <Window width={975} height={650}>
      {tweakedGear && <GearTweak tweakedGear={tweakedGear} setTweakedGear={setTweakedGear} />}
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <LoadoutCategories category={category} setCategory={setCategory} />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item basis="25%">
                <LoadoutEquipped setTweakedGear={setTweakedGear} />
              </Stack.Item>
              <Stack.Item basis="75%">
                <LoadoutGears
                  category={category}
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
  const { category, setCategory } = props;
  return (
    <Tabs fluid textAlign="center" style={{ 'flex-wrap': 'wrap-reverse' }}>
      {Object.keys(data.gears).map((cat) => (
        <Tabs.Tab
          key={cat}
          selected={cat === category}
          style={{
            'white-space': 'nowrap',
          }}
          onClick={() => setCategory(cat)}
        >
          {cat}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};

const LoadoutGears = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { user_tier, gear_slots, max_gear_slots } = data;
  const { category, search, setSearch, searchText, setSearchText } = props;

  const [sortType, setSortType] = useLocalState(context, 'sortType', 'Default');
  const [sortReverse, setsortReverse] = useLocalState(context, 'sortReverse', false);
  const testSearch = createSearch<Gear>(searchText, (gear) => gear.name);

  let contents;
  if (searchText.length > 2) {
    contents = Object.entries(data.gears)
      .reduce((a, [key, gears]) => {
        return a.concat(Object.entries(gears).map(([key, gear]) => ({ key, gear })));
      }, [])
      .filter(({ gear }) => {
        return testSearch(gear);
      });
  } else {
    contents = Object.entries(data.gears[category]).map(([key, gear]) => ({ key, gear }));
  }

  contents.sort(sortTypes[sortType]);
  if (sortReverse) {
    contents = contents.reverse();
  }

  return (
    <Section
      fill
      scrollable
      title={category}
      buttons={
        <Stack>
          <Stack.Item>
            <Dropdown
              height={1.66}
              selected={sortType}
              options={Object.keys(sortTypes)}
              onSelected={(value) => setSortType(value)}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon={sortReverse ? 'arrow-down-wide-short' : 'arrow-down-short-wide'}
              tooltip={sortReverse ? 'Ascending order' : 'Descending order'}
              tooltipPosition="bottom-end"
              onClick={() => setsortReverse(!sortReverse)}
            />
          </Stack.Item>
          {search && (
            <Stack.Item>
              <Input
                width={20}
                placeholder="Search..."
                value={searchText}
                onInput={(e) => setSearchText(e.target.value)}
              />
            </Stack.Item>
          )}
          <Stack.Item>
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
          </Stack.Item>
        </Stack>
      }
    >
      {contents.map(({ key, gear }) => {
        const maxTextLength = 12;
        const selected = Object.keys(data.selected_gears).includes(key);
        const costText = gear.cost === 1 ? `${gear.cost} Point` : `${gear.cost} Points`;

        const tooltipText = (
          <Box>
            {gear.name.length > maxTextLength && <Box>{gear.name}</Box>}
            {gear.gear_tier > user_tier && (
              <Box mt={gear.name.length > maxTextLength && 1.5} textColor="red">
                That gear is only available at a higher donation tier than you are on.
              </Box>
            )}
          </Box>
        );

        const tooltipsInfo = (
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
            {Object.entries(gear.tweaks).map(([key, tweaks]: [string, Tweak[]]) =>
              tweaks.map((tweak) => (
                <Button
                  key={key}
                  width="22px"
                  color="transparent"
                  icon={tweak.icon}
                  tooltip={tweak.tooltip}
                  tooltipPosition="top"
                />
              ))
            )}
            <Button width="22px" color="transparent" icon="info" tooltip={gear.desc} tooltipPosition="top" />
          </>
        );

        const textInfo = (
          <Box class="Loadout-InfoBox">
            <Box style={{ 'flex-grow': 1 }} fontSize={1} color="gold" opacity={0.75}>
              {gear.gear_tier > 0 && `Tier ${gear.gear_tier}`}
            </Box>
            <Box fontSize={0.75} opacity={0.66}>
              {costText}
            </Box>
          </Box>
        );

        return (
          <ImageButton
            key={key}
            m={0.5}
            imageSize={84}
            dmIcon={gear.icon}
            dmIconState={gear.icon_state}
            tooltip={(gear.name.length > maxTextLength || gear.gear_tier > 0) && tooltipText}
            tooltipPosition={'bottom'}
            selected={selected}
            disabled={gear.gear_tier > user_tier || (gear_slots + gear.cost > max_gear_slots && !selected)}
            buttons={tooltipsInfo}
            buttonsAlt={textInfo}
            onClick={() => act('toggle_gear', { gear: key })}
          >
            {gear.name}
          </ImageButton>
        );
      })}
    </Section>
  );
};

const LoadoutEquipped = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { setTweakedGear } = props;
  const selectedGears = Object.entries(data.gears).reduce((a, [categoryKey, categoryItems]) => {
    const selectedInCategory = Object.entries(categoryItems)
      .filter(([gearKey]) => Object.keys(data.selected_gears).includes(gearKey))
      .map(([gearKey, gear]) => ({ key: gearKey, ...gear }));

    return a.concat(selectedInCategory);
  }, []);

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
          {selectedGears.map((gear) => (
            <ImageButton
              key={gear.key}
              fluid
              imageSize={32}
              dmIcon={gear.icon}
              dmIconState={gear.icon_state}
              buttons={
                <>
                  {Object.entries(gear.tweaks).length > 0 && (
                    <Button
                      translucent
                      icon="gears"
                      iconColor="gray"
                      width="33px"
                      onClick={() => setTweakedGear(gear)}
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
          <ProgressBar
            value={data.gear_slots}
            maxValue={data.max_gear_slots}
            ranges={{
              bad: [data.max_gear_slots, Infinity],
              average: [data.max_gear_slots * 0.66, data.max_gear_slots],
              good: [0, data.max_gear_slots * 0.66],
            }}
          >
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
  const { tweakedGear, setTweakedGear } = props;

  return (
    <Dimmer>
      <Box className={'Loadout-Modal__background'}>
        <Section
          fill
          scrollable
          width={20}
          height={20}
          title={tweakedGear.name}
          buttons={
            <Button color="red" icon="times" tooltip="Close" tooltipPosition="top" onClick={() => setTweakedGear('')} />
          }
        >
          <LabeledList>
            {Object.entries(tweakedGear.tweaks).map(([key, tweaks]: [string, Tweak[]]) =>
              tweaks.map((tweak) => {
                const tweakInfo = data.selected_gears[tweakedGear.key][key];
                return (
                  <LabeledList.Item
                    key={key}
                    label={tweak.name}
                    color={tweakInfo ? '' : 'gray'}
                    buttons={
                      <Button
                        color="transparent"
                        icon={'pen'}
                        onClick={() => act('set_tweak', { gear: tweakedGear.key, tweak: key })}
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
              })
            )}
          </LabeledList>
        </Section>
      </Box>
    </Dimmer>
  );
};

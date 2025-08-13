import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
  VirtualList,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Seed = {
  name: string;
  category: string;
  gender: string;
  provider: string;
  required_donator_level: number;
};

type Provider = {
  name: string;
  is_enabled: BooleanLike;
};

type TTSData = {
  donator_level: number;
  character_gender: string;
  selected_seed: string | null;
  phrases: string[];
  providers: Provider[];
  seeds: Seed[];
};

const donatorTiers = {
  0: 'Free',
  1: 'Tier I',
  2: 'Tier II',
  3: 'Tier III',
  4: 'Tier IV',
  5: 'Tier V',
};

const gender = {
  male: 'Мужской',
  female: 'Женский',
};

const gendersIcons = {
  'Мужской': {
    icon: 'mars',
    color: 'blue',
  },
  'Женский': {
    icon: 'venus',
    color: 'purple',
  },
  'Любой': {
    icon: 'venus-mars',
    color: 'white',
  },
};

const getCheckboxGroup = (itemsList, selectedList, setSelected, contentKey: string | null = null) => {
  return itemsList.map((item) => {
    const title = contentKey ? item[contentKey] : item;
    return (
      <Button.Checkbox
        key={title}
        checked={selectedList.includes(item)}
        onClick={() => {
          if (selectedList.includes(item)) {
            setSelected(selectedList.filter((i) => (contentKey ? i[contentKey] : i) !== item));
          } else {
            setSelected([item, ...selectedList]);
          }
        }}
      >
        {title}
      </Button.Checkbox>
    );
  });
};

export const TTSSeedsExplorer = () => {
  return (
    <Window width={1000} height={685}>
      <Window.Content>
        <Stack fill>
          <TTSSeedsExplorerContent />
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const TTSSeedsExplorerContent = () => {
  const { act, data } = useBackend<TTSData>();

  const { providers, seeds, selected_seed, phrases, donator_level, character_gender } = data;

  const categories = seeds
    .map((seed) => seed.category)
    .filter((category, i, a) => a.indexOf(category) === i)
    .sort((a, b) => a.localeCompare(b));
  const genders = seeds.map((seed) => seed.gender).filter((gender, i, a) => a.indexOf(gender) === i);
  const donatorLevels = seeds
    .map((seed) => seed.required_donator_level)
    .filter((level, i, a) => a.indexOf(level) === i)
    .sort((a, b) => a - b)
    .map((level) => donatorTiers[level]);

  const [selectedProviders, setSelectedProviders] = useState(providers);
  const [selectedGenders, setSelectedGenders] = useState(
    genders.includes(gender[character_gender]) ? [gender[character_gender]] : genders
  );
  const [selectedCategories, setSelectedCategories] = useState(categories);
  const [selectedDonatorLevels, setSelectedDonatorLevels] = useState(
    donatorLevels.includes(donatorTiers[donator_level])
      ? donatorLevels.slice(0, donatorLevels.indexOf(donatorTiers[donator_level]) + 1)
      : donatorLevels
  );
  const [selectedPhrase, setSelectedPhrase] = useState(phrases[0]);
  const [searchtext, setSearchtext] = useState('');
  const [searchToggle, setSearchToggle] = useState(false);

  let providerCheckboxes = getCheckboxGroup(providers, selectedProviders, setSelectedProviders, 'name');
  let genderesCheckboxes = getCheckboxGroup(genders, selectedGenders, setSelectedGenders);
  let categoriesCheckboxes = getCheckboxGroup(categories, selectedCategories, setSelectedCategories);
  let donatorLevelsCheckboxes = getCheckboxGroup(donatorLevels, selectedDonatorLevels, setSelectedDonatorLevels);

  let phrasesSelect = (
    <Dropdown
      options={phrases}
      selected={selectedPhrase.replace(/(.{60})..+/, '$1...')}
      width="21.3em"
      onSelected={(value) => setSelectedPhrase(value)}
    />
  );

  let searchBar = (
    <>
      {searchToggle && <Input placeholder="Название..." width={20} onChange={(value) => setSearchtext(value)} />}
      <Button
        icon="magnifying-glass"
        tooltip="Переключить поиск"
        tooltipPosition="bottom-end"
        selected={searchToggle}
        onClick={() => setSearchToggle(!searchToggle)}
      />
    </>
  );

  const availableSeeds = seeds
    .sort((a, b) => {
      const aname = a.name.toLowerCase();
      const bname = b.name.toLowerCase();
      if (aname > bname) {
        return 1;
      }
      if (aname < bname) {
        return -1;
      }
      return 0;
    })
    .filter(
      (seed) =>
        selectedProviders.some((provider) => provider.name === seed.provider) &&
        selectedGenders.includes(seed.gender) &&
        selectedCategories.includes(seed.category) &&
        selectedDonatorLevels.includes(donatorTiers[seed.required_donator_level]) &&
        seed.name.toLowerCase().includes(searchtext.toLowerCase())
    );

  let seedsRow = availableSeeds.map((seed) => {
    return (
      <Table.Row key={seed.name} backgroundColor={selected_seed === seed.name ? 'green' : 'transparent'}>
        <Table.Cell collapsing textAlign="center">
          <Button
            fluid
            color={selected_seed === seed.name ? 'green' : 'transparent'}
            content={selected_seed === seed.name ? 'Выбрано' : 'Выбрать'}
            tooltip={donator_level < seed.required_donator_level && 'Требуется более высокий уровень подписки'}
            onClick={() => act('select', { seed: seed.name })}
          />
        </Table.Cell>
        <Table.Cell collapsing textAlign="center">
          <Button
            fluid
            icon="music"
            color={selected_seed === seed.name ? 'green' : 'transparent'}
            content=""
            tooltip="Прослушать пример"
            onClick={() => act('listen', { seed: seed.name, phrase: selectedPhrase })}
          />
        </Table.Cell>
        <Table.Cell
          bold
          textColor={seed.required_donator_level > 0 && selected_seed !== seed.name ? 'orange' : 'white'}
        >
          {seed.name}
        </Table.Cell>
        <Table.Cell collapsing opacity={selected_seed === seed.name ? 0.5 : 0.25} textAlign="left">
          {seed.category}
        </Table.Cell>
        <Table.Cell
          collapsing
          opacity={0.5}
          textColor={selected_seed === seed.name ? 'white' : gendersIcons[seed.gender].color}
          textAlign="left"
        >
          <Icon mx={1} size={1.2} name={gendersIcons[seed.gender].icon} />
        </Table.Cell>
        <Table.Cell collapsing opacity={0.5} textColor="white" textAlign="right">
          {seed.required_donator_level > 0 && (
            <>
              {donatorTiers[seed.required_donator_level]}
              <Icon ml={1} mr={2} name="coins" />
            </>
          )}
        </Table.Cell>
      </Table.Row>
    );
  });

  return (
    <>
      <Stack.Item basis="30.25em">
        <Stack fill vertical>
          <Stack.Item>
            <Section fill title="Фильтры">
              <LabeledList>
                <LabeledList.Item label="Провайдеры">{providerCheckboxes}</LabeledList.Item>
                <LabeledList.Item label="Пол">{genderesCheckboxes}</LabeledList.Item>
                <LabeledList.Item label="Тир">{donatorLevelsCheckboxes}</LabeledList.Item>
                <LabeledList.Item label="Фраза">{phrasesSelect}</LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Категории"
              buttons={
                <>
                  <Button
                    icon="times"
                    disabled={selectedCategories.length === 0}
                    onClick={() => setSelectedCategories([])}
                  >
                    Убрать всё
                  </Button>
                  <Button
                    icon="check"
                    disabled={selectedCategories.length === categories.length}
                    onClick={() => setSelectedCategories(categories)}
                  >
                    Выбрать всё
                  </Button>
                </>
              }
            >
              {categoriesCheckboxes}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <BlockQuote>
                <Box fontSize="11px">
                  {`Для поддержания и развития сообщества в условиях растущих расходов часть голосов пришлось сделать доступными только за материальную поддержку сообщества.`}
                </Box>
                <Box mt={1.5} italic color="gray" fontSize="10px">
                  {`Подробнее об этом можно узнать в нашем Discord-сообществе.`}
                </Box>
              </BlockQuote>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={`Голоса (${availableSeeds.length}/${seeds.length})`} buttons={searchBar}>
          <Table>
            <VirtualList>{seedsRow}</VirtualList>
          </Table>
        </Section>
      </Stack.Item>
    </>
  );
};

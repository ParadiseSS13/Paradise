import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Table, Section, Dropdown, Input } from '../components';
import { Window } from '../layouts';

export const TTSSeedsExplorer = (props, context) => {
  return (
    <Window resizable>
      <Window.Content className="Layout__content--flexColumn">
        <TTSSeedsExplorerContent />
      </Window.Content>
    </Window>
  );
};

export const TTSSeedsExplorerContent = (props, context) => {
  const { act, data } = useBackend(context);

  const { providers, seeds, selected_seed, phrases } = data;

  const categories = seeds.map(seed => seed.category).filter((category, i, a) => a.indexOf(category) === i);
  const genders = seeds.map(seed => seed.gender).filter((gender, i, a) => a.indexOf(gender) === i);

  const [selectedProviders, setSelectedProviders] = useLocalState(context, 'selectedProviders', providers);
  const [selectedGenders, setSelectedGenders] = useLocalState(context, 'selectedGenders', genders);
  const [selectedCategories, setSelectedCategories] = useLocalState(context, 'selectedCategories', categories);
  const [selectedPhrase, setSelectedPhrase] = useLocalState(context, 'selectedPhrase', phrases[0]);
  const [searchtext, setSearchtext] = useLocalState(context, 'searchtext', "");

  let providerCheckboxes = providers.map(provider => {
    return (
      <Button.Checkbox
        key={provider.name}
        checked={selectedProviders.includes(provider)}
        content={provider.name}
        onClick={() => {
          if (selectedProviders.includes(provider)) {
            setSelectedProviders(selectedProviders.filter(p => p.name !== provider.name));
          } else {
            setSelectedProviders([provider, ...selectedProviders]);
          }
        }} />
    );
  });

  let genderesCheckboxes = genders.map(gender => {
    return (
      <Button.Checkbox
        key={gender}
        checked={selectedGenders.includes(gender)}
        content={gender}
        onClick={() => {
          if (selectedGenders.includes(gender)) {
            setSelectedGenders(selectedGenders.filter(g => g !== gender));
          } else {
            setSelectedGenders([gender, ...selectedGenders]);
          }
        }} />
    );
  });

  let categoriesCheckboxes = categories.map(category => {
    return (
      <Button.Checkbox
        key={category}
        checked={selectedCategories.includes(category)}
        content={category}
        onClick={() => {
          if (selectedCategories.includes(category)) {
            setSelectedCategories(selectedCategories.filter(c => c !== category));
          } else {
            setSelectedCategories([category, ...selectedCategories]);
          }
        }} />
    );
  });

  let phrasesSelect = (
    <Dropdown
      options={phrases}
      selected={selectedPhrase.replace(/(.{25})..+/, "$1...")}
      width="220px"
      onSelected={value => setSelectedPhrase(value)} />
  );

  let searchBar = (
    <Input
      placeholder="Название..."
      fluid
      onInput={(e, value) => setSearchtext(value)} />
  );

  const availableSeeds = seeds.sort((a, b) => {
    const aname = a.name.toLowerCase();
    const bname = b.name.toLowerCase();
    if (aname > bname) {
      return 1;
    }
    if (aname < bname) {
      return -1;
    }
    return 0;
  }).filter(seed =>
    selectedProviders.some(provider => provider.name === seed.provider)
    && selectedGenders.includes(seed.gender)
    && selectedCategories.includes(seed.category)
    && seed.name.toLowerCase().includes(searchtext.toLowerCase())
  );

  let seedsRow = availableSeeds.map(seed => {
    return (
      <Table.Row key={seed.name} backgroundColor={selected_seed === seed.name ? "green" : "transparent"}>
        <Table.Cell collapsing textAlign="center">
          <Button
            fluid
            // disabled={selected_seed === seed.name}
            color={selected_seed === seed.name ? "green" : "transparent"}
            content={selected_seed === seed.name ? "Выбрано" : "Выбрать"}
            textAlign="left"
            onClick={() => act('select', { seed: seed.name })} />
        </Table.Cell>
        <Table.Cell collapsing textAlign="center">
          <Button
            fluid
            icon="music"
            content=""
            tooltip="Прослушать пример"
            color="transparent"
            onClick={() => act('listen', { seed: seed.name, phrase: selectedPhrase })} />
        </Table.Cell>
        <Table.Cell bold>
          {seed.name}
        </Table.Cell>
      </Table.Row>
    );
  });

  return (
    <Fragment>
      <Section title="Фильтры">
        <LabeledList>
          <LabeledList.Item label="Провайдеры">
            {providerCheckboxes}
          </LabeledList.Item>
          <LabeledList.Item label="Пол">
            {genderesCheckboxes}
          </LabeledList.Item>
          <LabeledList.Item label="Категории">
            {categoriesCheckboxes}
          </LabeledList.Item>
          <LabeledList.Item label="Фраза">
            {phrasesSelect}
          </LabeledList.Item>
          <LabeledList.Item label="Поиск">
            {searchBar}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title={`Голоса (${availableSeeds.length}/${seeds.length})`} flexGrow="1">
        <Table>
          {seedsRow}
        </Table>
      </Section>
    </Fragment>
  );
};

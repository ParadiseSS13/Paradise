import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Section, Input, Flex, Collapsible } from '../components';

export const ModpacksList = (props, context) => {
  return (
    <Window resizable>
      <Window.Content scrollable>
        <ModpacksListContent />
      </Window.Content>
    </Window>
  );
};

export const ModpacksListContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { modpacks } = data;

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const searchBar = (
    <Input
      placeholder="Искать модпак по имени, описанию или автору..."
      fluid
      onInput={(e, value) => setSearchText(value)}
    />
  );

  return (
    <Section>
      <Section title="Фильтры">{searchBar}</Section>
      <Section
        title={
          searchText.length > 0
            ? `Результаты поиска "${searchText}"`
            : `Все модификации`
        }
        fill
      >
        <Flex>
          <Flex.Item grow="1" basis="100%" width="100%" display="inline-block">
            {modpacks
              .filter(
                (modpack) =>
                  modpack.name &&
                  (searchText.length > 0
                    ? modpack.name
                        .toLowerCase()
                        .includes(searchText.toLowerCase()) ||
                      modpack.desc
                        .toLowerCase()
                        .includes(searchText.toLowerCase()) ||
                      modpack.author
                        .toLowerCase()
                        .includes(searchText.toLowerCase())
                    : true)
              )
              .map((modpack) => (
                <Collapsible key={modpack.name} title={modpack.name}>
                  <Section title="Авторы">{modpack.author}</Section>
                  <Section title="Описание">{modpack.desc}</Section>
                </Collapsible>
              ))}
          </Flex.Item>
        </Flex>
      </Section>
    </Section>
  );
};

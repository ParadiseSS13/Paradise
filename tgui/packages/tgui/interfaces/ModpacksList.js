import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Section, Input, Stack, Collapsible } from '../components';

export const ModpacksList = (props, context) => {
  return (
    <Window width={500} height={550}>
      <Window.Content>
        <Stack fill vertical>
          <ModpacksListContent />
        </Stack>
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
    <>
      <Stack.Item>
        <Section fill title="Фильтры">
          {searchBar}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={searchText.length > 0 ? `Результаты поиска "${searchText}"` : `Все модификации - ${modpacks.length}`}
        >
          <Stack fill vertical>
            <Stack.Item>
              {modpacks
                .filter(
                  (modpack) =>
                    modpack.name &&
                    (searchText.length > 0
                      ? modpack.name.toLowerCase().includes(searchText.toLowerCase()) ||
                        modpack.desc.toLowerCase().includes(searchText.toLowerCase()) ||
                        modpack.author.toLowerCase().includes(searchText.toLowerCase())
                      : true)
                )
                .map((modpack) => (
                  <Collapsible key={modpack.name} title={modpack.name}>
                    <Section title="Авторы">{modpack.author}</Section>
                    <Section title="Описание">{modpack.desc}</Section>
                  </Collapsible>
                ))}
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </>
  );
};

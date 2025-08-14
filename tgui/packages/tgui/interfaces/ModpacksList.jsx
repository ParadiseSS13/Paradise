import { useState } from 'react';
import { Collapsible, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ModpacksList = (props) => {
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

export const ModpacksListContent = (props) => {
  const { act, data } = useBackend();
  const { modpacks } = data;

  const [searchText, setSearchText] = useState('');

  const searchBar = (
    <Input
      placeholder="Искать модпак по имени, описанию или автору..."
      fluid
      onChange={(value) => setSearchText(value)}
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

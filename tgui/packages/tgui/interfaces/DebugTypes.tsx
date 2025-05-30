import { useBackend, useLocalState } from '../backend';
import { Box, Input, Stack, Button, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

// EditVV | JumpTo | Typepath | UID
type Data = {
  can_edit: boolean;
  can_jump: boolean;
  path: string;
  uid: string;
  loc: string;
};

type InputList = {
  target_path: string;
  items: Data[];
};

export const DebugTypes = (props, context) => {
  const { act, data } = useBackend<InputList>(context);
  const { target_path, items = [] } = data;
  const [searchQuery, setSearchQuery] = useLocalState<string>(context, 'searchQuery', '');
  // User types into search bar
  const onSearch = (query: string) => {
    if (query === searchQuery) {
      return;
    }
    setSearchQuery(query);
  };

  const filteredItems =
    searchQuery === ''
      ? items
      : items.filter((item) => {
          const regex = new RegExp(searchQuery, 'i');
          return regex.test(item.path);
        });

  return (
    <Window width={800} height={1000}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Box fontSize="1rem">Matches: {filteredItems.length}</Box>
          </Stack.Item>
          <Stack.Item>
            <Box fontSize="1rem">Query: {target_path}</Box>
          </Stack.Item>
          <Stack.Item>
            <SearchBar filteredItems={filteredItems} onSearch={onSearch} searchQuery={searchQuery} />
          </Stack.Item>
          <ListDisplay filteredItems={filteredItems} />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ListDisplay = (props, context) => {
  const { act } = useBackend<InputList>(context);
  const { filteredItems } = props;
  return (
    <Section fill scrollable>
      <Table className="DebugTypes__List">
        {filteredItems.map((item: Data, idx) => (
          <Table.Row key={idx}>
            <Table.Cell>
              <Button
                content="E"
                color={item.can_edit ? 'blue' : 'grey'}
                onClick={() => {
                  act('edit', {
                    edit: item.uid,
                  });
                }}
              >
                E
              </Button>
            </Table.Cell>
            <Table.Cell>
              <Button
                icon="square-arrow-up-right"
                color={item.can_jump ? 'blue' : 'grey'}
                onClick={() => {
                  act('jump', {
                    jump: item.uid,
                  });
                }}
              />
            </Table.Cell>
            <Table.Cell>{item.path}</Table.Cell>
            <Table.Cell>{item.uid}</Table.Cell>
            <Table.Cell>{item.loc}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const SearchBar = (props, context) => {
  const { act } = useBackend<InputList>(context);
  const { filteredItems, onSearch, searchQuery } = props;

  return (
    <Input
      width="100%"
      autoFocus
      autoSelect
      onInput={(_, value) => onSearch(value)}
      placeholder="Filter..."
      value={searchQuery}
    />
  );
};

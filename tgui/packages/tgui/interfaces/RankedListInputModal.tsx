import { useState } from 'react';
import { Button, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type ListInputData = {
  items: string[];
  message: string;
  timeout: number;
  title: string;
};

export const RankedListInputModal = (props) => {
  const { act, data } = useBackend<ListInputData>();
  const { items = [], message = '', timeout, title } = data;
  const [edittedItems, setEdittedItems] = useState<string[]>(items);

  // Dynamically changes the window height based on the message.
  const windowHeight = 330 + Math.ceil(message.length / 3);

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Section className="ListInput__Section" fill title={message}>
          <Stack fill vertical>
            <Stack.Item grow>
              <ListDisplay filteredItems={edittedItems} setEdittedItems={setEdittedItems} />
            </Stack.Item>
            <Stack.Item mt={0.5}>
              <InputButtons input={edittedItems} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/**
 * Displays the list of selectable items.
 * If a search query is provided, filters the items.
 */
const ListDisplay = (props) => {
  const { filteredItems } = props;

  return (
    <Section fill scrollable>
      <Table>
        {filteredItems.map((item, index) => (
          <Table.Row
            key={index}
            style={{
              padding: '8px',
            }}
          >
            <Button
              fluid
              py="0.25rem"
              color="transparent"
              style={{
                animation: 'none',
                transition: 'none',
                cursor: 'move',
              }}
              icon="grip-lines"
            >
              {item.replace(/^\w/, (c) => c.toUpperCase())}
            </Button>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

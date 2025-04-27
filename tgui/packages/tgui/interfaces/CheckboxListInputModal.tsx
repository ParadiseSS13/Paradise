import { useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type ListInputData = {
  init_value: string;
  items: CheckboxData[];
  message: string;
  timeout: number;
  title: string;
};

interface CheckboxData {
  key: string;
  checked: BooleanLike;
}
export const CheckboxListInputModal = (props) => {
  const { act, data } = useBackend<ListInputData>();
  const { items = [], message = '', init_value, timeout, title } = data;
  const [edittedItems, setEdittedItems] = useState<CheckboxData[]>(items);

  const windowHeight = 330 + Math.ceil(message.length / 3);

  const onClick = (new_item: CheckboxData) => {
    let updatedItems = [...edittedItems];
    updatedItems = updatedItems.map((item) =>
      item.key === new_item.key ? { ...item, checked: !new_item.checked } : item
    );
    setEdittedItems(updatedItems);
  };

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Section className="ListInput__Section" fill title={message}>
          <Stack fill vertical>
            <Stack.Item grow>
              <ListDisplay filteredItems={edittedItems} onClick={onClick} />
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
  const { filteredItems, onClick } = props;

  return (
    <Section fill scrollable>
      {filteredItems.map((item, index) => {
        return (
          <Button.Checkbox
            fluid
            id={index}
            key={index}
            onClick={() => onClick(item)}
            checked={item.checked}
            style={{
              animation: 'none',
              transition: 'none',
            }}
          >
            {item.key.replace(/^\w/, (c) => c.toUpperCase())}
          </Button.Checkbox>
        );
      })}
    </Section>
  );
};

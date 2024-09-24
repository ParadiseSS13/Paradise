import { Loader } from './common/Loader';
import { InputButtons } from './common/InputButtons';
import { Button, Input, Section, Stack } from '../components';
import { useBackend, useLocalState } from '../backend';
import { KEY_A, KEY_DOWN, KEY_ESCAPE, KEY_ENTER, KEY_UP, KEY_Z, KEY_TAB } from 'common/keycodes';
import { Window } from '../layouts';

type ListInputData = {
  init_value: string;
  items: string[];
  message: string;
  timeout: number;
  title: string;
};

export const RankedListInputModal = (props, context) => {
  const { act, data } = useBackend<ListInputData>(context);
  const { items = [], message = '', init_value, timeout, title } = data;
  const [selected, setSelected] = useLocalState<number>(context, 'selected', items.indexOf(init_value));
  const [edittedItems, setEdittedItems] = useLocalState<string[]>(context, 'edittedItems', items);
  // User presses up or down on keyboard
  // Simulates clicking an item
  const onArrowKey = (key: number) => {
    const len = edittedItems.length - 1;
    if (key === KEY_DOWN) {
      if (selected === null || selected === len) {
        setSelected(0);
        document!.getElementById('0')?.scrollIntoView();
      } else {
        setSelected(selected + 1);
        document!.getElementById((selected + 1).toString())?.scrollIntoView();
      }
    } else if (key === KEY_UP) {
      if (selected === null || selected === 0) {
        setSelected(len);
        document!.getElementById(len.toString())?.scrollIntoView();
      } else {
        setSelected(selected - 1);
        document!.getElementById((selected - 1).toString())?.scrollIntoView();
      }
    }
  };
  // User selects an item with mouse
  const onClick = (index: number) => {
    if (index === selected) {
      return;
    }
    setSelected(index);
  };
  // User presses a letter key with no searchbar visible
  const onLetterSearch = (key: number) => {
    const keyChar = String.fromCharCode(key);
    const foundItem = items.find((item) => {
      return item?.toLowerCase().startsWith(keyChar?.toLowerCase());
    });
    if (foundItem) {
      const foundIndex = items.indexOf(foundItem);
      setSelected(foundIndex);
      document!.getElementById(foundIndex.toString())?.scrollIntoView();
    }
  };

  // Dynamically changes the window height based on the message.
  const windowHeight = 330 + Math.ceil(message.length / 3);
  // Grabs the cursor
  setTimeout(() => document!.getElementById(selected.toString())?.focus(), 1);

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_DOWN || keyCode === KEY_UP) {
            event.preventDefault();
            onArrowKey(keyCode);
          }
          if (keyCode === KEY_TAB) {
            event.preventDefault();
            onArrowKey(keyCode);
          }
          if (keyCode === KEY_ENTER) {
            event.preventDefault();
            act('submit', { entry: edittedItems });
          }
          if (keyCode >= KEY_A && keyCode <= KEY_Z) {
            event.preventDefault();
            onLetterSearch(keyCode);
          }
          if (keyCode === KEY_ESCAPE) {
            event.preventDefault();
            act('cancel');
          }
        }}
      >
        <Section>
          <Stack fill vertical>
            <Stack.Item grow>
              <ListDisplay
                filteredItems={edittedItems}
                onClick={onClick}
              />
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
const ListDisplay = (props, context) => {
  const { act } = useBackend<ListInputData>(context);
  const { filteredItems, onClick, onFocusSearch, searchBarVisible, selected } = props;

  return (
    <Section fill scrollable tabIndex={0}>
      {filteredItems.map((item, index) => {
        return (
          <Button
            fluid
            color="transparent"
            id={index}
            key={index}
            onClick={() => onClick(index)}
            onDblClick={(event) => {
              event.preventDefault();
              act('submit', { entry: filteredItems[selected] });
            }}
            onKeyDown={(event) => {
              const keyCode = window.event ? event.which : event.keyCode;
              if (searchBarVisible && keyCode >= KEY_A && keyCode <= KEY_Z) {
                event.preventDefault();
                onFocusSearch();
              }
            }}
            selected={index === selected}
            style={{
              'animation': 'none',
              'transition': 'none',
            }}
          >
            {item.replace(/^\w/, (c) => c.toUpperCase())}
          </Button>
        );
      })}
    </Section>
  );
};

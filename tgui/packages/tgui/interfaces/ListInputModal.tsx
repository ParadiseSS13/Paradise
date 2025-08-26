import { useState } from 'react';
import { Button, Input, Section, Stack } from 'tgui-core/components';
import { KEY_A, KEY_DOWN, KEY_ENTER, KEY_ESCAPE, KEY_UP, KEY_Z } from 'tgui-core/keycodes';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type ListInputData = {
  init_value: string;
  items: string[];
  message: string;
  timeout: number;
  title: string;
};

export const ListInputModal = (props) => {
  const { act, data } = useBackend<ListInputData>();
  const { items = [], message = '', init_value, timeout, title } = data;
  const [selected, setSelected] = useState<number>(items.indexOf(init_value));
  const [searchBarVisible, setSearchBarVisible] = useState<boolean>(items.length > 10);
  const [searchQuery, setSearchQuery] = useState<string>('');
  // User presses up or down on keyboard
  // Simulates clicking an item
  const onArrowKey = (key: number) => {
    const len = filteredItems.length - 1;
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
  // User presses a letter key and searchbar is visible
  const onFocusSearch = () => {
    setSearchBarVisible(false);
    setSearchBarVisible(true);
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
  // User types into search bar
  const onSearch = (query: string) => {
    if (query === searchQuery) {
      return;
    }
    setSearchQuery(query);
    setSelected(0);
    document!.getElementById('0')?.scrollIntoView();
  };
  // User presses the search button
  const onSearchBarToggle = () => {
    setSearchBarVisible(!searchBarVisible);
    setSearchQuery('');
  };
  const filteredItems = items.filter((item) => item?.toLowerCase().includes(searchQuery.toLowerCase()));
  // Dynamically changes the window height based on the message.
  const windowHeight = 350 + Math.ceil(message.length / 3);
  // Grabs the cursor when no search bar is visible.
  if (!searchBarVisible) {
    setTimeout(() => document!.getElementById(selected.toString())?.focus(), 1);
  }

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
          if (keyCode === KEY_ENTER) {
            event.preventDefault();
            act('submit', { entry: filteredItems[selected] });
          }
          if (!searchBarVisible && keyCode >= KEY_A && keyCode <= KEY_Z) {
            event.preventDefault();
            onLetterSearch(keyCode);
          }
          if (keyCode === KEY_ESCAPE) {
            event.preventDefault();
            act('cancel');
          }
        }}
      >
        <Section
          buttons={
            <Button
              compact
              icon={searchBarVisible ? 'search' : 'font'}
              selected
              tooltip={
                searchBarVisible
                  ? 'Search Mode. Type to search or use arrow keys to select manually.'
                  : 'Hotkey Mode. Type a letter to jump to the first match. Enter to select.'
              }
              tooltipPosition="left"
              onClick={() => onSearchBarToggle()}
            />
          }
          className="ListInput__Section"
          fill
          title={message}
        >
          <Stack fill vertical>
            <Stack.Item grow>
              <ListDisplay
                filteredItems={filteredItems}
                onClick={onClick}
                onFocusSearch={onFocusSearch}
                searchBarVisible={searchBarVisible}
                selected={selected}
              />
            </Stack.Item>
            <Stack.Item m={0}>
              {searchBarVisible && (
                <SearchBar
                  filteredItems={filteredItems}
                  onSearch={onSearch}
                  searchQuery={searchQuery}
                  selected={selected}
                />
              )}
            </Stack.Item>
            <Stack.Item mt={0.5}>
              <InputButtons input={filteredItems[selected]} />
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
  const { act } = useBackend<ListInputData>();
  const { filteredItems, onClick, onFocusSearch, searchBarVisible, selected } = props;

  return (
    <Section fill scrollable>
      {filteredItems.map((item, index) => {
        return (
          <Button
            fluid
            color="transparent"
            id={index}
            key={index}
            onClick={() => onClick(index)}
            onMouseDown={(event) => {
              if (event.detail === 2) {
                event.preventDefault();
                act('submit', { entry: filteredItems[selected] });
              }
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
              animation: 'none',
              transition: 'none',
            }}
          >
            {item.replace(/^\w/, (c) => c.toUpperCase())}
          </Button>
        );
      })}
    </Section>
  );
};

/**
 * Renders a search bar input.
 * Closing the bar defaults input to an empty string.
 */
const SearchBar = (props) => {
  const { act } = useBackend<ListInputData>();
  const { filteredItems, onSearch, searchQuery, selected } = props;

  return (
    <Input
      width="100%"
      autoFocus
      autoSelect
      placeholder="Search..."
      value={searchQuery}
      onChange={(value) => onSearch(value)}
      onEnter={() => {
        act('submit', { entry: filteredItems[selected] });
      }}
    />
  );
};

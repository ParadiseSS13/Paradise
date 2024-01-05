/**
 * @file
 * @copyright 2020 watermelon914 (https://github.com/watermelon914)
 * @license MIT
 */

import { clamp01 } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Stack, Section, Input } from '../components';
import { Window } from '../layouts';
import { KEY_UP, KEY_DOWN } from 'common/keycodes';

let lastScrollTime = 0;

export const ListInput = (props, context) => {
  const { act, data } = useBackend(context);
  const { title, message, buttons, timeout } = data;

  // Search
  const [showSearchBar, setShowSearchBar] = useLocalState(
    context,
    'search_bar',
    true
  );
  const [displayedArray, setDisplayedArray] = useLocalState(
    context,
    'displayed_array',
    buttons
  );

  // KeyPress
  const [searchArray, setSearchArray] = useLocalState(
    context,
    'search_array',
    []
  );
  const [searchIndex, setSearchIndex] = useLocalState(
    context,
    'search_index',
    0
  );
  const [lastCharCode, setLastCharCode] = useLocalState(
    context,
    'last_char_code',
    null
  );

  // Selected Button
  const [selectedButton, setSelectedButton] = useLocalState(
    context,
    'selected_button',
    buttons[0]
  );
  return (
    <Window title={title} width={325} height={350}>
      {timeout !== undefined && <Loader value={timeout} />}
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              className="ListInput__Section"
              title={message}
              tabIndex={1}
              onKeyDown={(e) => {
                e.preventDefault();
                if (lastScrollTime > performance.now()) {
                  return;
                }
                lastScrollTime = performance.now() + 125;

                if (e.keyCode === KEY_UP || e.keyCode === KEY_DOWN) {
                  let direction = 1;
                  if (e.keyCode === KEY_UP) {
                    direction = -1;
                  }

                  let index = 0;
                  for (index; index < buttons.length; index++) {
                    if (buttons[index] === selectedButton) {
                      break;
                    }
                  }
                  index += direction;
                  if (index < 0) {
                    index = buttons.length - 1;
                  } else if (index >= buttons.length) {
                    index = 0;
                  }
                  setSelectedButton(buttons[index]);
                  setLastCharCode(null);
                  document.getElementById(buttons[index]).focus();
                  return;
                }

                const charCode = String.fromCharCode(e.keyCode).toLowerCase();
                if (!charCode) {
                  return;
                }

                let foundValue;
                if (charCode === lastCharCode && searchArray.length > 0) {
                  const nextIndex = searchIndex + 1;

                  if (nextIndex < searchArray.length) {
                    foundValue = searchArray[nextIndex];
                    setSearchIndex(nextIndex);
                  } else {
                    foundValue = searchArray[0];
                    setSearchIndex(0);
                  }
                } else {
                  const resultArray = displayedArray.filter(
                    (value) => value.substring(0, 1).toLowerCase() === charCode
                  );

                  if (resultArray.length > 0) {
                    setSearchArray(resultArray);
                    setSearchIndex(0);
                    foundValue = resultArray[0];
                  }
                }

                if (foundValue) {
                  setLastCharCode(charCode);
                  setSelectedButton(foundValue);
                  document.getElementById(foundValue).focus();
                }
              }}
              buttons={
                <Button
                  compact
                  icon="search"
                  color="transparent"
                  selected={showSearchBar}
                  tooltip="Search..."
                  tooltipPosition="left"
                  onClick={() => {
                    setShowSearchBar(!showSearchBar);
                    setDisplayedArray(buttons);
                  }}
                />
              }
            >
              {displayedArray.map((button) => (
                <Button
                  color="transparent"
                  content={button}
                  id={button}
                  key={button}
                  fluid
                  selected={selectedButton === button}
                  onClick={() => {
                    if (selectedButton === button) {
                      act('choose', { choice: button });
                    } else {
                      setSelectedButton(button);
                    }
                    setLastCharCode(null);
                  }}
                />
              ))}
            </Section>
          </Stack.Item>
          {showSearchBar && (
            <Stack.Item>
              <Input
                width="100%"
                autoFocus
                onInput={(e, value) =>
                  setDisplayedArray(
                    buttons.filter(
                      (val) =>
                        val.toLowerCase().search(value.toLowerCase()) !== -1
                    )
                  )
                }
              />
            </Stack.Item>
          )}
          <Stack.Item>
            <Stack textAlign="center">
              <Stack.Item grow basis={0}>
                <Button
                  fluid
                  color="good"
                  content="Confirm"
                  disabled={selectedButton === null}
                  onClick={() => act('choose', { choice: selectedButton })}
                />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Button
                  fluid
                  color="bad"
                  content="Cancel"
                  onClick={() => act('cancel')}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Loader = (props) => {
  const { value } = props;
  return (
    <div className="ListInput__Loader">
      <Box
        className="ListInput__LoaderProgress"
        style={{
          width: clamp01(value) * 100 + '%',
        }}
      />
    </div>
  );
};

import { isEscape, KEY } from 'common/keys';

import { useBackend, useLocalState } from '../backend';
import { Autofocus, Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type KeyInputData = {
  init_value: string;
  large_buttons: boolean;
  message: string;
  timeout: number;
  title: string;
};

const isStandardKey = (event): boolean => {
  return event.key !== KEY.Alt && event.key !== KEY.Control && event.key !== KEY.Shift && event.key !== KEY.Escape;
};

const KEY_CODE_TO_BYOND: Record<string, string> = {
  DEL: 'Delete',
  DOWN: 'South',
  END: 'Southwest',
  HOME: 'Northwest',
  INSERT: 'Insert',
  LEFT: 'West',
  PAGEDOWN: 'Southeast',
  PAGEUP: 'Northeast',
  RIGHT: 'East',
  SPACEBAR: 'Space',
  UP: 'North',
};

const DOM_KEY_LOCATION_NUMPAD = 3;

const formatKeyboardEvent = (event): string => {
  let text = '';

  if (event.altKey) {
    text += 'Alt';
  }

  if (event.ctrlKey) {
    text += 'Ctrl';
  }

  if (event.shiftKey && !(event.keyCode >= 48 && event.keyCode <= 57)) {
    text += 'Shift';
  }

  if (event.location === DOM_KEY_LOCATION_NUMPAD) {
    text += 'Numpad';
  }

  if (isStandardKey(event)) {
    if (event.shiftKey && event.keyCode >= 48 && event.keyCode <= 57) {
      const number = event.keyCode - 48;
      text += 'Shift' + number;
    } else {
      const key = event.key.toUpperCase();
      text += KEY_CODE_TO_BYOND[key] || key;
    }
  }

  return text;
};

export const KeyComboModal = (props, context) => {
  const { act, data } = useBackend<KeyInputData>(context);
  const { init_value, large_buttons, message = '', title, timeout } = data;
  const [input, setInput] = useLocalState(context, 'input', init_value);
  const [binding, setBinding] = useLocalState(context, 'binding', true);

  const handleKeyPress = (event) => {
    if (!binding) {
      if (event.key === KEY.Enter) {
        act('submit', { entry: input });
      }
      if (isEscape(event.key)) {
        act('cancel');
      }
      return;
    }

    event.preventDefault();
    if (isStandardKey(event)) {
      setValue(formatKeyboardEvent(event));
      setBinding(false);
      return;
    } else if (event.key === KEY.Escape) {
      setValue(init_value);
      setBinding(false);
      return;
    }
  };

  const setValue = (value: string) => {
    if (value === input) {
      return;
    }
    setInput(value);
  };

  // Dynamically changes the window height based on the message.
  const windowHeight =
    130 + (message.length > 30 ? Math.ceil(message.length / 3) : 0) + (message.length && large_buttons ? 5 : 0);

  return (
    <Window title={title} width={240} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          handleKeyPress(event);
        }}
      >
        <Section fill>
          <Autofocus />
          <Stack fill vertical>
            <Stack.Item grow>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                disabled={binding}
                content={binding && binding !== null ? 'Awaiting input...' : '' + input}
                width="100%"
                textAlign="center"
                onClick={() => {
                  setValue(init_value);
                  setBinding(true);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <InputButtons input={input} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

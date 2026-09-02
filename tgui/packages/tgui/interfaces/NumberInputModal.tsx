import { useState } from 'react';
import { Box, Button, RestrictedInput, Section, Stack } from 'tgui-core/components';
import { KEY_ENTER, KEY_ESCAPE } from 'tgui-core/keycodes';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type NumberInputData = {
  init_value: number;
  large_buttons: boolean;
  max_value: number;
  message: string;
  min_value: number;
  timeout: number;
  title: string;
  round_value: boolean;
};

export const NumberInputModal = (props) => {
  const { act, data } = useBackend<NumberInputData>();
  const { init_value, large_buttons, message = '', timeout, title } = data;
  const [input, setInput] = useState(init_value);
  const onChange = (value: number) => {
    if (value === input) {
      return;
    }
    setInput(value);
  };
  const onClick = (value: number) => {
    if (value === input) {
      return;
    }
    setInput(value);
  };
  // Dynamically changes the window height based on the message.
  const windowHeight = 140 + Math.max(Math.ceil(message.length / 3), message.length > 0 && large_buttons ? 5 : 0);

  return (
    <Window title={title} width={270} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ENTER) {
            act('submit', { entry: input });
          }
          if (keyCode === KEY_ESCAPE) {
            act('cancel');
          }
        }}
      >
        <Section fill>
          <Stack fill vertical>
            <Stack.Item grow>
              <Box color="label">{message}</Box>
            </Stack.Item>
            <Stack.Item>
              <InputArea input={input} onClick={onClick} onChange={onChange} />
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

/** Gets the user input and invalidates if there's a constraint. */
const InputArea = (props) => {
  const { act, data } = useBackend<NumberInputData>();
  const { min_value, max_value, init_value, round_value } = data;
  const { input, onClick, onChange } = props;
  const split_value = Math.round(input !== min_value ? Math.max(input / 2, min_value) : max_value / 2);
  const split_disabled = (input === min_value && min_value > 0) || input === 1;
  return (
    <Stack fill>
      <Stack.Item>
        <Button
          disabled={input === min_value}
          icon="angle-double-left"
          onClick={() => onClick(min_value)}
          tooltip={input === min_value ? 'Min' : `Min (${min_value})`}
        />
      </Stack.Item>
      <Stack.Item grow>
        <RestrictedInput
          autoFocus
          autoSelect
          fluid
          allowFloats={!round_value}
          minValue={min_value}
          maxValue={max_value}
          value={input}
          onChange={onChange}
          onEnter={(value) => act('submit', { entry: value })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={input === max_value}
          icon="angle-double-right"
          onClick={() => onClick(max_value)}
          tooltip={input === max_value ? 'Max' : `Max (${max_value})`}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={split_disabled}
          icon="divide"
          onClick={() => onClick(split_value)}
          tooltip={split_disabled ? 'Split' : `Split (${split_value})`}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={input === init_value}
          icon="redo"
          onClick={() => onClick(init_value)}
          tooltip={init_value ? `Reset (${init_value})` : 'Reset'}
        />
      </Stack.Item>
    </Stack>
  );
};

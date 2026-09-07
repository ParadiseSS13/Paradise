import { Box, Button, Section, Stack, Table } from 'tgui-core/components';
import { KEY_0, KEY_9, KEY_BACKSPACE, KEY_ENTER, KEY_ESCAPE, KEY_NUMPAD_0, KEY_NUMPAD_9 } from 'tgui-core/keycodes';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const SecureStorage = (props) => {
  return (
    <Window theme="securestorage" height={500} width={280}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <MainPage />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const handleKeyCodeEvent = (e) => {
  const { act } = useBackend();
  const keyCode = window.event ? e.which : e.keyCode;

  if (keyCode === KEY_ENTER) {
    e.preventDefault();
    act('keypad', { digit: 'E' });
    return;
  }
  if (keyCode === KEY_ESCAPE) {
    e.preventDefault();
    act('keypad', { digit: 'C' });
    return;
  }
  if (keyCode === KEY_BACKSPACE) {
    e.preventDefault();
    act('backspace');
    return;
  }
  if (keyCode >= KEY_0 && keyCode <= KEY_9) {
    e.preventDefault();
    act('keypad', { digit: keyCode - KEY_0 });
    return;
  }
  if (keyCode >= KEY_NUMPAD_0 && keyCode <= KEY_NUMPAD_9) {
    e.preventDefault();
    act('keypad', { digit: keyCode - KEY_NUMPAD_0 });
    return;
  }
};

const MainPage = (props) => {
  const { act, data } = useBackend();
  const { locked, no_passcode, emagged, user_entered_code } = data;

  const keypadKeys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['C', '0', 'E'],
  ];

  const status = no_passcode ? '' : locked ? 'bad' : 'good';

  return (
    <Section fill className="SecureStorage" onKeyDown={(e) => handleKeyCodeEvent(e)}>
      <Stack fill vertical>
        <Stack.Item height={7.3}>
          <Box className={classes(['SecureStorage__displayBox', 'SecureStorage__displayBox--' + status])} height="100%">
            {emagged ? 'ERROR' : user_entered_code}
          </Box>
        </Stack.Item>
        <Stack.Item align="center">
          <Table collapsing>
            {keypadKeys.map((keyColumn) => (
              <Table.Row key={keyColumn[0]}>
                {keyColumn.map((key) => (
                  <Table.Cell key={key}>
                    <NumberButton number={key} />
                  </Table.Cell>
                ))}
              </Table.Row>
            ))}
          </Table>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const NumberButton = (props) => {
  const { act, data } = useBackend();
  const { number } = props;

  return (
    <Button
      bold
      fluid
      textAlign="center"
      fontSize="55px"
      lineHeight={1.25}
      width="80px"
      className={classes([
        'SecureStorage__Button',
        'SecureStorage__Button--keypad',
        'SecureStorage__Button--' + number,
      ])}
      onClick={() => act('keypad', { digit: number })}
    >
      {number}
    </Button>
  );
};

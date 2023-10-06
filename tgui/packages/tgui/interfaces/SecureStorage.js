import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Flex, Section, Table } from '../components';
import { Window } from '../layouts';
import { TableCell, TableRow } from '../components/Table';
import {
  KEY_BACKSPACE,
  KEY_ENTER,
  KEY_ESCAPE,
  KEY_0,
  KEY_9,
  KEY_NUMPAD_0,
  KEY_NUMPAD_9,
} from '../hotkeys';

export const SecureStorage = (props, context) => {
  return (
    <Window resizable theme="securestorage">
      <Window.Content>
        <MainPage />
      </Window.Content>
    </Window>
  );
};

const handleKeyCodeEvent = (e, context) => {
  const { act } = useBackend(context);
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

const MainPage = (props, context) => {
  const { act, data } = useBackend(context);
  const { locked, no_passcode, emagged, user_entered_code } = data;

  const keypadKeys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['C', '0', 'E'],
  ];

  const status = no_passcode ? '' : locked ? 'bad' : 'good';

  return (
    <Section
      height="100%"
      stretchContents
      onKeyDown={(e) => handleKeyCodeEvent(e, context)}
    >
      <Flex.Item height="20%" mb="5px">
        <Box
          className={classes([
            'SecureStorage__displayBox',
            'SecureStorage__displayBox--' + status,
          ])}
          height="100%"
        >
          {emagged ? 'ERROR' : user_entered_code}
        </Box>
      </Flex.Item>
      <Table width="1px">
        {keypadKeys.map((keyColumn) => (
          <TableRow key={keyColumn[0]}>
            {keyColumn.map((key) => (
              <TableCell key={key}>
                <NumberButton number={key} />
              </TableCell>
            ))}
          </TableRow>
        ))}
      </Table>
    </Section>
  );
};

const NumberButton = (props, context) => {
  const { act, data } = useBackend(context);
  const { number } = props;

  return (
    <Button
      fluid
      bold
      mb="6px"
      content={number}
      textAlign="center"
      fontSize="60px"
      lineHeight={1.25}
      width="80px"
      className={classes([
        'SecureStorage__Button',
        'SecureStorage__Button--keypad',
        'SecureStorage__Button--' + number,
      ])}
      onClick={() => act('keypad', { digit: number })}
    />
  );
};

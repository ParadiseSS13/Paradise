import { Box, Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  previous_attempts: Attempts[];
  attempts_left: number;
  game_mode: string;
  code_length: number;
};

type Attempts = {
  attempt: string;
  bulls?: number;
  cows?: number;
  letter_states?: string[];
};

const check_attempts = (attempts_to_check: number) => {
  return attempts_to_check === 1
    ? 'on next failed access attempt.'
    : `after ${attempts_to_check} failed access attempts.`;
};

const BULLS_COWS_INFO = `Codes are made of a series of non-repeating digits.
Each wrong guess will return the number of correct digits in correct locations,
and the number of correct digits in incorrect locations.`;

const WORDLE_INFO = `Guess the 5-letter word.
Green: Correct letter in correct position.
Yellow: Correct letter in wrong position.
Gray: Letter not in the word.`;

export const AbandonedCrate = (props) => {
  const { data } = useBackend<Data>();
  const { previous_attempts = [], attempts_left = 0, game_mode = 'numbers', code_length = 4 } = data;

  const isWordMode = game_mode === 'words';

  let lockTitle = 'Deca-Code Lock';
  let infoText = BULLS_COWS_INFO;

  if (isWordMode) {
    lockTitle = 'Word Lock';
    infoText = WORDLE_INFO;
  }

  return (
    <Window width={335} height={180 + previous_attempts.length * 19}>
      <Window.Content scrollable>
        <Section title={lockTitle} buttons={<Button tooltip={infoText} icon="info" tooltipPosition="top" />}>
          <NoticeBox color="bad">Anti-Tamper Bomb will activate {check_attempts(attempts_left)}</NoticeBox>
          {isWordMode ? (
            <WordleAttempts attempts={previous_attempts} />
          ) : (
            <NumbersAttempts attempts={previous_attempts} />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const NumbersAttempts = (props) => {
  const { attempts } = props;
  return (
    <Table>
      {!!attempts.length && (
        <Table.Row fontSize="125%" bold>
          <Table.Cell collapsing color="white" textAlign="center" pr="5px">
            Attempt
          </Table.Cell>
          <Table.Cell collapsing textAlign="center">
            <Button tooltip={'Correct digits at correct positions'} icon="check" color="green" />
          </Table.Cell>
          <Table.Cell collapsing textAlign="center">
            <Button tooltip={'Correct digits at incorrect positions'} icon="asterisk" color="yellow" />
          </Table.Cell>
        </Table.Row>
      )}
      {attempts.map((attempt) => (
        <Table.Row key={attempt.attempt} style={{ borderTop: '2px solid #222' }}>
          <Table.Cell collapsing textAlign="center" pr="5px">
            <Box color="white" inline fontSize="125%">
              {attempt.attempt}
            </Box>
          </Table.Cell>
          <Table.Cell collapsing textAlign="center">
            <Box color="green" inline fontSize="125%">
              {attempt.bulls}
            </Box>
          </Table.Cell>
          <Table.Cell collapsing textAlign="center">
            <Box color="yellow" inline fontSize="125%">
              {attempt.cows}
            </Box>
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const WordleAttempts = (props) => {
  const { attempts } = props;

  const getLetterColor = (state: string) => {
    switch (state) {
      case 'correct':
        return 'green';
      case 'present':
        return 'yellow';
      case 'absent':
      default:
        return 'grey';
    }
  };

  return (
    <Box>
      {attempts.map((attempt, idx) => (
        <Box key={idx} mb={0.5}>
          {attempt.attempt.split('').map((letter, letterIdx) => {
            const state = attempt.letter_states?.[letterIdx] || 'absent';
            return (
              <Box
                key={letterIdx}
                inline
                px={1}
                py={0.5}
                mr={0.3}
                backgroundColor={getLetterColor(state)}
                color="white"
                bold
                fontSize="125%"
                textAlign="center"
                style={{
                  minWidth: '30px',
                  border: '2px solid #222',
                }}
              >
                {letter}
              </Box>
            );
          })}
        </Box>
      ))}
    </Box>
  );
};

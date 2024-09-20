import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Stack, Section, Table, Icon } from '../../components';

export const pda_minesweeper = (props, context) => {
  const { act, data } = useBackend(context);

  const [currentWindow, setWindow] = useLocalState(context, 'window', 'Game');

  const AltWindow = {
    'Game': 'Leaderboard',
    'Leaderboard': 'Game',
  };

  return (
    <Stack fill vertical textAlign="center">
      <Box height="90%">{currentWindow === 'Game' ? <MineSweeperGame /> : <MineSweeperLeaderboard />}</Box>
      <Button height="10%" translucent onClick={() => setWindow(AltWindow[currentWindow])}>
        <Box mt="14px" fontSize="24px" verticalAlign="middle">
          <Icon name={currentWindow === 'Game' ? 'book' : 'gamepad'} />
          {AltWindow[currentWindow]}
        </Box>
      </Button>
    </Stack>
  );
};

export const MineSweeperGame = (props, context) => {
  const { act, data } = useBackend(context);
  const { matrix, flags, bombs } = data;

  const NumColor = {
    1: 'blue',
    2: 'green',
    3: 'red',
    4: 'darkblue',
    5: 'brown',
    6: 'lightblue',
    7: 'black',
    8: 'white',
  };

  document.addEventListener('contextmenu', (event) => event.preventDefault());
  const handleClick = (e, row, cell) => {
    if (e.button !== 0 && e.button !== 2) {
      return;
    }
    act('Square', {
      'X': row,
      'Y': cell,
      'mode': e.button === 2 ? 'flag' : 'bomb',
    });
  };

  return (
    <Stack>
      <Stack.Item>
        {Object.keys(matrix).map((row) => (
          <Box key={row}>
            {Object.keys(matrix[row]).map((cell) => (
              <Button
                key={cell}
                m="1px"
                height="25px"
                width="25px"
                className={matrix[row][cell]['open'] ? 'Minesweeper__open' : 'Minesweeper__closed'}
                bold
                color="transparent"
                icon={
                  matrix[row][cell]['open']
                    ? matrix[row][cell]['bomb']
                      ? 'bomb'
                      : ''
                    : matrix[row][cell]['flag']
                      ? 'flag'
                      : ''
                }
                textColor={
                  matrix[row][cell]['open']
                    ? matrix[row][cell]['bomb']
                      ? 'black'
                      : NumColor[matrix[row][cell]['around']]
                    : matrix[row][cell]['flag']
                      ? 'red'
                      : 'gray'
                }
                onMouseDown={(e) => handleClick(e, row, cell)}
              >
                {!!matrix[row][cell]['open'] && !matrix[row][cell]['bomb'] && matrix[row][cell]['around']
                  ? matrix[row][cell]['around']
                  : ' '}
              </Button>
            ))}
          </Box>
        ))}
      </Stack.Item>
      <Stack.Item ml="15px" mt="10px" grow>
        <Section className="Minesweeper__infobox" width="100%">
          <Box>
            <Icon name="bomb" color="gray" />: {bombs}
            <br />
            <Icon name="flag" color="red" />: {flags}
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const MineSweeperLeaderboard = (props, context) => {
  const { act, data } = useBackend(context);
  const { leaderboard } = data;

  return (
    <Table className="Minesweeper__list">
      <Table.Row bold>
        <SortButton id="name">Nick</SortButton>
        <SortButton id="time">Time</SortButton>
      </Table.Row>
      {leaderboard &&
        leaderboard
          .sort((a, b) => {
            const i = sortOrder ? 1 : -1;
            return a[sortId].localeCompare(b[sortId]) * i;
          })
          .map((player, i) => (
            <Table.Row key={i}>
              <Table.Cell>{player.name}</Table.Cell>
              <Table.Cell>{player.time}</Table.Cell>
            </Table.Row>
          ))}
    </Table>
  );
};

const SortButton = (properties, context) => {
  const [sortId, setSortId] = useLocalState(context, 'sortId', 'time');
  const [sortOrder, setSortOrder] = useLocalState(context, 'sortOrder', false);
  const { id, children } = properties;
  return (
    <Table.Cell>
      <Button
        fluid
        color="transparent"
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}
      >
        {children}
        {sortId === id && <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />}
      </Button>
    </Table.Cell>
  );
};

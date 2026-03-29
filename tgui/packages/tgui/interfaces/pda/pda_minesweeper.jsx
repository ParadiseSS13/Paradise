import { useContext, useState } from 'react';
import { Box, Button, Icon, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import SortableTableContext from '../common/SortableTableContext';

export const pda_minesweeper = (props) => {
  const { act, data } = useBackend();

  const [currentWindow, setWindow] = useState('Game');

  const AltWindow = {
    Game: 'Leaderboard',
    Leaderboard: 'Game',
  };

  return (
    <Stack fill vertical textAlign="center">
      <Stack.Item grow>{currentWindow === 'Game' ? <MineSweeperGame /> : <MineSweeperLeaderboard />}</Stack.Item>
      <Stack.Item>
        <Button
          fluid
          color="transparent"
          fontSize={2}
          lineHeight={1.75}
          icon={currentWindow === 'Game' ? 'book' : 'gamepad'}
          onClick={() => setWindow(AltWindow[currentWindow])}
        >
          {AltWindow[currentWindow]}
        </Button>
      </Stack.Item>
    </Stack>
  );
};

export const MineSweeperGame = (props) => {
  const { act, data } = useBackend();
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

  const handleClick = (row, cell, mode) => {
    act('Square', {
      X: row,
      Y: cell,
      mode: mode,
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
                m={0.25}
                height={2}
                width={2}
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
                onClick={(e) => handleClick(row, cell, 'bomb')}
                onContextMenu={(e) => {
                  event.preventDefault();
                  handleClick(row, cell, 'flag');
                }}
              >
                {!!matrix[row][cell]['open'] && !matrix[row][cell]['bomb'] && matrix[row][cell]['around']
                  ? matrix[row][cell]['around']
                  : ' '}
              </Button>
            ))}
          </Box>
        ))}
      </Stack.Item>
      <Stack.Item grow className="Minesweeper__infobox">
        <Stack vertical textAlign="left" pt={1}>
          <Stack.Item pl={2} fontSize={2}>
            <Icon name="bomb" color="gray" /> : {bombs}
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item pl={2} fontSize={2}>
            <Icon name="flag" color="red" /> : {flags}
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const MineSweeperLeaderboard = (props) => (
  <SortableTableContext.Default sortId="time" sortOrder={false}>
    <MineSweeperLeaderboardBase />
  </SortableTableContext.Default>
);

const MineSweeperLeaderboardBase = (props) => {
  const { act, data } = useBackend();
  const { leaderboard } = data;
  const { sortId, sortOrder } = useContext(SortableTableContext);

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

const SortButton = (properties) => {
  const { sortId, setSortId, sortOrder, setSortOrder } = useContext(SortableTableContext);
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

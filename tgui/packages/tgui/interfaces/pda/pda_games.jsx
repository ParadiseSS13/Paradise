import { Box, Button, Icon } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const pda_games = (props) => {
  const { act, data } = useBackend();
  const { games } = data;

  const GetAppImage = (AppName) => {
    switch (AppName) {
      case 'Minesweeper':
        return (
          <Icon.Stack>
            <Icon ml="4px" mt="10px" name="flag" size="6" color="gray" rotation={30} />
            <Icon ml="20px" mt="4px" name="bomb" size="3" color="black" />
          </Icon.Stack>
        );
      default:
        return <Icon ml="16px" mt="10px" name="gamepad" size="6" />;
    }
  };

  return (
    <Box>
      {games.map((game) => (
        <Button
          key={game.name}
          width="33%"
          textAlign="center"
          color="transparent"
          onClick={() => act('play', { id: game.id })}
        >
          {GetAppImage(game.name)}
          <Box>{game.name}</Box>
        </Button>
      ))}
    </Box>
  );
};

import { useBackend } from '../../backend';
import { Box, Button, ImageButton, Section } from '../../components';
import { Icon, IconStack } from '../../components/Icon';

export const pda_games = (props, context) => {
  const { act, data } = useBackend(context);
  const { games } = data;

  const GetAppImage = (AppName) => {
    switch (AppName) {
      case 'Minesweeper':
        return (
          <IconStack>
            <Icon ml="0" mt="10px" name="flag" size="6" color="gray" rotation={30} />
            <Icon ml="9px" mt="23px" name="bomb" size="3" color="black" />
          </IconStack>
        );
      default:
        return <Icon ml="16px" mt="10px" name="gamepad" size="6" />;
    }
  };

  return (
    <Box>
      {games.map((game) => (
        <Button key={game.name} width="33%" textAlign="center" translucent onClick={() => act('play', { id: game.id })}>
          {GetAppImage(game.name)}
          <Box>{game.name}</Box>
        </Button>
      ))}
    </Box>
  );
};

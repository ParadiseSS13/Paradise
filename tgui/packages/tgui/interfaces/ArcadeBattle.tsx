import { Box, Button, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ArcadeBattleProps = {
  enemyName: string;
  enemyHP: number;
  playerHP: number;
  playerMaxHP: number;
  playerMP: number;
  playerMaxMP: number;
  onCooldown: boolean;
  gameOver: boolean;
  previousEvent: string;
  enemyMaxHP: number;
};

export const ArcadeBattle = (props, context) => {
  const { act, data } = useBackend<ArcadeBattleProps>();
  const {
    enemyName,
    playerHP,
    playerMaxHP,
    playerMP,
    playerMaxMP,
    enemyHP,
    enemyMaxHP,
    onCooldown,
    gameOver,
    previousEvent,
  } = data;

  if (gameOver) {
    return (
      <Window height={350} width={350}>
        <Window.Content>
          <Section fill align="center" title={enemyHP < 1 ? 'Rejoyce!' : 'Game Over!'}>
            <Stack justify="space-between" vertical fill>
              <Stack.Item>
                <Box>{previousEvent}</Box>
              </Stack.Item>
              <Stack.Item height="30%">
                <Button
                  bold
                  fluid
                  height="100%"
                  fontSize="min(8vw, 15vh)"
                  textAlign="center"
                  verticalAlignContent="middle"
                  onClick={() => act('newgame')}
                >
                  New Game
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {
    return (
      <Window height={350} width={350}>
        <Window.Content>
          <Stack vertical fill>
            <Stack.Item>
              <Section title={enemyName}>
                <ProgressBar
                  maxValue={enemyMaxHP}
                  minValue={0}
                  value={enemyHP}
                  ranges={{
                    red: [-10, 10],
                    orange: [10, 20],
                    green: [20, enemyMaxHP],
                  }}
                >
                  Their Health: {enemyHP}
                </ProgressBar>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Fight!">{previousEvent}</Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill title="You">
                <Stack vertical>
                  <Stack.Item>
                    <ProgressBar
                      maxValue={playerMaxHP}
                      minValue={0}
                      value={playerHP}
                      ranges={{
                        red: [-10, 10],
                        orange: [10, 20],
                        green: [20, playerMaxHP],
                      }}
                    >
                      Your Health: {playerHP}
                    </ProgressBar>
                  </Stack.Item>
                  <Stack.Item>
                    <ProgressBar
                      maxValue={playerMaxMP}
                      minValue={0}
                      value={playerMP}
                      ranges={{
                        red: [-10, playerMaxMP / 4],
                        orange: [playerMaxMP / 4, playerMaxMP / 2],
                        green: [playerMaxMP / 2, playerMaxMP],
                      }}
                    >
                      Your Magic: {playerMP}
                    </ProgressBar>
                  </Stack.Item>
                  <Stack.Item>
                    <Box bold align="center">
                      What will you do?
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack justify="center">
                      <Stack.Item>
                        <Button icon="burst" lineHeight={3} onClick={() => act('attack')} disabled={onCooldown}>
                          Attack
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button icon="plus" lineHeight={3} onClick={() => act('heal')} disabled={onCooldown}>
                          Heal
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button icon="star" lineHeight={3} onClick={() => act('charge')} disabled={onCooldown}>
                          Recharge
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
};

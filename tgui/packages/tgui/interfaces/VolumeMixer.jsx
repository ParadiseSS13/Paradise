import { Fragment } from 'react';
import { Box, Button, Icon, Section, Slider, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const VolumeMixer = (properties) => {
  const { act, data } = useBackend();
  const { channels } = data;
  return (
    <Window width={350} height={Math.min(95 + channels.length * 50, 565)}>
      <Window.Content>
        <Section fill scrollable>
          {channels.map((channel, key) => (
            <Fragment key={channel.num}>
              <Box fontSize="1.25rem" color="label" mt={key > 0 && '0.5rem'}>
                {channel.name}
              </Box>
              <Box mt="0.5rem">
                <Stack>
                  <Stack.Item mr={0.5}>
                    <Button width="24px" color="transparent">
                      <Icon
                        name="volume-off"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() => act('volume', { channel: channel.num, volume: 0 })}
                      />
                    </Button>
                  </Stack.Item>
                  <Stack.Item grow mx="0.5rem">
                    <Slider
                      minValue={0}
                      maxValue={100}
                      stepPixelSize={3.13}
                      value={channel.volume}
                      onChange={(e, value) => act('volume', { channel: channel.num, volume: value })}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button width="24px" color="transparent">
                      <Icon
                        name="volume-up"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() => act('volume', { channel: channel.num, volume: 100 })}
                      />
                    </Button>
                  </Stack.Item>
                </Stack>
              </Box>
            </Fragment>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

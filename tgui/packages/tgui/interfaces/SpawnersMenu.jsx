import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const SpawnersMenu = (props) => {
  const { act, data } = useBackend();
  const spawners = data.spawners || [];
  return (
    <Window width={700} height={600}>
      <Window.Content scrollable>
        <Section>
          {spawners.map((spawner) => (
            <Section
              mb={0.5}
              key={spawner.name}
              title={spawner.name + ' (' + spawner.amount_left + ' left)'}
              level={2}
              buttons={
                <>
                  <Button
                    icon="chevron-circle-right"
                    content="Jump"
                    onClick={() =>
                      act('jump', {
                        ID: spawner.uids,
                      })
                    }
                  />
                  <Button
                    icon="chevron-circle-right"
                    content="Spawn"
                    onClick={() =>
                      act('spawn', {
                        ID: spawner.uids,
                      })
                    }
                  />
                </>
              }
            >
              <Box
                style={{ whiteSpace: 'pre-wrap' }} // preserve newline
                mb={1}
                fontSize="16px"
              >
                {spawner.desc}
              </Box>
              {!!spawner.fluff && (
                <Box // lighter grey than default grey for better contrast.
                  style={{ whiteSpace: 'pre-wrap' }}
                  textColor="#878787"
                  fontSize="14px"
                >
                  {spawner.fluff}
                </Box>
              )}
              {!!spawner.important_info && (
                <Box style={{ whiteSpace: 'pre-wrap' }} mt={1} bold color="red" fontSize="18px">
                  {spawner.important_info}
                </Box>
              )}
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

import { useBackend } from '../backend';
import { Box, Section, Stack, NoticeBox, Button, Tooltip, Divider } from 'tgui-core/components';
import { Window } from '../layouts';

const RodDisplay = ({ rods, title }) => {
  const { act } = useBackend();

  if (!rods || rods.length === 0) {
    return (
      <Section title={title}>
        <NoticeBox type="info">No **{title.toLowerCase()}** designs found.</NoticeBox>
      </Section>
    );
  }

  return (
    <Section title={`${title} (${rods.length} found)`} level={2}>
      {rods.map((rod, i) => {
        return (
          <Box
            key={i}
            p={1}
            mb={0.5}
            style={{
              borderBottom: '1px solid var(--tgui-color-dark-gray)',
              backgroundColor: 'rgba(255,255,255,0.02)',
            }}
          >
            <Stack align="center">
              <Stack.Item grow>
                <Stack vertical>
                  <Stack.Item>
                    <Box bold fontSize="1.1em">
                      {rod.name || (
                        <Box inline color="bad">
                          [Unnamed Design]
                        </Box>
                      )}
                    </Box>
                  </Stack.Item>

                  <Stack.Item>
                    <Box fontSize="0.9em" color="label" mb={0.5}>
                      {rod.desc || (
                        <Box inline color="average">
                          [No description available]
                        </Box>
                      )}
                    </Box>
                  </Stack.Item>

                  <Stack.Item>
                    <Box fontSize="0.85em">
                      <Box inline color="label">
                        Heat Mod:
                      </Box>{' '}
                      <Box inline bold color={rod.heat_amp_mod ? 'good' : 'bad'}>
                        {rod.heat_amp_mod ?? 'N/A'}
                      </Box>
                      {' | '}
                      <Box inline color="label">
                        Power Mod:
                      </Box>{' '}
                      <Box inline bold color={rod.power_amp_mod ? 'good' : 'bad'}>
                        {rod.power_amp_mod ?? 'N/A'}
                      </Box>
                    </Box>
                  </Stack.Item>

                  {/* NOTE: Removed the [Debug: craftable = ...] line */}
                </Stack>
              </Stack.Item>

              <Stack.Item align="right">
                <Stack vertical>
                  <Stack.Item>
                    <Button
                      icon="wrench"
                      content="Fabricate"
                      tooltip="Fabrication not yet implemented"
                      disabled
                      // act="fabricate_rod" - add this when implementation is ready
                    />
                  </Stack.Item>

                  <Stack.Item>
                    <Tooltip
                      content={
                        <Box p={1} style={{ whiteSpace: 'pre-wrap', maxWidth: '400px' }}>
                          <Box bold mb={0.5}>
                            Full Object Data:
                          </Box>
                          {JSON.stringify(rod, null, 2)}
                        </Box>
                      }
                      position="left"
                    >
                      <Button icon="info-circle">Details</Button>
                    </Tooltip>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Box>
        );
      })}
    </Section>
  );
};

export const NuclearRodFabricator = (props) => {
  const { data } = useBackend(props);

  const totalRods =
    (Array.isArray(data.fuel_rods) ? data.fuel_rods.length : 0) +
    (Array.isArray(data.moderator_rods) ? data.moderator_rods.length : 0) +
    (Array.isArray(data.coolant_rods) ? data.coolant_rods.length : 0);

  return (
    <Window width={600} height={800}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Section title="Nuclear Rod Fabricator">
            <Box bold fontSize="1.1em">
              Total Craftable Designs: **{totalRods}**
            </Box>
          </Section>

          <Divider />

          <RodDisplay rods={data.fuel_rods} title="Fuel Rod Designs" />

          <RodDisplay rods={data.moderator_rods} title="Moderator Rod Designs" />

          <RodDisplay rods={data.coolant_rods} title="Coolant Rod Designs" />
        </Stack>
      </Window.Content>
    </Window>
  );
};

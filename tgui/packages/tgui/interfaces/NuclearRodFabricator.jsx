import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const NuclearRodFabricator = (props) => {
  const { data, act } = useBackend(props);

  const categories = [
    { key: 'fuel_rods', title: 'Fuel Rods' },
    { key: 'moderator_rods', title: 'Moderator Rods' },
    { key: 'coolant_rods', title: 'Coolant Rods' },
  ];

  const [selectedRod, setSelectedRod] = useState(null);

  const totalRods =
    (data.fuel_rods?.length || 0) +
    (data.moderator_rods?.length || 0) +
    (data.coolant_rods?.length || 0);

  return (
    <Window width={850} height={600}>
      <Window.Content>
        <Stack fill stretch>

          {/* Left Side */}
          <Stack.Item width="50%">
            <Section
              title={`Available Designs (${totalRods})`}
              fill
              scrollable
            >
              {categories.map((cat) => {
                const list = data[cat.key] || [];
                return (
                  <Section key={cat.key} title={cat.title} level={2}>
                    {list.length === 0 && (
                      <Box color="average">
                        No {cat.title.toLowerCase()} available.
                      </Box>
                    )}

                    {list.map((rod, i) => (
                      <Box
                        key={i}
                        p={1}
                        mb={0.5}
                        style={{
                          cursor: 'pointer',
                          backgroundColor:
                            selectedRod === rod
                              ? 'rgba(80, 140, 255, 0.25)'
                              : 'rgba(255,255,255,0.03)',
                          border: '1px solid rgba(255,255,255,0.08)',
                        }}
                        onClick={() => setSelectedRod(rod)}
                      >
                        <Box bold>{rod.name}</Box>
                        <Box fontSize="0.85em" color="label">
                          {rod.desc}
                        </Box>
                      </Box>
                    ))}
                  </Section>
                );
              })}
            </Section>
          </Stack.Item>

          {/* Right Side */}
          <Stack.Item grow>
            <Section title="Manufacturing Console" fill>
              {!selectedRod && (
                <NoticeBox>Please select a rod design from the left.</NoticeBox>
              )}

              {selectedRod && (
                <Stack vertical fill>

                  <Box bold fontSize="1.2em">
                    {selectedRod.name}
                  </Box>

                  <Box mb={1} color="label">
                    {selectedRod.desc}
                  </Box>

                  <Divider />

                  {/* Required Materials */}
                  <Section title="Required Materials">
                    {!selectedRod.materials ||
                    Object.keys(selectedRod.materials).length === 0 ? (
                      <Box color="average">No materials required.</Box>
                    ) : (
                      <Table>
                        {Object.entries(selectedRod.materials).map(
                          ([matName, matAmt], i) => (
                            <Table.Row key={i}>
                              <Table.Cell bold>{matName}</Table.Cell>
                              <Table.Cell>{matAmt}</Table.Cell>
                            </Table.Row>
                          )
                        )}
                      </Table>
                    )}
                  </Section>

                  <Divider />

                  {/* Resources */}
                  <Section title="Resources">
                    {!data.resources ||
                    Object.keys(data.resources).length === 0 ? (
                      <Box color="average">No resources available.</Box>
                    ) : (
                      <Table>
                        {Object.entries(data.resources).map(
                          ([resName, resAmt], i) => (
                            <Table.Row key={i}>
                              <Table.Cell bold>{resName}</Table.Cell>
                              <Table.Cell>{resAmt}</Table.Cell>
                            </Table.Row>
                          )
                        )}
                      </Table>
                    )}
                  </Section>

                  <Divider />

                  {/* Fabricate Button */}
                  <Button
                    icon="wrench"
                    content={`Fabricate ${selectedRod.name}`}
                    color="good"
                    onClick={() =>
                      act('fabricate_rod', { type_path: selectedRod.type_path })
                    }
                  />

                  {/* Debug TODO: remove later*/}
                  <Tooltip
                    content={
                      <Box p={1} style={{ whiteSpace: 'pre-wrap' }}>
                        {JSON.stringify(selectedRod, null, 2)}
                      </Box>
                    }
                    position="left"
                  >
                    <Button icon="info-circle" mt={1}>
                      Raw Metadata
                    </Button>
                  </Tooltip>

                </Stack>
              )}
            </Section>
          </Stack.Item>

        </Stack>
      </Window.Content>
    </Window>
  );
};

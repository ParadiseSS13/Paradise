import { Box, Button, Icon, NumberInput, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const CloningPod = (props) => {
  const { act, data } = useBackend();
  const { biomass, biomass_storage_capacity, sanguine_reagent, osseous_reagent, organs, currently_cloning } = data;
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        <Section title="Liquid Storage">
          <Stack height="25px" align="center">
            <Stack.Item color="label" width="25%">
              Biomass:{' '}
            </Stack.Item>
            <Stack.Item grow={1}>
              <ProgressBar
                value={biomass}
                ranges={{
                  good: [(2 * biomass_storage_capacity) / 3, biomass_storage_capacity],
                  average: [biomass_storage_capacity / 3, (2 * biomass_storage_capacity) / 3],
                  bad: [0, biomass_storage_capacity / 3], // This is just thirds
                }}
                minValue={0}
                maxValue={biomass_storage_capacity}
              />
            </Stack.Item>
          </Stack>
          <Stack height="25px" align="center">
            <Stack.Item color="label" width="25%">
              Sanguine Reagent:{' '}
            </Stack.Item>
            <Stack.Item>{sanguine_reagent + ' units'}</Stack.Item>
            <Stack.Item grow={1} />
            <Stack.Item>
              <NumberInput
                value={0}
                minValue={0}
                maxValue={sanguine_reagent}
                step={1}
                unit="units"
                onChange={(value) =>
                  act('remove_reagent', {
                    reagent: 'sanguine_reagent',
                    amount: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button content="Remove All" onClick={() => act('purge_reagent', { reagent: 'sanguine_reagent' })} />
            </Stack.Item>
          </Stack>
          <Stack height="25px" align="center">
            <Stack.Item color="label" width="25%">
              Osseous Reagent:{' '}
            </Stack.Item>
            <Stack.Item>{osseous_reagent + ' units'}</Stack.Item>
            <Stack.Item grow={1} />
            <Stack.Item>
              <NumberInput
                value={0}
                minValue={0}
                maxValue={osseous_reagent}
                step={1}
                unit="units"
                onChange={(value) =>
                  act('remove_reagent', {
                    reagent: 'osseous_reagent',
                    amount: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button content="Remove All" onClick={() => act('purge_reagent', { reagent: 'osseous_reagent' })} />
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Organ Storage">
          {!currently_cloning && (
            <Box>
              {!organs && <Box color="average">Notice: No organs loaded.</Box>}
              {!!organs &&
                organs.map((organ) => (
                  <Stack key={organ}>
                    <Stack.Item>{organ.name}</Stack.Item>
                    <Stack.Item grow={1} />
                    <Stack.Item>
                      <Button content="Eject" onClick={() => act('eject_organ', { organ_ref: organ.ref })} />
                    </Stack.Item>
                  </Stack>
                ))}
            </Box>
          )}
          {!!currently_cloning && (
            <Stack height="100%">
              <Stack.Item bold grow="1" textAlign="center" align="center" color="label">
                <Icon name="lock" size="5" mb={3} />
                <br />
                Unable to access organ storage while cloning.
              </Stack.Item>
            </Stack>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

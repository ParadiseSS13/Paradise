import { useBackend } from '../backend';
import {
  Button,
  ProgressBar,
  Section,
  Box,
  Flex,
  Icon,
  NumberInput,
} from '../components';
import { Window } from '../layouts';

export const CloningPod = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    biomass,
    biomass_storage_capacity,
    sanguine_reagent,
    osseous_reagent,
    organs,
    currently_cloning,
  } = data;
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        <Section title="Liquid Storage">
          <Flex height="25px" align="center">
            <Flex.Item color="label" width="25%">
              Biomass:{' '}
            </Flex.Item>
            <Flex.Item grow={1}>
              <ProgressBar
                value={biomass}
                ranges={{
                  good: [
                    (2 * biomass_storage_capacity) / 3,
                    biomass_storage_capacity,
                  ],
                  average: [
                    biomass_storage_capacity / 3,
                    (2 * biomass_storage_capacity) / 3,
                  ],
                  bad: [0, biomass_storage_capacity / 3], // This is just thirds
                }}
                minValue={0}
                maxValue={biomass_storage_capacity}
              />
            </Flex.Item>
          </Flex>
          <Flex height="25px" align="center">
            <Flex.Item color="label" width="25%">
              Sanguine Reagent:{' '}
            </Flex.Item>
            <Flex.Item>{sanguine_reagent + ' units'}</Flex.Item>
            <Flex.Item grow={1} />
            <Flex.Item>
              <NumberInput
                value={0}
                minValue={0}
                maxValue={sanguine_reagent}
                step={1}
                unit="units"
                onChange={(e, value) =>
                  act('remove_reagent', {
                    reagent: 'sanguine_reagent',
                    amount: value,
                  })
                }
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                content="Remove All"
                onClick={() =>
                  act('purge_reagent', { reagent: 'sanguine_reagent' })
                }
              />
            </Flex.Item>
          </Flex>
          <Flex height="25px" align="center">
            <Flex.Item color="label" width="25%">
              Osseous Reagent:{' '}
            </Flex.Item>
            <Flex.Item>{osseous_reagent + ' units'}</Flex.Item>
            <Flex.Item grow={1} />
            <Flex.Item>
              <NumberInput
                value={0}
                minValue={0}
                maxValue={osseous_reagent}
                step={1}
                unit="units"
                onChange={(e, value) =>
                  act('remove_reagent', {
                    reagent: 'osseous_reagent',
                    amount: value,
                  })
                }
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                content="Remove All"
                onClick={() =>
                  act('purge_reagent', { reagent: 'osseous_reagent' })
                }
              />
            </Flex.Item>
          </Flex>
        </Section>
        <Section title="Organ Storage">
          {!currently_cloning && (
            <Box>
              {!organs && <Box color="average">Notice: No organs loaded.</Box>}
              {!!organs &&
                organs.map((organ) => (
                  <Flex key={organ}>
                    <Flex.Item>{organ.name}</Flex.Item>
                    <Flex.Item grow={1} />
                    <Flex.Item>
                      <Button
                        content="Eject"
                        onClick={() =>
                          act('eject_organ', { organ_ref: organ.ref })
                        }
                      />
                    </Flex.Item>
                  </Flex>
                ))}
            </Box>
          )}
          {!!currently_cloning && (
            <Flex height="100%">
              <Flex.Item
                bold
                grow="1"
                textAlign="center"
                align="center"
                color="label"
              >
                <Icon name="lock" size="5" mb={3} />
                <br />
                Unable to access organ storage while cloning.
              </Flex.Item>
            </Flex>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

import { Box, Button, LabeledList, NumberInput, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

export const CompostBin = (props) => {
  const { act, data } = useBackend();
  const {
    biomass,
    compost,
    biomass_capacity,
    compost_capacity,
    potassium,
    potassium_capacity,
    potash,
    potash_capacity,
  } = data;

  let [vendAmount, setVendAmount] = useSharedState('vendAmount', 1);

  return (
    <Window width={360} height={260}>
      <Window.Content>
        <Stack fill vertical>
          <Section label="Resources">
            <Stack>
              <LabeledList>
                <LabeledList.Item label="Biomass">
                  <ProgressBar
                    ml={0.5}
                    mt={1}
                    width={20}
                    value={biomass}
                    minValue={0}
                    maxValue={biomass_capacity}
                    ranges={{
                      good: [biomass_capacity * 0.5, Infinity],
                      average: [biomass_capacity * 0.25, biomass_capacity * 0.5],
                      bad: [-Infinity, biomass_capacity * 0.25],
                    }}
                  >
                    {biomass} / {biomass_capacity} Units
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Compost">
                  <ProgressBar
                    ml={0.5}
                    mt={1}
                    width={20}
                    value={compost}
                    minValue={0}
                    maxValue={compost_capacity}
                    ranges={{
                      good: [compost_capacity * 0.5, Infinity],
                      average: [compost_capacity * 0.25, compost_capacity * 0.5],
                      bad: [-Infinity, compost_capacity * 0.25],
                    }}
                  >
                    {compost} / {compost_capacity} Units
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Potassium">
                  <ProgressBar
                    ml={0.5}
                    mt={1}
                    width={20}
                    value={potassium}
                    minValue={0}
                    maxValue={potassium_capacity}
                    ranges={{
                      good: [potassium_capacity * 0.5, Infinity],
                      average: [potassium_capacity * 0.25, potassium_capacity * 0.5],
                      bad: [-Infinity, potassium_capacity * 0.25],
                    }}
                  >
                    {potassium} / {potassium_capacity} Units
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Potash">
                  <ProgressBar
                    ml={0.5}
                    mt={1}
                    width={20}
                    value={potash}
                    minValue={0}
                    maxValue={potash_capacity}
                    ranges={{
                      good: [potash_capacity * 0.5, Infinity],
                      average: [potash_capacity * 0.25, potash_capacity * 0.5],
                      bad: [-Infinity, potash_capacity * 0.25],
                    }}
                  >
                    {potash} / {potash_capacity} Units
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Stack>
          </Section>
          <Section
            title="Controls"
            buttons={
              <>
                <Box inline mr="5px" color="silver">
                  Soil clumps to make:
                </Box>
                <NumberInput
                  animated
                  value={vendAmount}
                  width="32px"
                  minValue={1}
                  maxValue={10}
                  step={1}
                  stepPixelSize={7}
                  onChange={(value) => setVendAmount(value)}
                />
              </>
            }
          >
            <Stack.Item>
              <Button
                fluid
                align="center"
                content="Make Soil"
                disabled={compost < 25 * vendAmount}
                icon="arrow-circle-down"
                onClick={() =>
                  act('create', {
                    amount: vendAmount,
                  })
                }
              />
            </Stack.Item>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

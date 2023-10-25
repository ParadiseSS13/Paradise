import { useBackend, useSharedState } from '../backend';
import {
  Button,
  Section,
  Box,
  Flex,
  Icon,
  Collapsible,
  NumberInput,
  ProgressBar,
  Dimmer,
  LabeledList,
} from '../components';
import { Window } from '../layouts';

export const CompostBin = (props, context) => {
  const { act, data } = useBackend(context);
  const { biomass, compost, biomass_capacity, compost_capacity } = data;

  let [vendAmount, setVendAmount] = useSharedState(context, 'vendAmount', 1);

  return (
    <Window>
      <Window.Content>
        <Section label="Resources">
          <Flex>
            <LabeledList>
              <LabeledList.Item label="Biomass">
                <ProgressBar
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
            </LabeledList>
          </Flex>
          <Flex>
            <LabeledList>
              <LabeledList.Item label="Compost">
                <ProgressBar
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
            </LabeledList>
          </Flex>
        </Section>
        <Section title="Controls">
          <Flex>
            <Box inline mr="5px" color="silver">
              Soil clumps to make:
            </Box>
            <NumberInput
              animated
              value={vendAmount}
              width="32px"
              minValue={1}
              maxValue={10}
              stepPixelSize={7}
              onChange={(e, value) => setVendAmount(value)}
            />
          </Flex>
          <Flex.Item mr="5px" textAlign="right" width="0%">
            <Button
              align="right"
              content="Make Soil"
              disabled={compost < 25 * vendAmount}
              icon="arrow-circle-down"
              onClick={() =>
                act('create', {
                  amount: vendAmount,
                })
              }
            />
          </Flex.Item>
        </Section>
      </Window.Content>
    </Window>
  );
};

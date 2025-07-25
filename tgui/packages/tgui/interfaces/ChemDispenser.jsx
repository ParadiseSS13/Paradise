import { Box, Button, LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';

const dispenseAmounts = [1, 5, 10, 20, 30, 50];
const removeAmounts = [1, 5, 10];

export const ChemDispenser = (props) => {
  const { act, data } = useBackend();
  const { chemicals } = data;
  return (
    <Window width={400} height={400 + Math.ceil(chemicals.length / 3) * 24}>
      <Window.Content>
        <Stack fill vertical>
          <ChemDispenserSettings />
          <ChemDispenserChemicals />
          <ChemDispenserBeaker />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ChemDispenserSettings = (properties) => {
  const { act, data } = useBackend();
  const { amount, energy, maxEnergy } = data;
  return (
    <Stack.Item>
      <Section title="Settings">
        <LabeledList>
          <LabeledList.Item label="Energy">
            <ProgressBar
              value={energy}
              minValue={0}
              maxValue={maxEnergy}
              ranges={{
                good: [maxEnergy * 0.5, Infinity],
                average: [maxEnergy * 0.25, maxEnergy * 0.5],
                bad: [-Infinity, maxEnergy * 0.25],
              }}
            >
              {energy} / {maxEnergy} Units
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Dispense" verticalAlign="middle">
            <Stack>
              {dispenseAmounts.map((a, i) => (
                <Stack.Item key={i} grow width="15%">
                  <Button
                    fluid
                    icon="cog"
                    selected={amount === a}
                    content={a}
                    onClick={() =>
                      act('amount', {
                        amount: a,
                      })
                    }
                  />
                </Stack.Item>
              ))}
            </Stack>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const ChemDispenserChemicals = (properties) => {
  const { act, data } = useBackend();
  const { chemicals = [] } = data;
  const flexFillers = [];
  for (let i = 0; i < (chemicals.length + 1) % 3; i++) {
    flexFillers.push(true);
  }
  return (
    <Stack.Item grow>
      <Section fill scrollable title={data.glass ? 'Drink Dispenser' : 'Chemical Dispenser'}>
        {chemicals.map((c, i) => (
          <Button
            m={0.1}
            key={i}
            width="32.5%"
            icon="arrow-circle-down"
            overflow="hidden"
            content={c.title}
            style={{ marginLeft: '2px', textOverflow: 'ellipsis' }}
            onClick={() =>
              act('dispense', {
                reagent: c.id,
              })
            }
          />
        ))}
        {flexFillers.map((_, i) => (
          <Stack.Item key={i} grow basis="25%" />
        ))}
      </Section>
    </Stack.Item>
  );
};

const ChemDispenserBeaker = (properties) => {
  const { act, data } = useBackend();
  const { isBeakerLoaded, beakerCurrentVolume, beakerMaxVolume, beakerContents = [] } = data;
  return (
    <Stack.Item height={16}>
      <Section
        title={data.glass ? 'Glass' : 'Beaker'}
        fill
        scrollable
        buttons={
          <Box>
            {!!isBeakerLoaded && (
              <Box inline color="label" mr={2}>
                {beakerCurrentVolume} / {beakerMaxVolume} units
              </Box>
            )}
            <Button icon="eject" content="Eject" disabled={!isBeakerLoaded} onClick={() => act('ejectBeaker')} />
          </Box>
        }
      >
        <BeakerContents
          beakerLoaded={isBeakerLoaded}
          beakerContents={beakerContents}
          buttons={(chemical) => (
            <>
              <Button
                content="Isolate"
                icon="compress-arrows-alt"
                onClick={() =>
                  act('remove', {
                    reagent: chemical.id,
                    amount: -1,
                  })
                }
              />
              {removeAmounts.map((a, i) => (
                <Button
                  key={i}
                  content={a}
                  onClick={() =>
                    act('remove', {
                      reagent: chemical.id,
                      amount: a,
                    })
                  }
                />
              ))}
              <Button
                content="ALL"
                onClick={() =>
                  act('remove', {
                    reagent: chemical.id,
                    amount: chemical.volume,
                  })
                }
              />
            </>
          )}
        />
      </Section>
    </Stack.Item>
  );
};

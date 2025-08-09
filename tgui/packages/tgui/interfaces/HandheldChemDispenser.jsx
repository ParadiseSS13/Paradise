import { Button, LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const dispenseAmounts = [1, 5, 10, 20, 30, 50];
const removeAmounts = [1, 5, 10];

export const HandheldChemDispenser = (props) => {
  return (
    <Window width={390} height={430}>
      <Window.Content>
        <Stack fill vertical>
          <HandheldChemDispenserSettings />
          <HandheldChemDispenserChemicals />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const HandheldChemDispenserSettings = (properties) => {
  const { act, data } = useBackend();
  const { amount, energy, maxEnergy, mode } = data;
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
          <LabeledList.Item label="Amount" verticalAlign="middle">
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
          <LabeledList.Item label="Mode" verticalAlign="middle">
            <Stack justify="space-between">
              <Button
                icon="cog"
                selected={mode === 'dispense'}
                content="Dispense"
                m="0"
                width="32%"
                onClick={() =>
                  act('mode', {
                    mode: 'dispense',
                  })
                }
              />
              <Button
                icon="cog"
                selected={mode === 'remove'}
                content="Remove"
                m="0"
                width="32%"
                onClick={() =>
                  act('mode', {
                    mode: 'remove',
                  })
                }
              />
              <Button
                icon="cog"
                selected={mode === 'isolate'}
                content="Isolate"
                m="0"
                width="32%"
                onClick={() =>
                  act('mode', {
                    mode: 'isolate',
                  })
                }
              />
            </Stack>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const HandheldChemDispenserChemicals = (properties) => {
  const { act, data } = useBackend();
  const { chemicals = [], current_reagent } = data;
  const flexFillers = [];
  for (let i = 0; i < (chemicals.length + 1) % 3; i++) {
    flexFillers.push(true);
  }
  return (
    <Stack.Item grow height="18%">
      <Section fill title={data.glass ? 'Drink Selector' : 'Chemical Selector'}>
        {chemicals.map((c, i) => (
          <Button
            key={i}
            width="32%"
            icon="arrow-circle-down"
            overflow="hidden"
            textOverflow="ellipsis"
            selected={current_reagent === c.id}
            content={c.title}
            style={{ marginLeft: '2px' }}
            onClick={() =>
              act('dispense', {
                reagent: c.id,
              })
            }
          />
        ))}
        {flexFillers.map((_, i) => (
          <Stack.Item key={i} grow="1" basis="25%" />
        ))}
      </Section>
    </Stack.Item>
  );
};

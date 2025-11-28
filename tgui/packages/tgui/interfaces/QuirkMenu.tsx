import { useState, useEffect } from 'react';
import { Box, Button, Divider, Icon, LabeledList, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Quirk = { name: string; cost: number; desc: string; path: string };
type Data = { selected_quirks: string[]; all_quirks: Quirk[] };

// Helper to calculate the balance for a given set of selected quirk names
const calculateBalance = (quirkNames: string[], allQuirks: Quirk[]): number => {
  const selectedSet = new Set(quirkNames);
  return allQuirks.reduce((sum, q) => {
    if (!selectedSet.has(q.name)) return sum;

    return sum + (q.cost < 0 ? Math.abs(q.cost) : -q.cost);
  }, 0);
};

export const QuirkMenu = () => {
  const { act, data } = useBackend<Data>();
  const [selected, setSelected] = useState(data.selected_quirks);

  useEffect(() => setSelected(data.selected_quirks), [data.selected_quirks]);

  const selectedSet = new Set(selected);

  // Calculate the current balance
  const balance = calculateBalance(selected, data.all_quirks);

  const canAfford = (q: Quirk) => q.cost <= 0 || balance >= q.cost;

  const toggle = (q: Quirk) => {
    const isChosen = selectedSet.has(q.name);

    if (isChosen) {
      const remainingQuirks = selected.filter((n) => n !== q.name);
      const remainingBalance = calculateBalance(remainingQuirks, data.all_quirks);

      if (q.cost < 0 && remainingBalance < 0) {
        return;
      }
    } else {
      // Logic for ADDING a quirk
      if (q.cost > 0 && !canAfford(q)) {
        return;
      }
    }

    setSelected(isChosen ? selected.filter((n) => n !== q.name) : [...selected, q.name]);
    act(isChosen ? 'remove_quirk' : 'add_quirk', { path: q.path });
  };

  const renderList = (quirks: Quirk[], title: string, color: string, icon: string) => (
    <>
      <Box
        p={0.5}
        mb={1}
        color={color}
        style={{
          border: `1px solid ${color}`,
          backgroundColor: `rgba(${color === 'green' ? '0,128,0' : '255,0,0'},0.1)`,
        }}
      >
        <Icon name={icon} /> {title}
      </Box>
      {quirks.map((q) => {
        const chosen = selectedSet.has(q.name);
        const cost = q.cost > 0 ? `-${q.cost}` : `+${Math.abs(q.cost)}`;
        const costColor = q.cost > 0 ? 'bad' : 'good';

        let disabled = false;
        let buttonContent = chosen ? 'Remove' : 'Select';
        let buttonColor = chosen ? 'bad' : 'good';

        if (!chosen) {
          if (q.cost > 0 && !canAfford(q)) {
            disabled = true;
            buttonContent = 'Locked';
            buttonColor = 'average';
          }
        } else {
          const remainingQuirks = selected.filter((n) => n !== q.name);
          const remainingBalance = calculateBalance(remainingQuirks, data.all_quirks);
          if (q.cost < 0 && remainingBalance < 0) {
            disabled = true;
            buttonContent = 'Locked (Balance)';
            buttonColor = 'average';
          }
        }

        return (
          <Section
            key={q.name}
            title={q.name}
            mb={1}
            buttons={
              <Button
                {...{ color: buttonColor, content: buttonContent }}
                disabled={disabled}
                onClick={() => toggle(q)}
                fluid
              />
            }
          >
            <LabeledList>
              <LabeledList.Item label="Description">{q.desc}</LabeledList.Item>
              <LabeledList.Item label="Effect">
                <Box color={costColor} bold>
                  {cost}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        );
      })}
    </>
  );

  return (
    <Window width={750} height={550} theme="ntos">
      <Window.Content>
        <Stack fill>
          <Stack.Item grow basis={500}>
            <Section title="Available Quirks" fill scrollable>
              <Stack vertical>
                {renderList(
                  data.all_quirks.filter((q) => q.cost < 0),
                  'Negative Quirks (Add Points)',
                  'green',
                  'minus-circle'
                )}
                {renderList(
                  data.all_quirks.filter((q) => q.cost > 0),
                  'Positive Quirks (Cost Points)',
                  'bad',
                  'plus-circle'
                )}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Divider vertical />
          </Stack.Item>

          <Stack.Item basis={250}>
            <Stack vertical fill>
              <Section title="Balance">
                <Box bold color={balance >= 0 ? 'good' : 'bad'} fontSize="18px">
                  {balance}
                </Box>
              </Section>
              <Section title="Selected Quirks" fill scrollable>
                {selected.length ? (
                  selected.map((name) => {
                    const q = data.all_quirks.find((x) => x.name === name);
                    if (!q) return null;
                    const cost = q.cost > 0 ? `-${q.cost}` : `+${Math.abs(q.cost)}`;
                    const border = q.cost > 0 ? 'var(--color-bad)' : 'var(--color-good)';
                    return (
                      <Box key={name} mb={0.5} p={0.5} style={{ borderLeft: `3px solid ${border}` }}>
                        <Stack justify="space-between">
                          <Box bold>{name}</Box>
                          <Box>{cost}</Box>
                        </Stack>
                      </Box>
                    );
                  })
                ) : (
                  <Box italic>No quirks selected.</Box>
                )}
              </Section>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

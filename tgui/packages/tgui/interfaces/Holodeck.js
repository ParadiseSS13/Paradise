import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';
import { LabeledListItem } from '../components/LabeledList';

export const Holodeck = (props, context) => {
  const { act, data } = useBackend(context);

  const { decks, current_deck, ai_override, emagged } = data;

  return (
    <Window width={400} height={320} resizable>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Holodeck Control System">
              <Box>
                <b>Currently Loaded Program:</b> {current_deck}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Available Programs">
              {decks.map((deck) => (
                <Button
                  key={deck}
                  width={15.5}
                  color="transparent"
                  content={deck}
                  selected={deck === current_deck}
                  onClick={() =>
                    act('select_deck', {
                      deck: deck,
                    })
                  }
                />
              ))}
              <hr />
              <LabeledList>
                {Boolean(ai_override) && (
                  <LabeledListItem label="Override Protocols">
                    <Button
                      content={emagged ? 'Turn On' : 'Turn Off'}
                      color={emagged ? 'good' : 'bad'}
                      onClick={() => act('ai_override')}
                    />
                  </LabeledListItem>
                )}
                <LabeledListItem label="Safety Protocols">
                  <Box color={emagged ? 'bad' : 'good'}>
                    {emagged ? 'Off' : 'On'}
                    {Boolean(emagged) && (
                      <Button
                        ml={9.5}
                        width={15.5}
                        color="red"
                        content="Wildlife Simulation"
                        onClick={() => act('wildlifecarp')}
                      />
                    )}
                  </Box>
                </LabeledListItem>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

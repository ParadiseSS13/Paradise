import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section, Stack, Dimmer, Icon } from '../components';
import { Window } from '../layouts';

export const Holodeck = (props, context) => {
  const { act, data } = useBackend(context);
  const [currentDeck, setCurrentDeck] = useLocalState(context, 'currentDeck', '');
  const [showReload, setShowReload] = useLocalState(context, 'showReload', false);
  const { decks, ai_override, emagged } = data;

  const handleSelectDeck = (deck) => {
    act('select_deck', {
      deck: deck,
    });
    setCurrentDeck(deck);
    setShowReload(true);
    setTimeout(() => {
      setShowReload(false);
    }, 3000);
  };

  return (
    <Window width={400} height={320}>
      {showReload && <HolodeckReload />}
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Holodeck Control System">
              <Box>
                <b>Currently Loaded Program:</b> {currentDeck}
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
                  selected={deck === currentDeck}
                  onClick={() => handleSelectDeck(deck)}
                />
              ))}
              <hr color="gray" />
              <LabeledList>
                {Boolean(ai_override) && (
                  <LabeledList.Item label="Override Protocols">
                    <Button
                      content={emagged ? 'Turn On' : 'Turn Off'}
                      color={emagged ? 'good' : 'bad'}
                      onClick={() => act('ai_override')}
                    />
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Safety Protocols">
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
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const HolodeckReload = (props, context) => {
  return (
    <Dimmer textAlign="center">
      <Icon name="spinner" size="5" spin />
      <br />
      <br />
      <Box color="white">
        <h1>&nbsp;Recalibrating projection apparatus.&nbsp;</h1>
      </Box>
      <Box color="label">
        <h3>Please, wait for 3 seconds.</h3>
      </Box>
    </Dimmer>
  );
};

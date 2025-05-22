import { useState } from 'react';
import { Box, Button, Dimmer, Icon, LabeledList, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type HolodeckData = {
  emagged: BooleanLike;
  ai_override: BooleanLike;
  decks: string[];
};

export const Holodeck = (props) => {
  const { act, data } = useBackend<HolodeckData>();
  const [currentDeck, setCurrentDeck] = useState('');
  const [showReload, setShowReload] = useState(false);
  const { decks, ai_override, emagged } = data;

  const handleSelectDeck = (deck: string) => {
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
    <Window width={420} height={320}>
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

const HolodeckReload = (props) => {
  return (
    <Dimmer textAlign="center">
      <Icon name="spinner" size={5} spin />
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

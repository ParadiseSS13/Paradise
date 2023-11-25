import { useBackend, useLocalState } from '../backend';
import { Fragment } from 'inferno';
import { Box, Button, Icon, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { LabeledListItem } from '../components/LabeledList';

export const Holodeck = (props, context) => {
  const { act, data } = useBackend(context);

  const { decks, current_deck, ai_override, emagged } = data;

  return (
    <Window resizable>
      <Window.Content>
        <Section title="Holodeck Control System">
          <Box>
            <b>Currently Loaded Program:</b> {current_deck}
          </Box>
        </Section>
        <Section title="Available Programs">
          {decks.map((deck) => (
            <Button
              key={deck}
              block
              content={deck}
              selected={deck === current_deck}
              onClick={() =>
                act('select_deck', {
                  deck: deck,
                })
              }
            />
          ))}
          {Boolean(emagged) && (
            <Button
              content="Wildlife Simulation"
              color="red"
              onClick={() => act('wildlifecarp')}
            />
          )}
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
              </Box>
            </LabeledListItem>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

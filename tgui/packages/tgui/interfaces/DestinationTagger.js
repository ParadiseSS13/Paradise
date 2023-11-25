import { useBackend } from '../backend';
import { Button, Section, Box, Flex } from '../components';
import { LabeledListItem } from '../components/LabeledList';
import { Window } from '../layouts';

export const DestinationTagger = (props, context) => {
  const { act, data } = useBackend(context);
  const { destinations, selected_destination_id } = data;

  let selected_destination = destinations[selected_destination_id - 1];

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="TagMaster 3.0">
          <LabeledListItem>
            <LabeledListItem label="Selected">
              {selected_destination.name ?? 'None'}
            </LabeledListItem>
          </LabeledListItem>
          <br />
          <Box>
            <Flex
              overflowY="auto"
              wrap="wrap"
              align="center"
              justify="space-evenly"
              direction="row"
            >
              {destinations.map((destination, index) => (
                <Flex.Item key={index} m="2px">
                  <Button
                    width="115px"
                    textAlign="center"
                    content={destination.name}
                    selected={destination.id === selected_destination_id}
                    onClick={() =>
                      act('select_destination', {
                        destination: destination.id,
                      })
                    }
                  />
                </Flex.Item>
              ))}
            </Flex>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

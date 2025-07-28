import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const DestinationTagger = (props) => {
  const { act, data } = useBackend();
  const { destinations, selected_destination_id } = data;

  let selected_destination = destinations[selected_destination_id - 1];

  return (
    <Window width={355} height={330}>
      <Window.Content>
        <Stack fill vertical>
          <Section fill scrollable textAlign="center" title="TagMaster 3.1">
            <Box width="100%" textAlign="center">
              <Box color="label" inline>
                Selected:
              </Box>{' '}
              {selected_destination.name ?? 'None'}
            </Box>
            <Box mt={1.5}>
              <Stack overflowY="auto" wrap="wrap" align="center" justify="space-evenly" direction="row">
                {destinations.map((destination, index) => (
                  <Stack.Item key={index} m="2px">
                    <Button
                      color="transparent"
                      width="105px"
                      textAlign="center"
                      content={destination.name}
                      selected={destination.id === selected_destination_id}
                      onClick={() =>
                        act('select_destination', {
                          destination: destination.id,
                        })
                      }
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Box>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

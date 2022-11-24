import { useBackend } from "../backend";
import { Button, Section, Box, Flex, NoticeBox } from "../components";
import { Window } from "../layouts";

export const DestinationTagger = (_props, context) => {
  const { act, data } = useBackend(context);
  const { destinations, selected_destination_id } = data;

  let selected_destination = destinations[selected_destination_id - 1];

  return (
    <Window>
      <Window.Content scrollable>
        <Section
          title="TagMaster 3.0"
          textAlign="center">
          <NoticeBox
            textAlign="center"
            style={{ "font-style": "normal" }}>
            Destination: {selected_destination.name ?? "None"}
          </NoticeBox>
          <Box>
            <Flex
              style={{ "display": "flex", "flex-wrap": "wrap", "align-content": "flex-start", "justify-content": "center" }}>
              {destinations.map((destination, index) => (
                <Flex.Item key={index} m="2px">
                  <Button
                    width="118px"
                    textAlign="center"
                    content={destination.name}
                    selected={destination.id === selected_destination_id}
                    onClick={() =>
                      act("select_destination", {
                        destination: destination.id,
                      })}
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

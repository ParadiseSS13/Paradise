import { useBackend } from "../../backend";
import { Box, Button, LabeledList, Section } from "../../components";

export const DeconstructionMenu = (properties, context) => {
  const { data, act } = useBackend(context);

  const {
    loaded_item,
    linked_destroy,
    nodes_to_boost,
  } = data;

  if (!linked_destroy) {
    return (
      <Box>
        NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE
      </Box>
    );
  }

  if (!loaded_item) {
    return (
      <Section title="Deconstruction Menu">
        No item loaded. Standing by...
      </Section>
    );
  }

  return (
    <Section noTopPadding title="Deconstruction Menu">
      <Button
        content="Eject Item"
        mt={1}
        icon="eject"
        onClick={() => {
          act('eject_item');
        }} />
      <Box mt={1}>
        Name: {loaded_item.name}
      </Box>
      <Box mt="10px">
        This item can boost the following nodes:
        {nodes_to_boost.map(n => (
          <Box key={n.name}>
            <Box m={1}>
              <Button
                content={n.name + " (" + n.worth + ")"}
                icon="unlink"
                disabled={!n.boosted}
                onClick={() => {
                  act('deconstruct', { id: n.id });
                }} />
            </Box>
          </Box>
        ))}
      </Box>
    </Section>
  );
};

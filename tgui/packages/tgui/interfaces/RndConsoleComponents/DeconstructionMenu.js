import { useBackend } from "../../backend";
import { Box, Button, LabeledList, Section } from "../../components";

export const DeconstructionMenu = (properties, context) => {
  const { data, act } = useBackend(context);

  const {
    loaded_item,
    linked_destroy,
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
      <Box mt="10px">Name: {loaded_item.name}</Box>
      <Box mt="10px">
        <h3>Origin Tech:</h3>
      </Box>
      <LabeledList>
        {loaded_item.origin_tech.map(item => {
          return (
            <LabeledList.Item label={"* " + item.name} key={item.name}>
              {item.object_level}
              {" "}
              {item.current_level ? (
                <>(Current: {item.current_level})</>
              ) : null}
            </LabeledList.Item>
          );
        })}

      </LabeledList>
      <Box mt="10px">
        <h3>Options:</h3>
      </Box>
      <Button
        content="Deconstruct Item"
        icon="unlink"
        onClick={() => {
          act('deconstruct');
        }} />
      <Button
        content="Eject Item"
        icon="eject"
        onClick={() => {
          act('eject_item');
        }} />
    </Section>
  );
};

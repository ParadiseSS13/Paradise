import { useBackend } from "../../backend";
import { Box, Button, Section } from "../../components";

export const pda_notes = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    note,
  } = data;

  return (
    <Box>
      <Section>
        {note}
      </Section>
      <Button
        icon="pen"
        onClick={() => act("Edit")}
        content="Edit" />
    </Box>
  );
};

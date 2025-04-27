import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const pda_notes = (props) => {
  const { act, data } = useBackend();

  const { note } = data;

  return (
    <Box>
      <Section>{note}</Section>
      <Button icon="pen" onClick={() => act('Edit')} content="Edit" />
    </Box>
  );
};

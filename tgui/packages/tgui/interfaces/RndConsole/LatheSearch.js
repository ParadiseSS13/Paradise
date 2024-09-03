import { useBackend } from '../../backend';
import { Box, Input } from '../../components';

export const LatheSearch = (properties, context) => {
  const { act } = useBackend(context);
  return (
    <Box>
      <Input placeholder="Search..." onEnter={(e, value) => act('search', { to_search: value })} />
    </Box>
  );
};

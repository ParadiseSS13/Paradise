import { useBackend } from '../../backend';
import { Box, Input } from '../../components';

export const LatheSearch = (properties) => {
  const { act } = useBackend();
  return (
    <Box>
      <Input placeholder="Search..." onEnter={(e, value) => act('search', { to_search: value })} />
    </Box>
  );
};

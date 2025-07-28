import { Box, Input } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const LatheSearch = (properties) => {
  const { act } = useBackend();
  return (
    <Box>
      <Input placeholder="Search..." onEnter={(value) => act('search', { to_search: value })} />
    </Box>
  );
};

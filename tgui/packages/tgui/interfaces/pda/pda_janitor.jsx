import { Box, LabeledList } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const pda_janitor = (props) => {
  const { act, data } = useBackend();
  const { janitor } = data;

  const { user_loc, mops, buckets, cleanbots, carts, janicarts } = janitor;

  return (
    <LabeledList>
      <LabeledList.Item label="Current Location">
        {user_loc.x},{user_loc.y}
      </LabeledList.Item>
      {mops && (
        <LabeledList.Item label="Mop Locations">
          {mops.map((m) => (
            <Box key={m}>
              {m.x},{m.y} ({m.dir}) - {m.status}
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {buckets && (
        <LabeledList.Item label="Mop Bucket Locations">
          {buckets.map((b) => (
            <Box key={b}>
              {b.x},{b.y} ({b.dir}) - [{b.volume}/{b.max_volume}]
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {cleanbots && (
        <LabeledList.Item label="Cleanbot Locations">
          {cleanbots.map((c) => (
            <Box key={c}>
              {c.x},{c.y} ({c.dir}) - {c.status}
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {carts && (
        <LabeledList.Item label="Janitorial Cart Locations">
          {carts.map((c) => (
            <Box key={c}>
              {c.x},{c.y} ({c.dir}) - [{c.volume}/{c.max_volume}]
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {janicarts && (
        <LabeledList.Item label="Janicart Locations">
          {janicarts.map((janicart) => (
            <Box key={janicart}>
              {janicart.x},{janicart.y} ({janicart.direction_from_user})
            </Box>
          ))}
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};

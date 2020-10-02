import { useBackend } from "../../backend";
import { LabeledList, Box } from "../../components";

export const pda_janitor = (props, context) => {
  const { act, data } = useBackend(context);
  const { janitor } = data;

  const {
    user_loc,
    mops,
    buckets,
    cleanbots,
    carts,
  } = janitor;

  return (
    <LabeledList>
      <LabeledList.Item label="Current Location">
        {user_loc.x},{user_loc.y}
      </LabeledList.Item>
      {mops && (
        <LabeledList.Item label="Mop Locations">
          {mops.map(m => (
            <Box key={m}>
              {m.x},{m.y} ({m.dir}) - {m.status}
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {buckets && (
        <LabeledList.Item label="Mop Bucket Locations">
          {buckets.map(b => (
            <Box key={b}>
              {b.x},{b.y} ({b.dir}) - [{b.volume}/{b.max_volume}]
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {cleanbots && (
        <LabeledList.Item label="Cleanbot Locations">
          {cleanbots.map(c => (
            <Box key={c}>
              {c.x},{c.y} ({c.dir}) - {c.status}
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {carts && (
        <LabeledList.Item label="Janitorial Cart Locations">
          {carts.map(c => (
            <Box key={c}>
              {c.x},{c.y} ({c.dir}) - [{c.volume}/{c.max_volume}]
            </Box>
          ))}
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};

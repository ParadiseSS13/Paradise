import { Box, LabeledList, ProgressBar } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const pai_bioscan = (props) => {
  const { act, data } = useBackend();
  const { holder, dead, health, brute, oxy, tox, burn, temp } = data.app_data;

  if (!holder) {
    return <Box color="red">Error: No biological host found.</Box>;
  }
  return (
    <LabeledList>
      <LabeledList.Item label="Status">
        {dead ? (
          <Box bold color="red">
            Dead
          </Box>
        ) : (
          <Box bold color="green">
            Alive
          </Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item label="Health">
        <ProgressBar
          min={0}
          max={1}
          value={health / 100}
          ranges={{
            good: [0.5, Infinity],
            average: [0, 0.5],
            bad: [-Infinity, 0],
          }}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Oxygen Damage">
        <Box color="blue">{oxy}</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Toxin Damage">
        <Box color="green">{tox}</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Burn Damage">
        <Box color="orange">{burn}</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Brute Damage">
        <Box color="red">{brute}</Box>
      </LabeledList.Item>
    </LabeledList>
  );
};

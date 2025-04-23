/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useState } from 'react';
import { Box, Button, ProgressBar, Section } from '../components';

export const meta = {
  title: 'ProgressBar',
  render: () => <Story />,
};

const Story = (props) => {
  const [progress, setProgress] = useState(0.5);
  return (
    <Section>
      <ProgressBar
        ranges={{
          good: [0.5, Infinity],
          bad: [-Infinity, 0.1],
          average: [0, 0.5],
        }}
        minValue={-1}
        maxValue={1}
        value={progress}
      >
        Value: {Number(progress).toFixed(1)}
      </ProgressBar>
      <Box mt={1}>
        <Button content="-0.1" onClick={() => setProgress(progress - 0.1)} />
        <Button content="+0.1" onClick={() => setProgress(progress + 0.1)} />
      </Box>
    </Section>
  );
};

import { type ReactNode, useEffect, useRef, useState } from 'react';
import { Box, ProgressBar, Stack } from 'tgui-core/components';

type Props = {
  timeEnd: number;
} & Partial<{
  children: ReactNode;
  timeStart: number;
  progressBar: true;
  format: (value, formatted) => string;
}>;

export function Countdown(props: Props) {
  const { children, progressBar, timeStart, timeEnd, format, ...rest } = props;
  const countdownMax = Math.max((timeStart ? timeEnd - timeStart : timeEnd) * 100, 0);

  const [value, setValue] = useState(countdownMax);
  const timer = useRef<NodeJS.Timeout | null>(null);
  const tickRate = 1000;

  function tick() {
    setValue((oldValue) => {
      const newValue = Math.max(oldValue - tickRate, 0);
      if (newValue <= 0) {
        clearInterval(timer.current as NodeJS.Timeout);
      }

      return newValue;
    });
  }

  useEffect(() => {
    if (!timer.current) {
      timer.current = setInterval(tick, tickRate);
    }

    return () => clearInterval(timer.current as NodeJS.Timeout);
  }, []);

  const formatted = new Date(value).toISOString().slice(11, 19);
  let time = (
    <Box as="span" {...rest}>
      {format ? format(value, formatted) : formatted}
    </Box>
  );

  if (progressBar) {
    time = (
      <ProgressBar className="Countdown__progressBar" minValue={0} value={countdownMax - value} maxValue={countdownMax}>
        <Stack width="100%" textAlign="left">
          <Stack.Item grow>{children}</Stack.Item>
          <Stack.Item>({time})</Stack.Item>
        </Stack>
      </ProgressBar>
    );
  }

  return time;
}

// see seconds_to_clock
const secondsToClock = totalSeconds => {
  if (!totalSeconds || totalSeconds < 0) { totalSeconds = 0; }

  let minutes = Math.floor(totalSeconds / 60).toString(10);
  let seconds = (Math.floor(totalSeconds) % 60).toString(10);

  return [minutes, seconds].map(p => p.length < 2 ? '0' + p : p).join(':');
};

export const TimeDisplay = ({ totalSeconds = 0 }) => (
  secondsToClock(totalSeconds)
);

import { useEffect, useState } from 'react';
import { Transition } from 'react-transition-group';
import styled from 'styled-components';
import { animationDurationMs } from '~/common/animations';

interface OccurenceCounterProps {
  num: number;
}

const OccurenceCounterWrapper = styled.span<{ entering: boolean }>`
  height: 1em;
  border-radius: 32px;
  margin-left: 0.5em;
  padding: 2px 4px;
  display: inline-block;
  background-color: ${({ entering, theme }) =>
    entering ? theme.accent.primary : theme.background[3]};
  font-weight: bold;
  font-size: 75%;
  text-align: center;
  transition: ${animationDurationMs}ms;
`;

export const OccurenceCounter = ({ num }: OccurenceCounterProps) => {
  const [shouldBlink, setShouldBlink] = useState(false);

  useEffect(() => {
    setShouldBlink(true);
  }, [num]);

  return (
    <Transition
      in={shouldBlink}
      timeout={{ enter: animationDurationMs, exit: 0 }}
      onEntered={() => setShouldBlink(false)}
    >
      {state => (
        <OccurenceCounterWrapper entering={state === 'entering'}>
          x{num}
        </OccurenceCounterWrapper>
      )}
    </Transition>
  );
};

import { useEffect } from 'react';
import styled from 'styled-components';
import { initiatePing } from '~/byondcalls/ehjax';
import { useHeaderSlice } from '~/stores/header';

const PingWrapper = styled.span`
  color: ${({ theme }) => theme.success};
  padding: 0 9px;

  &.ping-good {
    color: ${({ theme }) => theme.success};
  }
  &.ping-medium {
    color: ${({ theme }) => theme.warning};
  }
  &.ping-bad {
    color: ${({ theme }) => theme.warning2};
  }
  &.ping-verybad {
    color: ${({ theme }) => theme.error};
  }
`;

const Ping = () => {
  const ping = useHeaderSlice(state => Math.min(999, state.ping));

  useEffect(() => {
    initiatePing();
  }, []);

  if (ping === 0) {
    return null;
  }

  let pingClass = 'verybad';
  if (ping <= 100) pingClass = 'good';
  else if (ping <= 150) pingClass = 'medium';
  else if (ping <= 200) pingClass = 'bad';

  return <PingWrapper className={'ping-' + pingClass}>• {ping} ms</PingWrapper>;
};

export default Ping;

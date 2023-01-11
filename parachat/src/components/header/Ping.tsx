import { useEffect } from 'react';
import styled from 'styled-components';
import { useHeaderSlice } from '~/common/store';

const PingWrapper = styled.div`
  padding: 6px 9px;
  color: #8f8;

  &.ping-good {
    color: #8f8;
  }
  &.ping-medium {
    color: #ff8;
  }
  &.ping-bad {
    color: #fa8;
  }
  &.ping-verybad {
    color: #f66;
  }
`;

const Ping = () => {
  const ping = useHeaderSlice(state => Math.min(999, state.ping));

  useEffect(() => {
    // const pingInterval = setInterval(() => {
    // 	window.initiatePing();
    // }, 1000);
    // return () => clearInterval(pingInterval);
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

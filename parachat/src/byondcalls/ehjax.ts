import { ByondCall } from '~/common/types';
import { useHeaderSlice } from '~/stores/header';

let pingStart = 0;

export const ehjaxCallback: ByondCall = topic => {
  if (topic === 'pang') {
    initiatePing();
  } else if (topic === 'pong') {
    const ping = Math.ceil((Date.now() - pingStart) / 2);
    useHeaderSlice.setState({ ping });
  }
};

export const initiatePing = () => {
  pingStart = Date.now();
  window.location.href = '?_src_=chat&proc=ping';
};

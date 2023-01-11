import { addMessage, useMessageSlice } from '~/common/store';
import { ByondCall, MessageType } from '~/common/types';

export const reboot: ByondCall = topic => {
  const autoReconnectSeconds = parseInt(topic) || 10;
  addMessage({
    text: 'Server rebooting!',
    type: MessageType.REBOOT,
    params: { timeout: autoReconnectSeconds },
  });
};

export const rebootFinished: ByondCall = () => {
  useMessageSlice.getState().rebootCompleted();
};

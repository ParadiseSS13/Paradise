import { ByondCall, MessageType } from '~/common/types';
import { addMessage, useMessageSlice } from '~/stores/message';

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

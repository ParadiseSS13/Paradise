import { useAdminSlice } from '~/common/store';
import { ByondCall } from '~/common/types';

export const playAudio: ByondCall = topic => {
  useAdminSlice.getState().setCurrentAudio(topic);
};

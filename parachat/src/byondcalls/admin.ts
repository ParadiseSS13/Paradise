import { ByondCall } from '~/common/types';
import { useAdminSlice } from '~/stores/admin';

export const playAudio: ByondCall = topic => {
  useAdminSlice.getState().setCurrentAudio(topic);
};

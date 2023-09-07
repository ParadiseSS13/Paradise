import { useAdminSlice } from '~/stores/admin';

export const playAudio = (
  uid: string,
  sender: string,
  file: string,
  volume: number
) => {
  useAdminSlice.getState().setAudio(uid, sender, file, volume);
};

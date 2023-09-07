import create from 'zustand';

interface AdminSlice {
  audioUid: string;
  audioSender: string;
  audioFile: string;
  audioVolume: number;
  setAudio: (uid: string, sender: string, file: string, volume: number) => void;
  clearAudio: () => void;
}

export const useAdminSlice = create<AdminSlice>()(set => ({
  audioUid: '',
  audioSender: '',
  audioFile: '',
  audioVolume: 0,
  setAudio: (uid, sender, file, volume) =>
    set(() => ({
      audioUid: uid,
      audioSender: sender,
      audioFile: file,
      audioVolume: volume,
    })),
  clearAudio: () => set(() => ({ audioSender: '', audioFile: '' })),
}));

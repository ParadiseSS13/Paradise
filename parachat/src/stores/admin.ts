import create from 'zustand';

interface AdminSlice {
  currentAudio: string;
  setCurrentAudio: (currentAudio: string) => void;
}

export const useAdminSlice = create<AdminSlice>()(set => ({
  currentAudio: '',
  setCurrentAudio: currentAudio => set(() => ({ currentAudio: currentAudio })),
}));

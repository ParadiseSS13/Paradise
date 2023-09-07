import { useState } from 'react';
import { Transition } from 'react-transition-group';
import styled from 'styled-components';
import { animationDurationMs } from '~/common/animations';
import { useAdminSlice } from '~/stores/admin';

const AudioWrapper = styled.div`
  height: 2em;
  background: ${({ theme }) => theme.accent[0]};
  overflow: hidden;
  position: relative;
`;

const TextWrapper = styled.span`
  top: -2em;
  left: 0px;
  height: 2em;
  padding: 0 8px;
  display: flex;
  line-height: 2em;
  position: relative;
  z-index: 500;

  & > span {
    flex: 1;
  }

  & > a {
    margin-left: 8px;
    color: ${({ theme }) => theme.textSecondary};
    font-weight: bold;
    transition-duration: ${animationDurationMs}ms;

    &:hover {
      color: ${({ theme }) => theme.textPrimary};
    }
  }
`;

const Progress = styled.div<{ duration: number; enter: boolean }>`
  width: 100%;
  height: 100%;
  background: ${({ theme }) => theme.accent.primary};
  color: transparent;
  transform: ${({ enter }) => (enter ? 'translateX(0)' : 'translateX(-100%)')};
  transition: transform ${({ duration }) => duration}ms linear;
`;

const Audio = () => {
  const audioUid = useAdminSlice(state => state.audioUid);
  const audioSender = useAdminSlice(state => state.audioSender);
  const audioFile = useAdminSlice(state => state.audioFile);
  const audioVolume = useAdminSlice(state => state.audioVolume);
  const clearAudio = useAdminSlice(state => state.clearAudio);
  const [duration, setDuration] = useState(0);

  if (!audioFile) {
    return null;
  }

  return (
    <>
      <audio
        src={'./' + audioFile}
        onLoadStart={() => setDuration(0)}
        onPlay={e => {
          const audio = e.target as HTMLAudioElement;
          audio.volume = audioVolume / 100;
          setDuration(audio.duration * 1000);
        }}
        onEnded={() => {
          setDuration(0);
          clearAudio();
        }}
        autoPlay
      />
      <Transition in={duration > 0} timeout={duration} appear>
        {state => (
          <AudioWrapper>
            <Progress
              duration={duration}
              enter={state === 'entering' || state === 'entered'}
            >
              {state}
            </Progress>
            <TextWrapper>
              <span>
                Playing <code>{audioFile}</code> from {audioSender}
              </span>
              <a href="#" onClick={clearAudio}>
                Stop
              </a>
              <a
                href="#"
                onClick={() => {
                  clearAudio();
                  location.href = `?_src_=${audioUid}&action=muteAdmin&a=${encodeURIComponent(
                    audioSender
                  )}`;
                }}
              >
                Stop and mute this admin
              </a>
            </TextWrapper>
          </AudioWrapper>
        )}
      </Transition>
    </>
  );
};

export default Audio;

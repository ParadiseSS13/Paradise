import { useEffect, useState } from 'react';
import { Transition } from 'react-transition-group';
import styled from 'styled-components';
import { useAdminSlice } from '~/stores/admin';

const AudioWrapper = styled.div`
  background: ${props => props.theme.accent[0]};
  font-weight: bold;
  height: 2em;
  position: relative;
  overflow: hidden;
`;

const Progress = styled.div`
  width: 100%;
  height: 100%;
  background: ${props => props.theme.accent.primary};
`;

const fillProgress = {
  entering: { transform: 'translateX(0)' },
  entered: { transform: 'translateX(0)' },
  exiting: { transform: 'translateX(-100%)' },
  exited: { transform: 'translateX(-100%)' },
};

const Audio = () => {
  const currentAudio = useAdminSlice(state => state.currentAudio);
  const setCurrentAudio = useAdminSlice(state => state.setCurrentAudio);
  const [duration, setDuration] = useState(0);

  useEffect(() => {
    if (!currentAudio) {
      return;
    }
    const audioElement = document.createElement('audio');
    audioElement.src = './' + currentAudio;
    audioElement.addEventListener('ended', () => setCurrentAudio(''));
    audioElement.play();

    setDuration(3000);
    setTimeout(() => setCurrentAudio(''), 3000);
  }, [currentAudio]);

  if (!currentAudio) {
    return null;
  }

  return (
    <Transition in timeout={duration} appear>
      {state => (
        <AudioWrapper>
          <Progress
            style={{
              color: 'transparent',
              transition: `transform ${duration}ms linear`,
              transform: 'translateX(-100%)',
              ...fillProgress[state],
            }}
          >
            {state}
          </Progress>
          <span
            style={{
              position: 'absolute',
              top: '0.5em',
              left: 8,
              zIndex: 500,
            }}
          >
            Playing {currentAudio}
          </span>
        </AudioWrapper>
      )}
    </Transition>
  );
};

export default Audio;

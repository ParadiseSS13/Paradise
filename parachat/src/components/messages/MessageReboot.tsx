import PropTypes from 'prop-types';
import { useEffect, useState } from 'react';
import { Transition } from 'react-transition-group';
import styled from 'styled-components';

const MessageRebootWrapper = styled.div`
  position: relative;
  padding: 6px 0;
  padding-left: 9px;
  margin-left: -9px;
  line-height: ${props => props.theme.lineHeight};
  background-color: ${props => props.theme.accent[3]};
`;

const Progress = styled.div`
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  background-color: ${props => props.theme.accent[4]};
`;

const Text = styled.span`
  z-index: 1;
  position: relative;

  a {
    color: inherit;
    font-weight: bold;
  }
`;

const progressFill = {
  entering: { transform: 'translateX(0)' },
  entered: { transform: 'translateX(0)' },
  exiting: { transform: 'translateX(-100%)' },
  exited: { transform: 'translateX(-100%)' },
};

const MessageReboot = ({ message }) => {
  const [secondsRemaining, setSecondsRemaining] = useState(
    message.params.timeout
  );

  useEffect(() => {
    const interval = setInterval(() => {
      setSecondsRemaining(s => Math.max(0, s - 1));
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (message.params.completed) {
      return;
    }

    const timeout = setTimeout(() => {
      window.location.href = 'byond://winset?command=.reconnect';
    }, message.params.timeout * 1000);
    return () => clearTimeout(timeout);
  }, [message.params]);

  return (
    <Transition timeout={message.params.timeout * 1000} in appear>
      {state => (
        <MessageRebootWrapper>
          <Progress
            style={
              !message.params.completed
                ? {
                    transition:
                      'transform ' +
                      message.params.timeout * 1000 +
                      'ms linear',
                    transform: 'translateX(-100%)',
                    ...progressFill[state],
                  }
                : {}
            }
          />
          <Text>
            {message.params.completed ? (
              'Reconnected automatically!'
            ) : (
              <span>
                Server is restarting!&nbsp;
                <a href="#">
                  Reconnect{' '}
                  {secondsRemaining > 0 ? '(' + secondsRemaining + ')' : ''}
                </a>
              </span>
            )}
          </Text>
        </MessageRebootWrapper>
      )}
    </Transition>
  );
};

MessageReboot.propTypes = {
  message: PropTypes.shape({
    id: PropTypes.number.isRequired,
    params: PropTypes.shape({
      timeout: PropTypes.number,
      completed: PropTypes.bool,
    }),
  }),
};

export default MessageReboot;

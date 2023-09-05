import { Transition } from 'react-transition-group';
import styled, { css } from 'styled-components';
import { animationDurationMs } from '~/common/animations';
import { MessageInfo } from '~/common/types';
import { OccurenceCounter } from './OccurenceCounter';

interface MessageProps {
  message: MessageInfo;
  show: boolean;
}

export const MessageWrapper = styled.div<{
  highlightColor: [number, number, number];
}>`
  display: block;
  padding: 3px 0 3px 9px;
  line-height: ${props => props.theme.lineHeight};

  ${props => props.theme.cssTheme}

  ${props =>
    props.highlightColor &&
    css`
      &.highlight-line {
        padding-left: 7px;
        border-left: 2px solid
          rgba(
            ${props.highlightColor[0]},
            ${props.highlightColor[1]},
            ${props.highlightColor[2]},
            1
          );
        background-color: rgba(
          ${props.highlightColor[0]},
          ${props.highlightColor[1]},
          ${props.highlightColor[2]},
          0.1
        );
      }

      .highlight-simple {
        display: inline-block;
      }
    `}
`;

const hexToRgb = hex =>
  hex
    .replace(
      /^#?([a-f\d])([a-f\d])([a-f\d])$/i,
      (m, r, g, b) => '#' + r + r + g + g + b + b
    )
    .substring(1)
    .match(/.{2}/g)
    .map(x => parseInt(x, 16));

export const addHighlight = highlight => {
  if (!highlight || !highlight.color) {
    return;
  }

  return {
    className: 'highlight-line',
    highlightColor: hexToRgb(highlight.color),
  };
};

const MessageAnimationWrapper = styled.div<{ enter: boolean }>`
  opacity: ${({ enter }) => (enter ? '1' : '0')};
  transform: ${({ enter }) => (enter ? 'translateX(0)' : 'translateX(10px)')};
  transition: ${animationDurationMs}ms;
`;

const Message: React.FC<MessageProps> = ({ message, show }) => {
  return (
    <Transition timeout={animationDurationMs} appear in>
      {state =>
        show ? (
          <MessageWrapper {...addHighlight(message.highlight)}>
            <MessageAnimationWrapper
              enter={state === 'entering' || state === 'entered'}
            >
              <span dangerouslySetInnerHTML={{ __html: message.text }} />
              {message.occurences > 1 && (
                <OccurenceCounter num={message.occurences} />
              )}
            </MessageAnimationWrapper>
          </MessageWrapper>
        ) : null
      }
    </Transition>
  );
};

export default Message;

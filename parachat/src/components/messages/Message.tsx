import PropTypes from 'prop-types';
import { Transition } from 'react-transition-group';
import styled, { css } from 'styled-components';
import { animationDurationMs } from '~/common/animations';

export const MessageWrapper = styled.div`
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

const slideIn = {
  entering: { opacity: 1, transform: 'translateX(0)' },
  entered: { opacity: 1, transform: 'translateX(0)' },
  exiting: { opacity: 0, transform: 'translateX(10px)' },
  exited: { opacity: 0, transform: 'translateX(10px)' },
};

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

const Message = ({ message, show }) => {
  return (
    <Transition timeout={animationDurationMs} in appear>
      {state =>
        show ? (
          <MessageWrapper {...addHighlight(message.highlight)}>
            <div
              style={{
                transitionDuration: '0.2s',
                opacity: 0,
                transform: 'translateX(10px)',
                ...slideIn[state],
              }}
            >
              <span dangerouslySetInnerHTML={{ __html: message.text }} />
            </div>
          </MessageWrapper>
        ) : null
      }
    </Transition>
  );
};

Message.propTypes = {
  message: PropTypes.shape({
    id: PropTypes.number.isRequired,
    text: PropTypes.string,
    type: PropTypes.number,
    tab: PropTypes.number,
    params: PropTypes.object,
    highlight: PropTypes.object,
  }),
  show: PropTypes.bool,
};

export default Message;

import { useEffect, useRef, useState } from 'react';
import { Transition } from 'react-transition-group';
import styled from 'styled-components';
import { animationDurationMs, fadeIn } from '~/common/animations';
import { MessageInfo, MessageType, Tab } from '~/common/types';
import { useHeaderSlice } from '~/stores/header';
import { useMessageSlice } from '~/stores/message';
import Message from './messages/Message';
import MessageReboot from './messages/MessageReboot';

const MessageListWrapper = styled.div`
  flex: 1;
  background-color: ${props => props.theme.colors.bg[1]};
  overflow-y: auto;
  overflow-x: hidden;
`;

const ScrollToBottom = styled.a`
  position: absolute;
  bottom: 10px;
  right: 30px;
  padding: 8px;
  color: ${props => props.theme.colors.fg[0]};
  background-color: ${props => props.theme.colors.bg[3]};
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.5);
  font-weight: bold;
  text-decoration: none;
  border-radius: 4px;
  transition-duration: 0.2s;
  z-index: 100;
  ${fadeIn.initial}
`;

const getMessageComponent = ({ type }: MessageInfo) => {
  switch (type) {
    case MessageType.REBOOT:
      return MessageReboot;
    default:
      return Message;
  }
};

const shouldShowMessage = (selectedTab: Tab, { tab, type }: MessageInfo) => {
  if (selectedTab === Tab.ALL) {
    return true;
  }

  switch (type) {
    case MessageType.TEXT:
      return tab === Tab.ALL || selectedTab === tab;
    case MessageType.REBOOT:
      return true;
    default:
      return true;
  }
};

const MessageList = () => {
  const [showScrollToBottom, setShowScrollToBottom] = useState(false);
  const messages = useMessageSlice(state => state.messages);
  const selectedTab = useHeaderSlice(state => state.selectedTab);
  const refList = useRef(null);

  const scrollToBottom = () => {
    refList.current.scrollTop = refList.current.scrollHeight;
    setShowScrollToBottom(
      refList.current.scrollHeight > refList.current.clientHeight
    );
  };

  useEffect(() => {
    if (!messages.length) {
      return;
    }
    scrollToBottom();
  }, [messages, selectedTab]);

  return (
    <MessageListWrapper
      ref={refList}
      onScroll={e =>
        setShowScrollToBottom(
          e.target.scrollTop + e.target.clientHeight < e.target.scrollHeight
        )
      }
    >
      <Transition timeout={animationDurationMs} in={showScrollToBottom}>
        {state => (
          <ScrollToBottom
            href="#"
            onClick={scrollToBottom}
            style={{ ...fadeIn[state] }}
          >
            Scroll to bottom
          </ScrollToBottom>
        )}
      </Transition>
      {messages.map(message => {
        const MessageComponent = getMessageComponent(message);
        return (
          <MessageComponent
            key={message.id}
            message={message}
            show={shouldShowMessage(selectedTab, message)}
          />
        );
      })}
    </MessageListWrapper>
  );
};

export default MessageList;

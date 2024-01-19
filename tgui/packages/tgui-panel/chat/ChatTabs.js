/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useSelector } from 'common/redux';
import { Box, Tabs, Flex, Button } from 'tgui/components';
import { changeChatPage, addChatPage } from './actions';
import { selectChatPages, selectCurrentChatPage } from './selectors';
import { openChatSettings } from '../settings/actions';
import { useSettings } from 'tgui-panel/settings';

const UnreadCountWidget = ({ value }) => (
  <Box
    style={{
      'font-size': '0.7em',
      'border-radius': '0.25em',
      'width': '1.7em',
      'line-height': '1.55em',
      'background-color': 'crimson',
      'color': '#fff',
    }}
  >
    {Math.min(value, 99)}
  </Box>
);

export const ChatTabs = (props, context) => {
  const pages = useSelector(context, selectChatPages);
  const currentPage = useSelector(context, selectCurrentChatPage);
  const dispatch = useDispatch(context);
  const settings = useSettings(context);
  return (
    <Flex align="center">
      <Flex.Item>
        <Tabs textAlign="center">
          {pages.map((page) => (
            <Tabs.Tab
              key={page.id}
              selected={page === currentPage}
              rightSlot={
                page.unreadCount > 0 && (
                  <UnreadCountWidget value={page.unreadCount} />
                )
              }
              onClick={() => OpenSettingsOrSwapTab(page, currentPage, context)}
            >
              {page.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Flex.Item>
      <Flex.Item ml={1}>
        <Button
          color="transparent"
          icon="plus"
          onClick={() => {
            dispatch(addChatPage());
            dispatch(openChatSettings());
          }}
        />
      </Flex.Item>
    </Flex>
  );
};

// Handles switching to a new tab or closing/opening settings by just double clicking on the chat tab
const OpenSettingsOrSwapTab = (our_page, ourCurrentPage, our_context) => {
  const settings = useSettings(our_context);
  const dispatch = useDispatch(our_context);
  if (ourCurrentPage === our_page) {
    return settings.toggle();
  } else {
    return dispatch(changeChatPage({ pageId: our_page.id }));
  }
};

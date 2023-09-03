import { addMessage, useHeaderSlice } from '~/common/store';
import { ByondCall, Tab } from '~/common/types';

const tabMatch = /^pchat:(\w+):/;
export const output: ByondCall = topic => {
  let message = decodeURIComponent(topic.replace(/\+/g, '%20'));
  let matchedTab: string;
  const regexMatch = message.match(tabMatch);
  if (regexMatch) {
    message = message.slice(regexMatch[0].length);
    matchedTab = regexMatch[1];
  }

  const tab: Tab = Tab[matchedTab] ?? Tab.OTHER;
  addMessage({ text: message, tab });

  // Unread tab incrementation
  const headerState = useHeaderSlice.getState();
  const selectedTab = headerState.selectedTab;
  if (selectedTab === tab || selectedTab === Tab.ALL) {
    return;
  }

  headerState.incrementUnreadTab(tab);
};

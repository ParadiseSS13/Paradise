import styled from 'styled-components';
import { Tab } from '~/common/types';
import { useHeaderSlice } from '~/stores/header';
import TabButton from './TabButton';

const TabsWrapper = styled.div`
  flex: 1;
  display: flex;
  overflow: hidden;
`;

const tabs = [
  { tabName: 'All', tabId: Tab.ALL },
  { tabName: 'Local', tabId: Tab.LOCAL },
  { tabName: 'Radio', tabId: Tab.RADIO },
  { tabName: 'OOC', tabId: Tab.OOC },
  { tabName: 'Admin', tabId: Tab.ADMIN },
  { tabName: 'Other', tabId: Tab.OTHER },
];

const Tabs: React.FC = () => {
  const unreadTabs = useHeaderSlice(state => state.unreadTabs);
  const selectedTab = useHeaderSlice(state => state.selectedTab);
  const setSelectedTab = useHeaderSlice(state => state.setSelectedTab);
  const clearUnreadTab = useHeaderSlice(state => state.clearUnreadTab);
  const clearUnreadTabs = useHeaderSlice(state => state.clearUnreadTabs);

  const onTabClick = tabId => {
    if (selectedTab === tabId) {
      return;
    }

    setSelectedTab(tabId);
    if (tabId === Tab.ALL) {
      clearUnreadTabs();
    } else {
      clearUnreadTab(tabId);
    }
  };

  return (
    <TabsWrapper>
      {tabs.map(({ tabName, tabId }) => (
        <TabButton
          key={tabId}
          name={tabName}
          active={selectedTab === tabId}
          onTabClick={() => onTabClick(tabId)}
          unread={unreadTabs[tabId]}
        />
      ))}
    </TabsWrapper>
  );
};

export default Tabs;

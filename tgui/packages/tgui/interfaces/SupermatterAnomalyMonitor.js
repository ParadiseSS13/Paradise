import { Window } from '../layouts';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { sortBy } from 'common/collections';
import {
  Section,
  Box,
  Flex,
  Button,
  Table,
  LabeledList,
  ProgressBar,
  Tabs,
  Input,
  Icon,
} from '../components'
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import { FlexItem } from '../components/Flex';
import { complexModal, modalOpen } from './common/ComplexModal';
import { TemporaryNotice } from './common/TemporaryNotice';


export const SupermatterAnomalyMonitor = (properties, context) => {
  const { act, data } = useBackend(context);
  const { loginState, currentPage } = data;

  let body;
  if(!loginState.logged_in) {
    return (
      <Window resizable>
        <Window.Content>
          <LoginScreen />
        </Window.Content>
      </Window>
    );
  } else {
    if (currentPage === 1) {
      body = <SupermatterAnomalyPageView/>;
    } else if (currentPage ===2){
      body = <SupermatterAnomalyPageList />;
    }
  }

  return (
    <Window resizable>
      <complexModal />
      <Window.Content scrollable classname="Layout__content--flexcolumn">
        <LoginInfo />
        <TemporaryNotice />
        <SupermatterAnomalyNavigation />
        <Section height="100%" flexGrow="1">
          {body}
        </Section>
      </Window.Content>
    </Window>
  );
};

const SupermatterAnomalyNavigation = (properties, context) => {
  const { act, data } = useBackend(context);
  const { currentPage, } = data;
  return (
    <Tabs>
      <Tabs.Tab
        selected={currentPage === 1}
        onClick={() => act('page',{ page: 1})}
      >
       <Icon name="folder" />
        Current Event
      </Tabs.Tab>
      {currentPage === 2 (
        <Tabs.Tab selected={currentPage === 2}>
          <Icon name="list" />
           Event List
        </Tabs.Tab>
      )}
    </Tabs>
  );
};

const SupermatterAnomalyPageView = (properties, context) => {
  const { act, data } = useBackend(context);
  const {  } = data;

}

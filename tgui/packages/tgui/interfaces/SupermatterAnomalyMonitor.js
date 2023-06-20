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
      body = <SupermatterAnomalyPageList />;
    } else if (currentPage ===2){
      body = <SupermatterAnomalyPageView />;
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
  const { currentPage, general } = data;
  return (

  );
};

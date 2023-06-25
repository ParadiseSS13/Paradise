import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { TableCell } from '../components/Table';
import {
  Section,
  Icon,
  Button,
  Divider,
  Flex,
  LabeledList,
  Box,
  Tabs,
  Table,
} from '../components';
import { LabeledListItem } from '../components/LabeledList';

export const SupermatterAnomalyMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <SupermatterAnomalyView />;
      case 1:
        return <SupermatterAnomalyRecord />;
      default:
        return "ERROR!";
    }
  };

  return (
    <Window resizable>
      <Window.Content>
        <Box fillPositionParent>
          <Tabs>
            <Tabs.Tab
              key="AnomalyView"
              selected={0 === tabIndex}
              onClick={() => setTabIndex (0)}
            >
              <Icon name="table" /> Monitor
            </Tabs.Tab>
            <Tabs.Tab
              key="RecordView"
              selected={1 === tabIndex}
              onClick={() => setTabIndex(1)}
            >
              <Icon name="folder" /> Records
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};


const SupermatterAnomalyView = (props, context) => {
  const { act, data } = useBackend(context);
  const { event_active } = data;
  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Current Events">
          {event_active}
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
 };


const SupermatterAnomalyRecord = (props, context) => {
  const { act, data } = useBackend(context);
  const { last_events } = data;
  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Recorded Events">
          {last_events}
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};

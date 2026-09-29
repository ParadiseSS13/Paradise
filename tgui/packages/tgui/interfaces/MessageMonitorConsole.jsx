import { Box, Button, LabeledList, Section, Table, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const MessageMonitorConsole = (properties) => {
  const { act, data } = useBackend();
  const { auth, server, power, password, tabIndex, setTabIndex } = data;
  return (
    <Window width={800} height={400}>
      <Window.Content scrollable>
        <Section title="Authentication">
          <Box mb={2}>
            <LabeledList>
              <LabeledList.Item label="Server">
                <Button content="Server" selected={server} onClick={() => act('server')} />
              </LabeledList.Item>
              <LabeledList.Item label="Server Password">
                <Button content={password ? password : 'Unset'} selected={1} onClick={() => act('password')} />
              </LabeledList.Item>
              <LabeledList.Item label="server power">
                <Button content={power ? 'On' : 'Off'} selected={power} icon="power-off" onClick={() => act('power')} />
              </LabeledList.Item>
            </LabeledList>
          </Box>
        </Section>
        <Section title="Options">
          <Box mb={2}>
            <Button content="Clear message logs" selected={0} onClick={() => act('clear_msg')} />
            <Button content="Clear request console logs" selected={0} onClick={() => act('clear_req')} />
            <Button content="Send admin message" selected={0} onClick={() => act('admin_msg')} />
            <Button content="Set custom key" selected={0} onClick={() => act('custom_key')} />
          </Box>
        </Section>
        <Section title="Logs">
          <Tabs>
            <Tabs.Tab key="MessageLog" selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
              View Message Log
            </Tabs.Tab>
            <Tabs.Tab key="RequestLog" selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
              View request console logs
            </Tabs.Tab>
          </Tabs>
          {PickTab(tabIndex)}
        </Section>
      </Window.Content>
    </Window>
  );
};

const PickTab = (index) => {
    switch (index) {
      case 0:
        return <MessageLog />;
      case 1:
        return <RequestLog />;
      default:
        return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
    }
};

const MessageLog = (_properties) => {
  const { act, data } = useBackend();
  const { sender, recipient, message } = data;
  return (
    <Table m="0.5rem">
      <Table.Row header>
        <Table.Cell>Sender</Table.Cell>
        <Table.Cell>Recipient</Table.Cell>
        <Table.Cell>Message</Table.Cell>
      </Table.Row>
    </Table>
  );
};

const RequestLog = (_properties) => {
  const { act, data } = useBackend();
  const { sendingDep, recievingDep, message, stamp, idAuth, priority } = data;
  return (
    <Table m="0.5rem">
      <Table.Row header>
        <Table.Cell>Sendeing Department</Table.Cell>
        <Table.Cell>Recieving Department</Table.Cell>
        <Table.Cell>Message</Table.Cell>
        <Table.Cell>Stamp</Table.Cell>
        <Table.Cell>ID auth</Table.Cell>
      </Table.Row>
    </Table>
  );
};

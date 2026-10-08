import { useState } from 'react';

import {
  Box,
  Button,
  Icon,
  LabeledList,
  Section, Table,
  Tabs,
  Flex,
  NoticeBox,
  Stack,
  Dropdown,
  Input,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const MessageMonitorConsole = (properties) => {
  const { act, data } = useBackend();
  const { authenticated } = data;
  const [tabIndex, setTabIndex] = useState(0);

  const PickPage = (pageIndex) => {
    switch (pageIndex) {
      case 0:
        return <AuthPage />;
      case 1:
        return <MainPage />;
      default:
        return 'SMETHING WENT VERY WRONG PLEASE AHELP, PickPage error';
    }
  };

  return (
    <Window width={800} height={400}>
      <Window.Content scrollable>
        {PickPage(authenticated)}
      </Window.Content>
    </Window>
  );
};

const MainPage = (_properties) => {
  const { act, data } = useBackend();
  const { server, active, password } = data;
  const [tabIndex, setTabIndex] = useState(0);

    const PickTab = (index) => {
    switch (index) {
      case 0:
        return <MessageLog />;
      case 1:
        return <RequestLog />;
      default:
        return 'SMETHING WENT VERY WRONG PLEASE AHELP, PickTab error'; // `PickTab error` so we get a bit more info fromt the error meesgae.
    }
  };

  return (
    <Section>
      <NoticeBox info>
        <Stack>
          <Stack.Item grow mt={0.5}>
            Decrypted
          </Stack.Item>
          <Stack.Item>
            <Button icon="sign-out-alt" content="Logout" color="good" onClick={() => act('logout')} />
          </Stack.Item>
        </Stack>
      </NoticeBox>
      <Section title="Authentication">
        <Box mb={2}>
          <LabeledList>
            <LabeledList.Item label="Server">
              {server ? server : 'Unset'}
            </LabeledList.Item>
            <LabeledList.Item label="Server Password">
              <Button content={password ? password : 'Unset'} selected={1} onClick={() => act('password')} />
            </LabeledList.Item>
            <LabeledList.Item label="server power">
              <Button
                content={active ? 'On' : 'Off'}
                selected={active}
                icon="power-off"
                onClick={() => act('active')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Box>
      </Section>
      <Section title="Options">
        <Box mb={2}>
          <Button content="Clear message logs" selected={0} onClick={() => act('clear_msg')} />
          <Button content="Clear request console logs" selected={0} onClick={() => act('clear_req')} />
          <Button content="Send admin message" selected={0} onClick={() => act('admin_msg')} />
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
    </Section>
  );
};

const AuthPage = (_properties) => {
  const { act, data } = useBackend();
  const { servers } = data;
  const [server, setServer] = useState(servers[0]);
  const [password, setPassword] = useState('');
  return (
    <Flex height="100%" align="center" justify="center">
      <Flex.Item textAlign="center" mt="-2rem">
        <Box fontSize="1.5rem" bold>
          <Icon name="server" verticalAlign="middle" size={3} mr="1rem" />
          Decryption
        </Box>
        <Box color="label" my="1rem">
          Servers:
          <Dropdown
             width="150px"
             options={servers}
             selected={server}
             onSelected={(server) => setServer(server)}
          />
        </Box>
        <Box color="label" my="1rem">
          Password:
          <Input onChange={(password) => setPassword(password)} />
        </Box>
        <Box my="1rem">
          <Button
          content="Decrypt"
          disabled={!server || !password}
          onClick={() => act('decrypt', { server: server, password: password })}
          />
        </Box>
      </Flex.Item>
    </Flex>
  );
};

const MessageLog = (_properties) => {
  const { act, data } = useBackend();
  const { PDALog } = data;
  return (
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Delete</Table.Cell>
          <Table.Cell>Sender</Table.Cell>
          <Table.Cell>Recipient</Table.Cell>
          <Table.Cell>Message</Table.Cell>
        </Table.Row>
        {PDALog.map((P) => (
          <Table.Row key={P.sender}>
            <Table.Cell>
              <Button color="red" content="Delete" icon="trash" onClick={() => act('deleteP', { Pmessage: P.uid })} />
            </Table.Cell>
            <Table.Cell>{P.sender}</Table.Cell>
            <Table.Cell>{P.recipient}</Table.Cell>
            <Table.Cell>{P.message}</Table.Cell>
            <Stack.Divider />
          </Table.Row>
        ))}
      </Table>
  );
};

const RequestLog = (_properties) => {
  const { act, data } = useBackend();
  const { RequestLog } = data;
  return (
    <Table m="0.5rem">
      <Table.Row header>
        <Table.Cell>Recieving Department</Table.Cell>
        <Table.Cell>Sending Department</Table.Cell>
        <Table.Cell>Message</Table.Cell>
        <Table.Cell>Stamp</Table.Cell>
        <Table.Cell>ID Auth</Table.Cell>
        <Table.Cell>Priority</Table.Cell>
      </Table.Row>
      {RequestLog.map((R) => (
        <Table.Row key={R.recievingDep}>
          <Table.Cell>{R.recievingDep}</Table.Cell>
          <Table.Cell>{R.sendingDep}</Table.Cell>
          <Table.Cell>{R.message}</Table.Cell>
          <Table.Cell>{R.stamp}</Table.Cell>
          <Table.Cell>{R.idAuth}</Table.Cell>
          <Table.Cell>{R.priority}</Table.Cell>
          <Table.Cell>
            <Button color="red" content="Delete" icon="trash" onClick={() => act('deleteR', { Rmessage: R.uid })} />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

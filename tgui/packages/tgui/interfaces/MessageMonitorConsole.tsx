import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ServerData = {
  authenticated: boolean;
  server: string;
  active: boolean;
  password: string;
};

type AuthData = {
  servers: string[];
};

type PDALog = {
  recipient: string;
  sender: string;
  message: string;
  uid: string;
};

type PDAData = {
  PDALog: PDALog[];
};

type RCLog = {
  recievingDep: string;
  sendingDep: string;
  message: string;
  stamp: string;
  idAuth: string;
  priority: string;
  uid: string;
};

type RCData = {
  RequestLog: RCLog[];
};

type Recipients = {
  name: string;
  uid: string;
};

type RecipientsData = {
  recipients: Recipients[];
  selectedRecipient: Recipients;
};

export const MessageMonitorConsole = (properties) => {
  const { act, data } = useBackend<ServerData>();
  const { authenticated } = data;

  const PickPage = (pageIndex) => {
    switch (pageIndex) {
      case 0:
        return <AuthPage />;
      case 1:
        return <MainPage />;
      default:
        return 'SOMETHING WENT VERY WRONG PLEASE AHELP, PickPage error';// `PickPage error` so we get a bit more info from the error meesage.
    }
  };

  return (
    <Window width={800} height={550}>
      <Window.Content scrollable>{PickPage(authenticated)}</Window.Content>
    </Window>
  );
};

const MainPage = (_properties) => {
  const { act, data } = useBackend<ServerData>();
  const { server, active, password } = data;
  const [tabIndex, setTabIndex] = useState(0);

  const PickTab = (index) => {
    switch (index) {
      case 0:
        return <MessageLog />;
      case 1:
        return <RequestLog />;
      case 2:
        return <CustomMessage />;
      default:
        return 'SMETHING WENT VERY WRONG PLEASE AHELP, PickTab error'; // `PickTab error` so we get a bit more info from the error meesage.
    }
  };

  return (
    <Box>
      <NoticeBox info>
        <Stack>
          <Stack.Item grow mt={0.5}>
            Decrypted
          </Stack.Item>
          <Stack.Item>
            <Button icon="lock" content="Encrypt" color="good" onClick={() => act('logout')} />
          </Stack.Item>
        </Stack>
      </NoticeBox>
      <Section title="Authentication">
        <Box mb={2}>
          <LabeledList>
            <LabeledList.Item label="Server">{server ? server : 'Unset'}</LabeledList.Item>
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
        </Box>
      </Section>
      <Section>
        <Tabs>
          <Tabs.Tab key="MessageLog" selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
            View Message Log
          </Tabs.Tab>
          <Tabs.Tab key="RequestLog" selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
            View request console logs
          </Tabs.Tab>
          <Tabs.Tab key="Custom message" selected={tabIndex === 2} onClick={() => setTabIndex(2)}>
            Send custom message
          </Tabs.Tab>
        </Tabs>
        <Section>{PickTab(tabIndex)}</Section>
      </Section>
    </Box>
  );
};

const AuthPage = (_properties) => {
  const { act, data } = useBackend<AuthData>();
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
          <Dropdown width="150px" options={servers} selected={server} onSelected={(server) => setServer(server)} />
        </Box>
        <Box color="label" my="1rem">
          Password:
          <Input onChange={(password) => setPassword(password)} />
        </Box>
        <Box my="1rem">
          <Button
            content="Decrypt"
            icon="unlock"
            disabled={!server || !password}
            onClick={() => act('decrypt', { server: server, password: password })}
          />
        </Box>
      </Flex.Item>
    </Flex>
  );
};

const MessageLog = (_properties) => {
  const { act, data } = useBackend<PDAData>();
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
        </Table.Row>
      ))}
    </Table>
  );
};

const RequestLog = (_properties) => {
  const { act, data } = useBackend<RCData>();
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
        <Table.Cell>Delete</Table.Cell>
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

const CustomMessage = (_properties) => {
  const { act, data } = useBackend<RecipientsData>();
  const { recipients } = data;
  const [sender, setSender] = useState('');
  const [senderJob, setSenderJob] = useState('');
  const [selectedRecipient, setRecipient] = useState();
  const [message, setMessage] = useState('');

  let recipentMap = [];
  recipients.map((recipient) => (recipentMap[recipient.name] = recipient.uid));

  return (
    <Stack>
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item label="Sender">
            <Input fluid onChange={(sender) => setSender(sender)} />
          </LabeledList.Item>
          <LabeledList.Item label="Sender's job">
            <Input fluid onChange={(senderJob) => setSenderJob(senderJob)} />
          </LabeledList.Item>
          <LabeledList.Item label="Recipient">
            <Dropdown
              width="300px"
              options={recipients.map((recipient) => recipient.name)}
              selected={recipients.filter((recipient) => recipient.uid === selectedRecipient)[0]?.name}
              onSelected={(recipient) => setRecipient(recipentMap[recipient])}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Message">
            <TextArea
              fluid
              height="7rem"
              placeholder="Type your maessage here"
              onChange={(message) => setMessage(message)}
              value={message}
            />
          </LabeledList.Item>
        </LabeledList>
        <Button
          icon="arrow-up-from-bracket"
          content="Send"
          disabled={!sender || !senderJob || !selectedRecipient || !message}
          onClick={() =>
            act('admin_msg', { sender: sender, senderJob: senderJob, recipient: selectedRecipient, message: message })
          }
        />
      </Stack.Item>
    </Stack>
  );
};

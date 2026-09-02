import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../../backend';

export const pda_nanobank = (props) => {
  const { act, data } = useBackend();
  const { logged_in, owner_name, money } = data;
  const [tabIndex, setTabIndex] = useState(1);

  if (!logged_in) {
    return <LoginScreen />;
  }

  return (
    <>
      <Box>
        <LabeledList>
          <LabeledList.Item label="Account Name">{owner_name}</LabeledList.Item>
          <LabeledList.Item label="Account Balance">${money}</LabeledList.Item>
        </LabeledList>
      </Box>
      <Box>
        <NanoBankNavigation tabIndex={tabIndex} setTabIndex={setTabIndex} />
        <NanoBankTabContent tabIndex={tabIndex} />
      </Box>
    </>
  );
};

const NanoBankNavigation = (props) => {
  const { data } = useBackend();
  const { is_premium } = data;
  const { tabIndex, setTabIndex } = props;

  return (
    <Tabs mt={2}>
      <Tabs.Tab selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
        <Icon mr={1} name="list" />
        Transfers
      </Tabs.Tab>
      <Tabs.Tab selected={2 === tabIndex} onClick={() => setTabIndex(2)}>
        <Icon mr={1} name="list" />
        Account Actions
      </Tabs.Tab>
      <Tabs.Tab selected={3 === tabIndex} onClick={() => setTabIndex(3)}>
        <Icon mr={1} name="list" />
        Transaction History
      </Tabs.Tab>
      {Boolean(is_premium) && (
        <Tabs.Tab selected={4 === tabIndex} onClick={() => setTabIndex(4)}>
          <Icon mr={1} name="list" />
          Supply Orders
        </Tabs.Tab>
      )}
    </Tabs>
  );
};

const NanoBankTabContent = (props) => {
  const { data } = useBackend();
  const { db_status } = data;
  const { tabIndex } = props;

  if (!db_status) {
    return <Box>Account Database Connection Severed</Box>;
  }

  switch (tabIndex) {
    case 1:
      return <Transfer />;
    case 2:
      return <AccountActions />;
    case 3:
      return <Transactions />;
    case 4:
      return <SupplyOrders />;
    default:
      return "You are somehow on a tab that doesn't exist! Please let a coder know.";
  }
};

const Transfer = (props) => {
  const { act, data } = useBackend();

  const { requests, available_accounts, money } = data;
  const [selectedAccount, setSelectedAccount] = useState('selectedAccount');
  const [transferAmount, setTransferAmount] = useState('transferAmount');
  const [searchText, setSearchText] = useState('');

  let accountMap = [];
  available_accounts.map((account) => (accountMap[account.name] = account.UID));

  return (
    <>
      <LabeledList>
        <LabeledList.Item label="Account">
          <Input placeholder="Search by account name" onChange={(value) => setSearchText(value)} />
          <Dropdown
            mt={0.6}
            width="190px"
            options={available_accounts
              .filter(
                createSearch(searchText, (account) => {
                  return account.name;
                })
              )
              .map((account) => account.name)}
            selected={available_accounts.filter((account) => account.UID === selectedAccount)[0]?.name}
            onSelected={(val) => setSelectedAccount(accountMap[val])}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Amount">
          <Input placeholder="Up to 5000" onChange={(value) => setTransferAmount(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="Actions">
          <Button.Confirm
            bold
            icon="paper-plane"
            width="auto"
            disabled={money < transferAmount || !selectedAccount}
            content="Send"
            onClick={() =>
              act('transfer', {
                amount: transferAmount,
                transfer_to_account: selectedAccount,
              })
            }
          />
          <Button
            bold
            icon="hand-holding-usd"
            width="auto"
            disabled={!selectedAccount}
            content="Request"
            onClick={() =>
              act('transfer_request', {
                amount: transferAmount,
                transfer_to_account: selectedAccount,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
      <Section level={3} title="Requests">
        {requests.map((request) => (
          <Box key={request.UID} mt={1} ml={1}>
            <b>Request from {request.requester}</b>
            <LabeledList>
              <LabeledList.Item label="Amount">{request.amount}</LabeledList.Item>
              <LabeledList.Item label="Time">{request.time} Minutes ago</LabeledList.Item>
              <LabeledList.Item label="Actions">
                <Button.Confirm
                  icon="thumbs-up"
                  color="good"
                  disabled={money < request.amount}
                  content="Accept"
                  onClick={() =>
                    act('resolve_transfer_request', {
                      accepted: 1,
                      requestUID: request.request_id,
                    })
                  }
                />
                <Button
                  icon="thumbs-down"
                  color="bad"
                  content="Deny"
                  onClick={() =>
                    act('resolve_transfer_request', {
                      requestUID: request.request_id,
                    })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          </Box>
        ))}
      </Section>
    </>
  );
};

const AccountActions = (props) => {
  const { act, data } = useBackend();
  const { security_level, department_members, auto_approve, auto_approve_amount, is_department_account, is_premium } =
    data;

  return (
    <>
      <LabeledList>
        <LabeledList.Item label="Account Security">
          <Button
            icon="user-lock"
            selected={security_level === 1}
            content="Account Number Only"
            tooltip="Set Account security so that only having the account number is required for transactions"
            onClick={() =>
              act('set_security', {
                new_security_level: 1,
              })
            }
          />
          <Button
            icon="user-lock"
            selected={security_level === 2}
            content="Require Pin Entry"
            tooltip="Set Account security so that pin entry is required for transactions"
            onClick={() =>
              act('set_security', {
                new_security_level: 2,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Logout">
          <Button icon="sign-out-alt" width="auto" content="Logout" onClick={() => act('logout')} />
        </LabeledList.Item>
        <LabeledList.Item label="NanoBank Premium">
          <Button
            icon="coins"
            width="auto"
            tooltip="Upgrade your NanoBank to Premium for 250 Credits! Allows you to remotely approve department cargo orders on the supply console!"
            color={is_premium ? 'yellow' : 'good'}
            content={is_premium ? 'Already Purchased' : 'Purchase Premium'}
            onClick={() => act('purchase_premium')}
          />
        </LabeledList.Item>
      </LabeledList>
      {Boolean(is_department_account) && (
        <>
          <Divider />
          <LabeledList>
            <LabeledList.Item label="Auto Approve Orders">
              <Button
                color={auto_approve ? 'good' : 'bad'}
                content={auto_approve ? 'Yes' : 'No'}
                onClick={() => act('toggle_auto_approve')}
              />
            </LabeledList.Item>

            <LabeledList.Item label="Auto Approve Purchases when">
              <Input
                placeholder="# Credits"
                value={auto_approve_amount}
                onChange={(value) =>
                  act('set_approve_amount', {
                    approve_amount: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
          <Divider />
          <Table>
            <Table.Row header>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Occupation</Table.Cell>
              <Table.Cell>Can Approve Crates</Table.Cell>
            </Table.Row>
            {department_members.map((member) => (
              <Table.Row key={member}>
                <Table.Cell>{member.name}</Table.Cell>
                <Table.Cell>{member.job}</Table.Cell>
                <Table.Cell>
                  <Button
                    color={member.can_approve ? 'good' : 'bad'}
                    content={member.can_approve ? 'Yes' : 'No'}
                    onClick={() =>
                      act('toggle_member_approval', {
                        member: member.name,
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </>
      )}
    </>
  );
};

const Transactions = (props) => {
  const { act, data } = useBackend();
  const { transaction_log } = data;

  return (
    <Table>
      <Table.Row header>
        <Table.Cell>Timestamp</Table.Cell>
        <Table.Cell>Reason</Table.Cell>
        <Table.Cell>Value</Table.Cell>
        <Table.Cell>Terminal</Table.Cell>
      </Table.Row>
      {transaction_log.map((t) => (
        <Table.Row key={t}>
          <Table.Cell>{t.time}</Table.Cell>
          <Table.Cell>{t.purpose}</Table.Cell>
          <Table.Cell color={t.is_deposit ? 'green' : 'red'}>${t.amount}</Table.Cell>
          <Table.Cell>{t.target_name}</Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const LoginScreen = (props) => {
  const { act, data } = useBackend();
  const [accountID, setAccountID] = useState(null);
  const [accountPin, setAccountPin] = useState(null);
  const { card_account_num } = data;
  let account_num = accountID ? accountID : card_account_num;
  return (
    <LabeledList>
      <LabeledList.Item label="Account ID">
        <Input placeholder="Account ID" onChange={(value) => setAccountID(value)} />
      </LabeledList.Item>
      <LabeledList.Item label="Pin">
        <Input placeholder="Account Pin" onChange={(value) => setAccountPin(value)} />
      </LabeledList.Item>
      <LabeledList.Item>
        <Button
          content="Login"
          icon="sign-in-alt"
          disabled={!accountID && !card_account_num}
          onClick={() =>
            act('login', {
              account_num: account_num,
              account_pin: accountPin,
            })
          }
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

const GetRequestNotice = (_properties) => {
  const { request } = _properties;

  let head_color;
  let head_name;

  switch (request.department) {
    case 'Engineering':
      head_name = 'CE';
      head_color = 'orange';
      break;
    case 'Medical':
      head_name = 'CMO';
      head_color = 'teal';
      break;
    case 'Science':
      head_name = 'RD';
      head_color = 'purple';
      break;
    case 'Supply':
      head_name = 'CT'; // cargo tech
      head_color = 'brown';
      break;
    case 'Service':
      head_name = 'HOP';
      head_color = 'olive';
      break;
    case 'Security':
      head_name = 'HOS';
      head_color = 'red';
      break;
    case 'Command':
      head_name = 'CAP';
      head_color = 'blue';
      break;
    case 'Assistant':
      head_name = 'Any Head';
      head_color = 'grey';
      break;
    default:
      head_name = 'None';
      head_color = 'grey';
      break;
  }

  return (
    <Stack fill>
      <Stack.Item mt={0.5}>Approval Required:</Stack.Item>
      {Boolean(request.req_cargo_approval) && (
        <Stack.Item>
          <Button color="brown" content="QM" icon="user-tie" tooltip="This Order requires approval from the QM still" />
        </Stack.Item>
      )}
      {Boolean(request.req_head_approval) && (
        <Stack.Item>
          <Button
            color={head_color}
            content={head_name}
            disabled={request.req_cargo_approval}
            icon="user-tie"
            tooltip={
              request.req_cargo_approval
                ? `This Order first requires approval from the QM before the ${head_name} can approve it`
                : `This Order requires approval from the ${head_name} still`
            }
          />
        </Stack.Item>
      )}
    </Stack>
  );
};

const SupplyOrders = (_properties) => {
  const { act, data } = useBackend();
  const { supply_requests } = data;
  return (
    <>
      <Box bold>Requests</Box>
      <Table>
        {supply_requests.map((r) => (
          <Table.Row key={r.ordernum} className="Cargo_RequestList">
            <Table.Cell mb={1}>
              <Box>
                Order #{r.ordernum}: {r.supply_type} ({r.cost} credits) for <b>{r.orderedby}</b> with{' '}
                {r.department ? `The ${r.department} Department` : 'Their Personal'} Account
              </Box>
              <Box italic>Reason: {r.comment}</Box>
              <GetRequestNotice request={r} />
            </Table.Cell>
            <Stack.Item textAlign="right">
              <Button
                content="Approve"
                color="green"
                disabled={!r.can_approve}
                onClick={() =>
                  act('approve_crate', {
                    ordernum: r.ordernum,
                  })
                }
              />
              <Button
                content="Deny"
                color="red"
                disabled={!r.can_deny}
                onClick={() =>
                  act('deny_crate', {
                    ordernum: r.ordernum,
                  })
                }
              />
            </Stack.Item>
          </Table.Row>
        ))}
      </Table>
    </>
  );
};

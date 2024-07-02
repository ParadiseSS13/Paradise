import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Section,
  Tabs,
  Table,
  Divider,
} from '../../components';

export const pda_nanobank = (props, context) => {
  const { act, data } = useBackend(context);
  const { logged_in, owner_name, money } = data;

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
        <NanoBankNavigation />
        <NanoBankTabContent />
      </Box>
    </>
  );
};

const NanoBankNavigation = (properties, context) => {
  const { data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 1);

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
    </Tabs>
  );
};

const NanoBankTabContent = (props, context) => {
  const [tabIndex] = useLocalState(context, 'tabIndex', 1);
  const { data } = useBackend(context);
  const { db_status } = data;

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
    default:
      return "You are somehow on a tab that doesn't exist! Please let a coder know.";
  }
};

const Transfer = (props, context) => {
  const { act, data } = useBackend(context);

  const { requests, available_accounts, money } = data;
  const [selectedAccount, setSelectedAccount] = useLocalState(
    context,
    'selectedAccount'
  );
  const [transferAmount, setTransferAmount] = useLocalState(
    context,
    'transferAmount'
  );
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  let accountMap = [];
  available_accounts.map((account) => (accountMap[account.name] = account.UID));

  return (
    <>
      <LabeledList>
        <LabeledList.Item label="Account">
          <Input
            placeholder="Search by account name"
            onInput={(e, value) => setSearchText(value)}
          />
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
            selected={
              available_accounts.filter(
                (account) => account.UID === selectedAccount
              )[0]?.name
            }
            onSelected={(val) => setSelectedAccount(accountMap[val])}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Amount">
          <Input
            placeholder="Up to 5000"
            onInput={(e, value) => setTransferAmount(value)}
          />
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
              <LabeledList.Item label="Amount">
                {request.amount}
              </LabeledList.Item>
              <LabeledList.Item label="Time">
                {request.time} Minutes ago
              </LabeledList.Item>
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

const AccountActions = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    security_level,
    department_members,
    auto_approve,
    auto_approve_amount,
    is_department_account,
  } = data;

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
          <Button
            icon="sign-out-alt"
            width="auto"
            content="Logout"
            onClick={() => act('logout')}
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
                onInput={(e, value) =>
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

const Transactions = (props, context) => {
  const { act, data } = useBackend(context);
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
          <Table.Cell color={t.is_deposit ? 'green' : 'red'}>
            ${t.amount}
          </Table.Cell>
          <Table.Cell>{t.target_name}</Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const LoginScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const [accountID, setAccountID] = useLocalState(context, 'accountID', null);
  const [accountPin, setAccountPin] = useLocalState(
    context,
    'accountPin',
    null
  );
  const { card_account_num } = data;
  let account_num = accountID ? accountID : card_account_num;
  return (
    <LabeledList>
      <LabeledList.Item label="Account ID">
        <Input
          placeholder="Account ID"
          onInput={(e, value) => setAccountID(value)}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Pin">
        <Input
          placeholder="Account Pin"
          onInput={(e, value) => setAccountPin(value)}
        />
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

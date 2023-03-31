import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Flex,
  Icon,
  Input,
  LabeledList,
  Section,
  Table,
  Tabs,
} from '../components';
import { FlexItem } from '../components/Flex';
import { TableCell } from '../components/Table';
import { Window } from '../layouts';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';

export const AccountsUplinkTerminal = (properties, context) => {
  const { act, data } = useBackend(context);
  const { loginState, currentPage } = data;

  let body;
  if (!loginState.logged_in) {
    return (
      <Window resizable>
        <Window.Content>
          <LoginScreen />
        </Window.Content>
      </Window>
    );
  } else {
    if (currentPage === 1) {
      body = <AccountsUplinkTerminalContent />;
    } else if (currentPage === 2) {
      body = <DetailedAccountInfo />;
    } else if (currentPage === 3) {
      body = <CreateAccount />;
    }
  }

  return (
    <Window resizable>
      <Window.Content scrollable>
        <LoginInfo />
        <AccountsUplinkTerminalNavigation />
        {body}
      </Window.Content>
    </Window>
  );
};

const AccountsUplinkTerminalNavigation = (properties, context) => {
  const { data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const {
    login_state,
  } = data
  return (
    <Tabs>
      <Tabs.Tab
        selected={0 === tabIndex}
        onClick={() => setTabIndex(0)}>
        <Icon name="list" />
        User Accounts
      </Tabs.Tab>
      <Tabs.Tab
        selected={1 === tabIndex}
        onClick={() => setTabIndex(1)}>
        <Icon name="list" />
        Department Accounts
      </Tabs.Tab>
    </Tabs>
  );
};

const AccountsUplinkTerminalContent = (props, context) => {
  const [tabIndex] = useLocalState(context, 'tabIndex', 0);
  switch (tabIndex) {
    case 0:
      return <AccountsRecordList />;
    case 1:
      return <DepartmentAccountsList />;
    default:
      return "You are somehow on a tab that doesn't exist! Please let a coder know.";
  }
};

const AccountsRecordList = (properties, context) => {
  const { act, data } = useBackend(context);
  const { accounts } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortId, _setSortId] = useLocalState(context, 'sortId', 'owner_name');
  const [sortOrder, _setSortOrder] = useLocalState(context, 'sortOrder', true);
  return (
    <Flex direction="column" height="100%">
      <AccountsActions />
      <Flex.Item flexGrow="1" mt="0.5rem">
        <Section height="100%">
          <Table className="AccountsUplinkTerminal__list">
            <Table.Row bold>
              <SortButton id="owner_name">Account Holder</SortButton>
              <SortButton id="account_number">Account Number</SortButton>
              <SortButton id="suspended">Account Status</SortButton>
              <SortButton id="money">Account Balance</SortButton>
            </Table.Row>
            {accounts
              .filter(
                createSearch(searchText, (account) => {
                  return (
                    account.owner_name +
                    '|' +
                    account.account_number +
                    '|' +
                    account.suspended +
                    '|' +
                    account.money
                  );
                })
              )
              .sort((a, b) => {
                const i = sortOrder ? 1 : -1;
                return a[sortId].localeCompare(b[sortId]) * i;
              })
              .map((account) => (
                <Table.Row
                  key={account.account_number}
                  className={
                    'AccountsUplinkTerminal__listRow--' + account.suspended
                  }
                  onClick={() =>
                    act('view_account_detail', { account_num: account.account_number })
                  }
                >
                  <Table.Cell>
                    <Icon name="user" /> {account.owner_name}
                  </Table.Cell>
                  <Table.Cell>#{account.account_number}</Table.Cell>
                  <Table.Cell>{account.suspended}</Table.Cell>
                  <Table.Cell>{account.money}</Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const DepartmentAccountsList = (properties, context) => {
  const { act, data } = useBackend(context);
  const { department_accounts } = data;
  return (
    <Flex direction="column" height="100%">
      <AccountsActions />
      <Flex.Item flexGrow="1" mt="0.5rem">
        <Section height="100%">
          <Table className="AccountsUplinkTerminal__list">
            <Table.Row bold>
              <TableCell>Department Name</TableCell>
              <TableCell>Account Number</TableCell>
              <TableCell>Account Status</TableCell>
              <TableCell>Account Balance</TableCell>
            </Table.Row>
            {department_accounts
              .map((account) => (
                <Table.Row
                  key={account.account_number}
                  className={
                    'AccountsUplinkTerminal__listRow--' + account.suspended
                  }
                  onClick={() => act('view_account_detail', {
                    account_num: account.account_number
                  })}>
                  <Table.Cell>
                    <Icon name="wallet"/> {account.name}
                  </Table.Cell>
                  <Table.Cell>#{account.account_number}</Table.Cell>
                  <Table.Cell>{account.suspended}</Table.Cell>
                  <Table.Cell>{account.money}</Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const SortButton = (properties, context) => {
  const [sortId, setSortId] = useLocalState(context, 'sortId', 'name');
  const [sortOrder, setSortOrder] = useLocalState(context, 'sortOrder', true);
  const { id, children } = properties;
  return (
    <Table.Cell>
      <Button
        color={sortId !== id && 'transparent'}
        width="100%"
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}
      >
        {children}
        {sortId === id && (
          <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />
        )}
      </Button>
    </Table.Cell>
  );
};

const AccountsActions = (properties, context) => {
  const { act, data } = useBackend(context);
  const { is_printing } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  return (
    <Flex>
      <FlexItem>
        <Button
          content="New Account"
          icon="plus"
          onClick={() => act('create_new_account')}
        />
      </FlexItem>
      <FlexItem grow="1" ml="0.5rem">
        <Input
          placeholder="Search by account holder, number, status"
          width="100%"
          onInput={(e, value) => setSearchText(value)}
        />
      </FlexItem>
    </Flex>
  );
};

const DetailedAccountInfo = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    account_number,
    owner_name,
    money,
    suspended,
    transactions,
    account_pin,
    is_department_account
  } = data;
  return (
    <Fragment>
      <Section
        title={'#' + account_number + ' / ' + owner_name}
        mt={1}
        buttons={
          <Button
            icon="arrow-left"
            content="Back"
            onClick={() => act('back')}
          />
        }
      >
        <LabeledList>
          <LabeledList.Item label="Account Number">
            #{account_number}
          </LabeledList.Item>
          {!!is_department_account &&
            <LabeledList.Item label="Account Pin">
              {account_pin}
            </LabeledList.Item>
          }
          <LabeledList.Item label="Account Pin Actions">
            <Button ml={1}
              icon="user-cog"
              content="Set New Pin"
              disabled={Boolean(is_department_account)}
              onClick={() => act('set_account_pin', {
                account_number: account_number,
              })}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Account Holder">
            {owner_name}
          </LabeledList.Item>
          <LabeledList.Item label="Account Balance">{money}</LabeledList.Item>
          <LabeledList.Item
            label="Account Status"
            color={suspended ? 'red' : 'green'}
          >
            {suspended ? 'Suspended' : 'Active'}
            <Button
              ml={1}
              content={suspended ? 'Unsuspend' : 'Suspend'}
              icon={suspended ? 'unlock' : 'lock'}
              onClick={() => act('toggle_suspension')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Transactions">
        <Table>
          <Table.Row header>
            <Table.Cell>Timestamp</Table.Cell>
            <Table.Cell>Reason</Table.Cell>
            <Table.Cell>Value</Table.Cell>
            <Table.Cell>Terminal</Table.Cell>
          </Table.Row>
          {transactions.map((t) => (
            <Table.Row key={t}>
              <Table.Cell>{t.time}</Table.Cell>
              <Table.Cell>{t.purpose}</Table.Cell>
              <Table.Cell color={t.is_deposit ? 'green' : 'red'}>${t.amount}</Table.Cell>
              <Table.Cell>{t.target_name}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Fragment>
  );
};

const CreateAccount = (properties, context) => {
  const { act, data } = useBackend(context);
  const [accName, setAccName] = useLocalState(context, 'accName', '');
  const [accDeposit, setAccDeposit] = useLocalState(context, 'accDeposit', '');
  return (
    <Section
      title="Create Account"
      buttons={
        <Button icon="arrow-left" content="Back" onClick={() => act('back')} />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Account Holder">
          <Input
            placeholder="Name Here"
            onChange={(e, value) => setAccName(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Initial Deposit">
          <Input
            placeholder="0"
            onChange={(e, value) => setAccDeposit(value)}
          />
        </LabeledList.Item>
      </LabeledList>
      <Button
        mt={1}
        fluid
        content="Create Account"
        onClick={() =>
          act('finalise_create_account', {
            holder_name: accName,
            starting_funds: accDeposit,
          })
        }
      />
    </Section>
  );
};

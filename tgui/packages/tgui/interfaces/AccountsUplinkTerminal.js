import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import { RecordsTable } from './common/RecordsTable';

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
      <Window.Content scrollable className="Layout__content--flexColumn">
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
  const { login_state } = data;
  return (
    <Tabs>
      <Tabs.Tab selected={0 === tabIndex} onClick={() => setTabIndex(0)}>
        <Icon name="list" />
        User Accounts
      </Tabs.Tab>
      <Tabs.Tab selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
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

const AccountsRecordList = (props, context) => {
  const { act, data } = useBackend(context);
  const { accounts } = data;
  return (
    <RecordsTable
      columns={[
        {
          id: 'owner_name',
          name: 'Account Holder',
          datum: {
            children: (value) => (
              <>
                <Icon name="user" /> {value}
              </>
            ),
          },
        },
        {
          id: 'account_number',
          name: 'Account Number',
          datum: { children: (value) => <>#{value}</> },
        },
        { id: 'suspended', name: 'Account Status' },
        { id: 'money', name: 'Account Balance' },
      ]}
      data={accounts}
      datumID={(datum) => datum.account_number}
      leftButtons={
        <Button
          content="New Account"
          icon="plus"
          onClick={() => act('create_new_account')}
        />
      }
      searchPlaceholder="Search by account holder, number, status"
      datumRowProps={(datum) => ({
        className: `AccountsUplinkTerminal__listRow--${datum.suspended}`,
        onClick: () =>
          act('view_account_detail', {
            account_num: datum.account_number,
          }),
      })}
    />
  );
};

const DepartmentAccountsList = (props, context) => {
  const { act, data } = useBackend(context);
  const { department_accounts } = data;
  return (
    <RecordsTable
      columns={[
        {
          id: 'name',
          name: 'Department Name',
          datum: {
            children: (value) => (
              <>
                <Icon name="wallet" /> {value}
              </>
            ),
          },
        },
        {
          id: 'account_number',
          name: 'Account Number',
          datum: { children: (value) => <>#{value}</> },
        },
        { id: 'suspended', name: 'Account Status' },
        { id: 'money', name: 'Account Balance' },
      ]}
      data={department_accounts}
      datumID={(datum) => datum.account_number}
      leftButtons={
        <Button
          content="New Account"
          icon="plus"
          onClick={() => act('create_new_account')}
        />
      }
      searchPlaceholder="Search by department name, account number, status, and balance"
      datumRowProps={(datum) => ({
        className: `AccountsUplinkTerminal__listRow--${datum.suspended}`,
        onClick: () =>
          act('view_account_detail', {
            account_num: datum.account_number,
          }),
      })}
    />
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
    is_department_account,
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
          {!!is_department_account && (
            <LabeledList.Item label="Account Pin">
              {account_pin}
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Account Pin Actions">
            <Button
              ml={1}
              icon="user-cog"
              content="Set New Pin"
              disabled={Boolean(is_department_account)}
              onClick={() =>
                act('set_account_pin', {
                  account_number: account_number,
                })
              }
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
              <Table.Cell color={t.is_deposit ? 'green' : 'red'}>
                ${t.amount}
              </Table.Cell>
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

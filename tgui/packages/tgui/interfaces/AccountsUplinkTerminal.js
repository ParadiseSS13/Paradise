import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from "../backend";
import { Button, Flex, Icon, Input, LabeledList, Section, Table } from '../components';
import { FlexItem } from '../components/Flex';
import { Window } from "../layouts";
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';

export const AccountsUplinkTerminal = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    loginState,
    currentPage,
  } = data;

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
      body = <AccountsRecordList />;
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
        {body}
      </Window.Content>
    </Window>
  );
};

const AccountsRecordList = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    accounts,
  } = data;
  const [searchText, setSearchText] = useLocalState(context, "searchText", "");
  const [sortId, _setSortId] = useLocalState(context, "sortId", "owner_name");
  const [sortOrder, _setSortOrder] = useLocalState(context, "sortOrder", true);
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
            </Table.Row>
            {accounts
              .filter(createSearch(searchText, account => {
                return account.owner_name + "|"
                        + account.account_number + "|"
                        + account.suspended;
              }))
              .sort((a, b) => {
                const i = sortOrder ? 1 : -1;
                return a[sortId].localeCompare(b[sortId]) * i;
              })
              .map(account => (
                <Table.Row
                  key={account.id}
                  onClick={
                    () => act('view_account_detail', { index: account.account_index })
                  }>
                  <Table.Cell><Icon name="user" /> {account.owner_name}</Table.Cell>
                  <Table.Cell>#{account.account_number}</Table.Cell>
                  <Table.Cell>{account.suspended}</Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const SortButton = (properties, context) => {
  const [sortId, setSortId] = useLocalState(context, "sortId", "name");
  const [sortOrder, setSortOrder] = useLocalState(context, "sortOrder", true);
  const {
    id,
    children,
  } = properties;
  return (
    <Table.Cell>
      <Button
        color={sortId !== id && "transparent"}
        width="100%"
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}>
        {children}
        {sortId === id && (
          <Icon
            name={sortOrder ? "sort-up" : "sort-down"}
            ml="0.25rem;"
          />
        )}
      </Button>
    </Table.Cell>
  );
};

const AccountsActions = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    is_printing,
  } = data;
  const [searchText, setSearchText] = useLocalState(context, "searchText", "");
  return (
    <Flex>
      <FlexItem>
        <Button
          content="New Account"
          icon="plus"
          onClick={() => act('create_new_account')}
        />
        <Button
          icon="print"
          content="Print Account List"
          disabled={is_printing}
          ml="0.25rem"
          onClick={() => act('print_records')}
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
    is_printing,
    account_number,
    owner_name,
    money,
    suspended,
    transactions,
  } = data;
  return (
    <Fragment>
      <Section title={"#" + account_number + " / " + owner_name} mt={1} buttons={
        <Fragment>
          <Button
            icon="print"
            content="Print Account Details"
            disabled={is_printing}
            onClick={
              () => act('print_account_details')
            } />
          <Button
            icon="arrow-left"
            content="Back"
            onClick={
              () => act('back')
            } />
        </Fragment>
      }>
        <LabeledList>
          <LabeledList.Item label="Account Number">
            #{account_number}
          </LabeledList.Item>
          <LabeledList.Item label="Account Holder">
            {owner_name}
          </LabeledList.Item>
          <LabeledList.Item label="Account Balance">
            {money}
          </LabeledList.Item>
          <LabeledList.Item label="Account Status" color={suspended ? "red" : "green"}>
            {suspended ? "Suspended" : "Active"}
            <Button
              ml={1}
              content={suspended ? "Unsuspend" : "Suspend"}
              icon={suspended ? "unlock" : "lock"}
              onClick={
                () => act('toggle_suspension')
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Transactions">
        <Table>
          <Table.Row header>
            <Table.Cell>
              Timestamp
            </Table.Cell>
            <Table.Cell>
              Target
            </Table.Cell>
            <Table.Cell>
              Reason
            </Table.Cell>
            <Table.Cell>
              Value
            </Table.Cell>
            <Table.Cell>
              Terminal
            </Table.Cell>
          </Table.Row>
          {transactions.map(t => (
            <Table.Row key={t}>
              <Table.Cell>
                {t.date} {t.time}
              </Table.Cell>
              <Table.Cell>
                {t.target_name}
              </Table.Cell>
              <Table.Cell>
                {t.purpose}
              </Table.Cell>
              <Table.Cell>
                ${t.amount}
              </Table.Cell>
              <Table.Cell>
                {t.source_terminal}
              </Table.Cell>
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
    <Section title="Create Account" buttons={
      <Button
        icon="arrow-left"
        content="Back"
        onClick={
          () => act('back')
        } />
    }>
      <LabeledList>
        <LabeledList.Item label="Account Holder">
          <Input placeholder="Name Here" onChange={(e, value) => setAccName(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="Initial Deposit">
          <Input placeholder="0" onChange={(e, value) => setAccDeposit(value)} />
        </LabeledList.Item>
      </LabeledList>
      <Button
        mt={1}
        fluid
        content="Create Account"
        onClick={
          () => act('finalise_create_account', { holder_name: accName, starting_funds: accDeposit })
        }
      />
    </Section>
  );
};

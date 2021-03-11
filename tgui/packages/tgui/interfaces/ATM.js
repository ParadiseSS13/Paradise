import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Table, Icon, Input, Divider, Box, LabeledList, Section } from '../components';
import { Window } from '../layouts';

/*
#define NO_SCREEN 0
#define CHANGE_SECURITY_LEVEL 1
#define TRANSFER_FUNDS 2
#define VIEW_TRANSACTION_LOGS 3
*/

export const ATM = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    view_screen,
    authenticated_account,
    ticks_left_locked_down,
    linked_db,
  } = data;
  let body;
  if (ticks_left_locked_down > 0) {
    body = (
      <Box bold color="bad">
        <Icon name="exclamation-triangle" />
        Maximum number of pin attempts exceeded! Access to this ATM has been temporarily disabled.
      </Box>
    );
  } else if (!linked_db) {
    body = (
      <Box bold color="bad">
        <Icon name="exclamation-triangle" />
        Unable to connect to accounts database, please retry and if the issue persists contact Nanotrasen IT support.
      </Box>
    );
  } else if (authenticated_account) {
    switch (view_screen) {
      case 1: // CHANGE_SECURITY_LEVEL
        body = <ChangeSecurityLevel />;
        break;
      case 2: // TRANSFER_FUNDS
        body = <TransferFunds />;
        break;
      case 3: // VIEW_TRANSACTION_LOGS
        body = <ViewTransactionLogs />;
        break;
      default:
        body = <DefaultScreen />;
    }
  }
  else {
    body = <LoginScreen />;
  }
  return (
    <Window resizable>
      <Window.Content scrollable>
        <IntroductionAndCard />
        <Section>
          {body}
        </Section>
      </Window.Content>
    </Window>
  );
};

const IntroductionAndCard = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    machine_id,
    held_card_name,
  } = data;
  return (
    <Section title="Nanotrasen Automatic Teller Machine" >
      <Box>
        For all your monetary need!
      </Box>
      <Divider />
      <Box>
        <Icon name="info-circle" /> This terminal is <i>{machine_id}</i>, report this code when contacting Nanotrasen IT Support.
      </Box>
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Card">
          <Button
            content={held_card_name}
            icon="eject"
            onClick={
              () => act('insert_card')
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ChangeSecurityLevel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    security_level,
  } = data;
  return (
    <Section title="Select a new security level for this account" >
      <LabeledList>
        <Divider />
        <LabeledList.Item label="Level">
          <Button
            content="Zero"
            icon="unlock"
            selected={security_level === 0}
            onClick={
              () => act('change_security_level', { new_security_level: 0 })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          Either the account number or card is required to access this account.
          EFTPOS transactions will require a card and ask for a pin, but not verify the pin is correct.
        </LabeledList.Item>
        <Divider />
        <LabeledList.Item label="Level">
          <Button
            content="One"
            icon="unlock"
            selected={security_level === 1}
            onClick={
              () => act('change_security_level', { new_security_level: 1 })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          An account number and pin must be manually entered to access this account and process transactions.
        </LabeledList.Item>
        <Divider />
        <LabeledList.Item label="Level">
          <Button
            content="Two"
            selected={security_level === 2}
            icon="unlock"
            onClick={
              () => act('change_security_level', { new_security_level: 2 })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          In addition to account number and pin, a card is required to access this account and process transactions.
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <BackButton />
    </Section>
  );
};

const TransferFunds = (props, context) => {
  const { act, data } = useBackend(context);
  const [targetAccNumber, setTargetAccNumber] = useLocalState(context, "targetAccNumber", 0);
  const [fundsAmount, setFundsAmount] = useLocalState(context, "fundsAmount", 0);
  const [purpose, setPurpose] = useLocalState(context, "purpose", 0);
  const {
    money,
  } = data;
  return (
    <Section title="Transfer Fund" >
      <LabeledList>
        <LabeledList.Item label="Account Balance">
          ${money}
        </LabeledList.Item>
        <LabeledList.Item label="Target account number">
          <Input
            placeholder="6 Digit Number"
            onInput={(e, value) => setTargetAccNumber(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Funds to transfer">
          <Input
            onInput={(e, value) => setFundsAmount(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Transaction Purpose">
          <Input
            fluid
            onInput={(e, value) => setPurpose(value)}
          />
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Button
        content="Transfer"
        icon="sign-out-alt"
        onClick={
          () => act('transfer', { target_acc_number: targetAccNumber, funds_amount: fundsAmount, purpose: purpose })
        } />
      <Divider />
      <BackButton />
    </Section>
  );
};

const DefaultScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const [fundsAmount, setFundsAmount] = useLocalState(context, "fundsAmount", 0);
  const {
    owner_name,
    money,
  } = data;
  return (
    <Fragment>
      <Section
        title={"Welcome, " + owner_name}
        buttons={
          <Button
            content="Logout"
            icon="sign-out-alt"
            onClick={
              () => act('logout')
            } />
        }>
        <LabeledList>
          <LabeledList.Item
            label="Account Balance">
            ${money}
          </LabeledList.Item>
          <LabeledList.Item
            label="Withdrawal Amount">
            <Input
              onInput={(e, value) => setFundsAmount(value)} />
          </LabeledList.Item>
          <LabeledList.Item>
            <Button
              content="Withdraw Fund"
              icon="sign-out-alt"
              onClick={
                () => act('withdrawal', { funds_amount: fundsAmount })
              } />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Menu">
        <Box>
          <Button
            content="Change account security level"
            icon="lock"
            onClick={
              () => act('view_screen', { view_screen: 1 })
            }
          />
        </Box>
        <Box>
          <Button
            content="Make transfer"
            icon="exchange-alt"
            onClick={
              () => act('view_screen', { view_screen: 2 })
            }
          />
        </Box>
        <Box>
          <Button
            content="View transaction log"
            icon="list"
            onClick={
              () => act('view_screen', { view_screen: 3 })
            }
          />
        </Box>
        <Box>
          <Button
            content="Print balance statement"
            icon="print"
            onClick={
              () => act('balance_statement')
            }
          />
        </Box>
      </Section>
    </Fragment>
  );
};

const LoginScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const [accountID, setAccountID] = useLocalState(context, "accountID", null);
  const [accountPin, setAccountPin] = useLocalState(context, "accountPin", null);
  const {
    machine_id,
    held_card_name,
  } = data;
  return (
    <Section
      title="Insert card or enter ID and pin to login">
      <LabeledList>
        <LabeledList.Item label="Account ID">
          <Input
            placeholder="6 Digit Number"
            onInput={(e, value) => setAccountID(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Pin">
          <Input
            placeholder="6 Digit Number"
            onInput={(e, value) => setAccountPin(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item>
          <Button
            content="Login"
            icon="sign-in-alt"
            onClick={
              () => act('attempt_auth', { account_num: accountID, account_pin: accountPin })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ViewTransactionLogs = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    transaction_log,
  } = data;
  return (
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
        {transaction_log.map(t => (
          <Table.Row key={t}>
            <Table.Cell p="1rem">
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
      <Divider />
      <BackButton />
    </Section>
  );
};

const BackButton = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Button
      content="Back"
      icon="sign-out-alt"
      onClick={
        () => act('view_screen', { view_screen: 0 })
      } />
  );
};

import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Icon, Input, Divider, Box, LabeledList, Section } from '../components';
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
  if (ticks_left_locked_down > 0){
    body =
    <Box bold color="bad">
      <Icon name = "exclamation-triangle"></Icon> Maximum number of pin attempts exceeded! Access to this ATM has been temporarily disabled.
    </Box>
  } else if (!linked_db){
    body =
    <Box bold color="bad">
      <Icon name = "exclamation-triangle"></Icon> Unable to connect to accounts database, please retry and if the issue persists contact Nanotrasen IT support.
    </Box>
  } else if (authenticated_account){
    switch(view_screen){
      case 1: // CHANGE_SECURITY_LEVEL
        body = <ChangeSecurityLevel/>
        break;
      case 2: // TRANSFER_FUNDS
        body = <TransferFunds/>
        break;
      case 3: // VIEW_TRANSACTION_LOGS
        body = <ViewTransactionLogs/>
        break;
      default:
        body = <DefaultScreen/>
    }
  }
  else {
    body = <LoginScreen />;
   }
  return (
    <Window resizable>
      <Window.Content scrollable>
        <IntroductionAndCard/>
        <Section>
        {body}
        </Section>
      </Window.Content>
    </Window>
  );
};

const IntroductionAndCard = (props, context) => {
  const {act, data } = useBackend(context);
  const {
    machine_id,
    held_card_name,
  } = data;
  return (<Section title="Nanotrasen Automatic Teller Machine" >
    <Box>For all your monetary need!
    </Box>
    <Divider/>
    <Box>
      <Icon name = "info-circle"></Icon> This terminal is <i>{machine_id}</i>, report this code when contacting Nanotrasen IT Support.
    </Box>
    <Divider/>
    <LabeledList>
      <LabeledList.Item label = "Card">
        <Button
          content={held_card_name}
          icon='eject'
          onClick={
            () => act('insert_card')}
        />
      </LabeledList.Item>
    </LabeledList>
  </Section>
  );
};

const DefaultScreen = (props, context) => {
  const {act, data } = useBackend(context);
  const {
    owner_name,
    money,
  } = data;
  return (
    <Flex>
      <Box>
        Welcome, {owner_name}
      </Box>
      <Box>
        Account balance: {money}
      </Box>
      <Divider />
      <Box>
      <Button
            content="Logout"
            icon='sign-out-alt'
            onClick={
              () => act('logout')}
          />
      </Box>
    </Flex>
  );
};

const LoginScreen = (props, context) => {
  const {act, data } = useBackend(context);
  const [accountID, setAccountID] = useLocalState(context, "accountID", null)
  const [accountPin, setAccountPin] = useLocalState(context, "accountPin", null)
  const {
    machine_id,
    held_card_name,
  } = data;
  return (
  <Flex>
    <LabeledList>
      <LabeledList.Item>
      Insert card or enter ID and pin to login
      </LabeledList.Item>
      <LabeledList.Item label = "Account ID">
        <Input
        placeholder="6 Digit Number"
        onInput={(e, value) => setAccountID(value)}
        />
      </LabeledList.Item>
      <LabeledList.Item label = "Pin">
        <Input
        placeholder= "6 Digit Number"
        onInput={(e, value) => setAccountPin(value)}
        />
      </LabeledList.Item>
      <LabeledList.Item>
        <Button
            content="Login"
            icon='sign-in-alt'
            onClick={
              () => act('attempt_auth', {account_num: accountID, account_pin: accountPin})}
          />
      </LabeledList.Item>
    </LabeledList>
  </Flex>
  );
};





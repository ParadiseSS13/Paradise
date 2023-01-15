import { createSearch } from 'common/string';
import { useBackend, useLocalState } from "../backend";
import { Box, Button, LabeledList, Section, Input, Dropdown } from '../components';
import { Window } from '../layouts';

export const EFTPOS = (props, context) => {
  const { act, data } = useBackend(context);
  const { transaction_locked, machine_name } = data;
  return (
    <Window>
      <Window.Content>
        <Section title={"POS Terminal " + machine_name}
          buttons={
            <>
              <Button
                content={transaction_locked ? "Unlock EFTPOS" : "Lock EFTPOS"}
                tooltip="Enter pin to modify transactions and EFTPOS settings"
                icon={transaction_locked ? "lock-open" : "lock"}
                onClick={() => act('toggle_lock')}
              />
              <Button
                content="Reset EFTPOS"
                tooltip="Requires Captain, HoP or CC access"
                icon="sync"
                onClick={() => act('reset')}
              />
        </>}>
          {transaction_locked ? <LockedView /> : <UnlockedView />}
        </Section>

      </Window.Content>
    </Window>
  );
};

const LockedView = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    transaction_amount,
    transaction_paid,
  } = data;
  return (
    <>
      <Box mt={2} bold width="100%" fontSize="3rem" color={transaction_paid ? 'green' : 'red'} align="center" justify="center">Payment {transaction_paid ? "Accepted" : "Due"}: ${transaction_amount}</Box>
      <Box mt={.5} fontSize="1.25rem" align="center" justify="center">
        {transaction_paid
          ? 'This transaction has been processed successfully '
          : 'Swipe your card to finish this transaction.'}
        </Box>
    </>
  );
};

const UnlockedView = (props, context) => {
  const { act, data } = useBackend(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const {
    transaction_purpose,
    transaction_amount,
    linked_account,
    available_accounts
  } = data;

  let accountMap = []
  available_accounts.map(account => (
    accountMap[account.name] = account.UID
  ))
  return (
    <LabeledList>
      <LabeledList.Item label="Transaction Purpose">
        <Button
          content={transaction_purpose}
          icon="edit"
          onClick={() => act('trans_purpose')}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Value">
        <Button
          content={transaction_amount ? '$' + transaction_amount : '$0'}
          icon="edit"
          onClick={() => act('trans_value')}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Linked Account">
        <Box mb={.5}>{linked_account.name}</Box>
        <Input
          width="190px"
          placeholder="Search by name"
          onInput={(e, value) => setSearchText(value)}
        />
        <Dropdown
          mt={0.6}
          width="190px"
          options={available_accounts
            .filter(
              createSearch(searchText, (account) => {
                return (
                  account.name
                );
              })
            )
            .map((account) => account.name)}
          selected={available_accounts.filter(account => account.UID === linked_account.UID)[0]?.name}
          onSelected={(val) => act('link_account', {
            account: accountMap[val],
          })}/>
      </LabeledList.Item>
      <LabeledList.Item label="Actions">
        <Button
          content="Change access code"
          icon="key"
          onClick={() => act('change_code')}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

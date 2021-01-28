import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const EFTPOS = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    transaction_locked,
    machine_name,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Box italic>
          This terminal is {machine_name}. Report this code when contacting Nanotrasen IT Support.
        </Box>
        {transaction_locked ? (
          <LockedView />
        ) : (
          <UnlockedView />
        )}
      </Window.Content>
    </Window>
  );
};

const LockedView = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    transaction_purpose,
    transaction_amount,
    linked_account,
    transaction_paid,
  } = data;
  return (
    <Section title="Current Transaction" mt={1}>
      <LabeledList>
        <LabeledList.Item label="Transaction Purpose">
          {transaction_purpose}
        </LabeledList.Item>
        <LabeledList.Item label="Value">
          {/* Ternary required otherwise the 0 is offset weirdly */}
          {transaction_amount ? transaction_amount : "0"}
        </LabeledList.Item>
        <LabeledList.Item label="Linked Account">
          {linked_account ? linked_account : "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Actions">
          <Button
            content={transaction_paid ? "Reset" : "Reset (Auth required)"}
            icon="unlock"
            onClick={
              () => act('toggle_lock')
            } />
        </LabeledList.Item>
      </LabeledList>
      <NoticeBox mt={1}>
        <Button
          content="------"
          icon="id-card"
          mr={2}
          onClick={
            () => act('scan_card')
          } />
        {transaction_paid ? "This transaction has been processed successfully " : "Swipe your card to finish this transaction."}
      </NoticeBox>
    </Section>
  );
};

const UnlockedView = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    transaction_purpose,
    transaction_amount,
    linked_account,
  } = data;
  return (
    <Section title="Transation Settings" mt={1}>
      <LabeledList>
        <LabeledList.Item label="Transaction Purpose">
          <Button
            content={transaction_purpose}
            icon="edit"
            onClick={
              () => act('trans_purpose')
            } />
        </LabeledList.Item>
        <LabeledList.Item label="Value">
          <Button
            // Ternary required otherwise the 0 is offset weirdly
            content={transaction_amount ? transaction_amount : "0"}
            icon="edit"
            onClick={
              () => act('trans_value')
            } />
        </LabeledList.Item>
        <LabeledList.Item label="Linked Account">
          <Button
            content={linked_account ? linked_account : "None"}
            icon="edit"
            onClick={
              () => act('link_account')
            } />
        </LabeledList.Item>
        <LabeledList.Item label="Actions">
          <Button
            content="Lock in new transaction"
            icon="lock"
            onClick={
              () => act('toggle_lock')
            } />
          <Button
            content="Change access code"
            icon="key"
            onClick={
              () => act('change_code')
            } />
          <Button
            content="Reset access code"
            tooltip="Requires Captain, HoP or CC access"
            icon="sync-alt"
            onClick={
              () => act('reset')
            } />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

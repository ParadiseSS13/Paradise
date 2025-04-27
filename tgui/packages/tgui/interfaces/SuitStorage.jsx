import { Box, Button, Dimmer, Icon, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const SuitStorage = (props) => {
  const { data } = useBackend();
  const { uv } = data;
  return (
    <Window width={400} height={260}>
      <Window.Content>
        <Stack fill vertical>
          {!!uv && (
            <Dimmer backgroundColor="black" opacity={0.85}>
              <Stack>
                <Stack.Item bold textAlign="center" mb={1}>
                  <Icon name="spinner" spin={1} size={4} mb={4} />
                  <br />
                  Disinfection of contents in progress...
                </Stack.Item>
              </Stack>
            </Dimmer>
          )}
          <StoredItems />
          <OpenToggle />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const StoredItems = (props) => {
  const { act, data } = useBackend();
  const { helmet, suit, magboots, mask, storage, open, locked } = data;
  return (
    <Section
      fill
      title="Stored Items"
      buttons={
        <>
          <Button content="Start Disinfection Cycle" icon="radiation" textAlign="center" onClick={() => act('cook')} />
          <Button
            content={locked ? 'Unlock' : 'Lock'}
            icon={locked ? 'unlock' : 'lock'}
            disabled={open}
            onClick={() => act('toggle_lock')}
          />
        </>
      }
    >
      {open && !locked ? (
        <LabeledList>
          <ItemRow object={helmet} label="Helmet" missingText="helmet" eject="dispense_helmet" />
          <ItemRow object={suit} label="Suit" missingText="suit" eject="dispense_suit" />
          <ItemRow object={magboots} label="Boots" missingText="boots" eject="dispense_boots" />
          <ItemRow object={mask} label="Breathmask" missingText="mask" eject="dispense_mask" />
          <ItemRow object={storage} label="Storage" missingText="storage item" eject="dispense_storage" />
        </LabeledList>
      ) : (
        <Stack fill>
          <Stack.Item bold grow="1" textAlign="center" align="center" color="label">
            <Icon name={locked ? 'lock' : 'exclamation-circle'} size="5" mb={3} />
            <br />
            {locked ? 'The unit is locked.' : 'The unit is closed.'}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

const ItemRow = (props) => {
  const { act, data } = useBackend();
  const { object, label, missingText, eject } = props;
  return (
    <LabeledList.Item label={label}>
      <Box my={0.5}>
        {object ? (
          <Button my={-1} icon="eject" content={object} onClick={() => act(eject)} />
        ) : (
          <Box color="silver" bold>
            No {missingText} found.
          </Box>
        )}
      </Box>
    </LabeledList.Item>
  );
};

const OpenToggle = (props) => {
  const { act, data } = useBackend();
  const { open, locked } = data;
  return (
    <Section>
      <Button
        fluid
        content={open ? 'Close Suit Storage Unit' : 'Open Suit Storage Unit'}
        icon={open ? 'times-circle' : 'expand'}
        color={open ? 'red' : 'green'}
        disabled={locked}
        textAlign="center"
        onClick={() => act('toggle_open')}
      />
    </Section>
  );
};

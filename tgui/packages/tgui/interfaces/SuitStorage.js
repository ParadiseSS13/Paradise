import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Dimmer, Divider, Flex, Icon, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const SuitStorage = (props, context) => {
  const { data } = useBackend(context);
  const { uv } = data;
  return (
    <Window resizable>
      <Window.Content display="flex" className="Layout__content--flexColumn">
        {!!uv && (
          <Dimmer
            backgroundColor="black"
            opacity={0.85}>
            <Flex>
              <Flex.Item
                bold
                textAlign="center"
                mb={2}>
                <Icon
                  name="spinner"
                  spin={1}
                  size={4}
                  mb={4}
                /><br />
                Disinfection of contents in progress...
              </Flex.Item>
            </Flex>
          </Dimmer>
        )}
        <StoredItems />
        <OpenToggle />
      </Window.Content>
    </Window>
  );
};

const StoredItems = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    helmet,
    suit,
    magboots,
    mask,
    storage,
    open,
    locked,
  } = data;
  return (
    <Section
      title="Stored Items"
      flexGrow="1"
      buttons={
        <Fragment>
          <Button
            content="Start Disinfection Cycle"
            icon="radiation"
            textAlign="center"
            onClick={() => act('cook')}
          />
          <Button
            content={locked ? "Unlock" : "Lock"}
            icon={locked ? "unlock" : "lock"}
            disabled={open}
            onClick={() => act('toggle_lock')}
          />
        </Fragment>
      }>
      {(open && !locked) ? (
        <LabeledList>
          <ItemRow object={helmet} label="Helmet" missingText="helmet" eject="dispense_helmet" />
          <ItemRow object={suit} label="Suit" missingText="suit" eject="dispense_suit" />
          <ItemRow object={magboots} label="Boots" missingText="boots" eject="dispense_boots" />
          <ItemRow object={mask} label="Breathmask" missingText="mask" eject="dispense_mask" />
          <ItemRow object={storage} label="Storage" missingText="storage item" eject="dispense_storage" />
        </LabeledList>
      ) : (
        <Flex height="100%">
          <Flex.Item
            bold
            grow="1"
            textAlign="center"
            align="center"
            color="label">
            <Icon
              name={locked ? "lock" : "exclamation-circle"}
              size="5"
              mb={3}
            /><br />
            {locked ? "The unit is locked." : "The unit is closed."}
          </Flex.Item>
        </Flex>
      )}
    </Section>
  );
};

const ItemRow = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    object,
    label,
    missingText,
    eject,
  } = props;
  return (
    <LabeledList.Item label={label}>
      <Box my={0.5}>
        {object ? (
          <Button
            my={-1}
            icon="eject"
            content={object}
            onClick={() => act(eject)}
          />
        ) : (
          <Box color="silver" bold>
            No {missingText} found.
          </Box>
        )}
      </Box>
    </LabeledList.Item>
  );
};

const OpenToggle = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    open,
    locked,
  } = data;
  return (
    <Section>
      <Button
        fluid
        content={open ? "Close Suit Storage Unit" : "Open Suit Storage Unit"}
        icon={open ? "times-circle" : "expand"}
        color={open ? "red" : "green"}
        disabled={locked}
        textAlign="center"
        onClick={() => act('toggle_open')}
      />
    </Section>
  );
};

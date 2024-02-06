import { filter } from 'common/collections';
import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
} from '../../components';

export const pda_messenger = (props, context) => {
  const { act, data } = useBackend(context);
  const { active_convo } = data;

  if (active_convo) {
    return <ActiveConversation data={data} />;
  }
  return <MessengerList data={data} />;
};

export const ActiveConversation = (props, context) => {
  const { act } = useBackend(context);
  const data = props.data;

  const { convo_name, convo_job, messages, active_convo } = data;

  const [clipboardMode, setClipboardMode] = useLocalState(
    context,
    'clipboardMode',
    false
  );

  let body = (
    <Section
      fill
      scrollable
      title={'Conversation with ' + convo_name + ' (' + convo_job + ')'}
      buttons={
        <>
          <Button
            icon="eye"
            selected={clipboardMode}
            tooltip="Enter Clipboard Mode"
            tooltipPosition="bottom-start"
            onClick={() => setClipboardMode(!clipboardMode)}
          />
          <Button
            icon="comment"
            onClick={() => act('Message', { 'target': active_convo })}
            content="Reply"
          />
        </>
      }
    >
      {filter((im) => im.target === active_convo)(messages).map((im, i) => (
        <Box
          textAlign={im.sent ? 'right' : 'left'}
          position="relative"
          mb={1}
          key={i}
        >
          <Icon
            fontSize={2.5}
            color={im.sent ? '#4d9121' : '#cd7a0d'}
            position="absolute"
            left={im.sent ? null : '0px'}
            right={im.sent ? '0px' : null}
            bottom="-4px"
            style={{
              'z-index': '0',
              'transform': im.sent ? 'scale(-1, 1)' : null,
            }}
            name="comment"
          />
          <Box
            inline
            backgroundColor={im.sent ? '#4d9121' : '#cd7a0d'}
            p={1}
            maxWidth="100%"
            position="relative"
            textAlign={im.sent ? 'left' : 'right'}
            style={{
              'z-index': '1',
              'border-radius': '10px',
              'word-break': 'normal',
            }}
          >
            {im.sent ? 'You:' : 'Them:'} {im.message}
          </Box>
        </Box>
      ))}
    </Section>
  );

  if (clipboardMode) {
    body = (
      <Section
        fill
        scrollable
        title={'Conversation with ' + convo_name + ' (' + convo_job + ')'}
        buttons={
          <>
            <Button
              icon="eye"
              selected={clipboardMode}
              tooltip="Exit Clipboard Mode"
              tooltipPosition="bottom-start"
              onClick={() => setClipboardMode(!clipboardMode)}
            />
            <Button
              icon="comment"
              onClick={() => act('Message', { 'target': active_convo })}
              content="Reply"
            />
          </>
        }
      >
        {filter((im) => im.target === active_convo)(messages).map((im, i) => (
          <Box
            key={i}
            color={im.sent ? '#4d9121' : '#cd7a0d'}
            style={{
              'word-break': 'normal',
            }}
          >
            {im.sent ? 'You:' : 'Them:'} <Box inline>{im.message}</Box>
          </Box>
        ))}
      </Section>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item mb={0.5}>
        <LabeledList>
          <LabeledList.Item label="Messenger Functions">
            <Button.Confirm
              content="Delete Conversations"
              confirmContent="Are you sure?"
              icon="trash"
              confirmIcon="trash"
              onClick={() => act('Clear', { option: 'Convo' })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      {body}
    </Stack>
  );
};

export const MessengerList = (props, context) => {
  const { act } = useBackend(context);

  const data = props.data;

  const { convopdas, pdas, charges, silent, toff, ringtone_list, ringtone } =
    data;

  const [searchTerm, setSearchTerm] = useLocalState(context, 'searchTerm', '');

  return (
    <Stack fill vertical>
      <Stack.Item mb={5}>
        <LabeledList>
          <LabeledList.Item label="Messenger Functions">
            <Button
              selected={!silent}
              icon={silent ? 'volume-mute' : 'volume-up'}
              onClick={() => act('Toggle Ringer')}
            >
              Ringer: {silent ? 'Off' : 'On'}
            </Button>
            <Button
              color={toff ? 'bad' : 'green'}
              icon="power-off"
              onClick={() => act('Toggle Messenger')}
            >
              Messenger: {toff ? 'Off' : 'On'}
            </Button>
            <Button
              icon="trash"
              color="bad"
              onClick={() => act('Clear', { option: 'All' })}
            >
              Delete All Conversations
            </Button>
            <Button icon="bell" onClick={() => act('Ringtone')}>
              Set Custom Ringtone
            </Button>
            <Button>
              <Dropdown
                selected={ringtone}
                width="100px"
                options={Object.keys(ringtone_list)}
                onSelected={(value) =>
                  act('Available_Ringtones', { selected_ringtone: value })
                }
              />
            </Button>
          </LabeledList.Item>
        </LabeledList>
        {(!toff && (
          <Box>
            {!!charges && (
              <Box mt={0.5} mb={1}>
                <LabeledList>
                  <LabeledList.Item label="Cartridge Special Function">
                    {charges} charges left.
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            )}
            {(!convopdas.length && !pdas.length && (
              <Box>No current conversations</Box>
            )) || (
              <Box>
                Search:{' '}
                <Input
                  mt={0.5}
                  value={searchTerm}
                  onInput={(e, value) => {
                    setSearchTerm(value);
                  }}
                />
              </Box>
            )}
          </Box>
        )) || <Box color="bad">Messenger Offline.</Box>}
      </Stack.Item>
      <PDAList
        title="Current Conversations"
        data={data}
        pdas={convopdas}
        msgAct="Select Conversation"
        searchTerm={searchTerm}
      />
      <PDAList
        title="Other PDAs"
        pdas={pdas}
        msgAct="Message"
        data={data}
        searchTerm={searchTerm}
      />
    </Stack>
  );
};

const PDAList = (props, context) => {
  const { act } = useBackend(context);
  const data = props.data;

  const { pdas, title, msgAct, searchTerm } = props;

  const { charges, plugins } = data;

  if (!pdas || !pdas.length) {
    return <Section title={title}>No PDAs found.</Section>;
  }

  return (
    <Section fill scrollable title={title}>
      {pdas
        .filter((pda) => {
          return pda.Name.toLowerCase().includes(searchTerm.toLowerCase());
        })
        .map((pda) => (
          <Stack key={pda.uid} m={0.5}>
            <Stack.Item grow>
              <Button
                fluid
                icon="arrow-circle-down"
                content={pda.Name}
                onClick={() => act(msgAct, { target: pda.uid })}
              />
            </Stack.Item>
            <Stack.Item>
              {!!charges &&
                plugins.map((plugin) => (
                  <Button
                    key={plugin.uid}
                    icon={plugin.icon}
                    content={plugin.name}
                    onClick={() =>
                      act('Messenger Plugin', {
                        plugin: plugin.uid,
                        target: pda.uid,
                      })
                    }
                  />
                ))}
            </Stack.Item>
          </Stack>
        ))}
    </Section>
  );
};

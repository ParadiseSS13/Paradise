import { filter } from 'common/collections';
import { useBackend, useLocalState } from "../../backend";
import { Box, Button, Icon, Input, LabeledList, Section } from "../../components";

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

  const {
    convo_name,
    convo_job,
    messages,
    active_convo,
  } = data;

  const [
    clipboardMode,
    setClipboardMode,
  ] = useLocalState(context, 'clipboardMode', false);

  let body = (
    <Box>
      <Button
        content="Back"
        icon="arrow-left"
        onClick={() => act("Back")} />
      <Section
        level={2}
        title={"Conversation with " + convo_name + " (" + convo_job + ")"}
        buttons={
          <Button
            icon="eye"
            selected={clipboardMode}
            tooltip="Enter Clipboard Mode"
            tooltipPosition="bottom-left"
            onClick={() => setClipboardMode(!clipboardMode)} />
        }
        height="415px"
        stretchContents>
        <Section height="97%" overflowY="auto">
          {filter(im => im.target === active_convo)(messages).map((im, i) => (
            <Box
              textAlign={im.sent ? "right" : "left"}
              position="relative"
              mb={1}
              key={i}>
              <Icon
                fontSize={2.5}
                color={im.sent ? "#3e6189" : "#565656"}
                position="absolute"
                left={im.sent ? null : "0px"}
                right={im.sent ? "0px" : null}
                bottom="-5px"
                style={{
                  "z-index": "0",
                  "transform": im.sent ? "scale(-1, 1)" : null,
                }}
                name="comment" />
              <Box
                inline
                backgroundColor={im.sent ? "#3e6189" : "#565656"}
                p={1}
                maxWidth="100%"
                position="relative"
                textAlign="left"
                style={{
                  "z-index": "1",
                  "border-radius": "5px",
                  "word-break": "normal",
                  "word-wrap": "break-word",
                }}>
                {im.message}
              </Box>
            </Box>
          ))}
        </Section>
        <Box textAlign="right">
          <Button
            mt={1}
            icon="comment"
            onClick={() => act("Message", { "target": active_convo })}
            content="Reply" />
        </Box>
      </Section>
    </Box>
  );

  if (clipboardMode) {
    body = (
      <Box>
        <Button
          content="Back"
          icon="arrow-left"
          onClick={() => act("Back")} />
        <Section
          level={2}
          title={"Conversation with " + convo_name + " (" + convo_job + ")"}
          buttons={
            <Button
              icon="eye"
              selected={clipboardMode}
              tooltip="Exit Clipboard Mode"
              tooltipPosition="bottom-left"
              onClick={() => setClipboardMode(!clipboardMode)} />
          }
          height="415px"
          stretchContents>
          <Section style={{
            "height": "97%",
            "overflow-y": "auto",
          }}>
            {filter(im => im.target === active_convo)(messages).map((im, i) => (
              <Box
                key={i}
                color={im.sent ? "#2185d0" : "#aaaaaa"}
                style={{
                  "word-break": "normal",
                }}>
                {im.sent ? "You:" : "Them:"} {im.message}
              </Box>
            ))}
          </Section>
          <Box textAlign="right">
            <Button
              mt={1}
              icon="comment"
              onClick={() => act("Message", { "target": active_convo })}
              content="Reply" />
          </Box>
        </Section>
      </Box>
    );
  }

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Messenger Functions">
          <Button
            icon="trash"
            color="bad"
            onClick={() => act("Clear", { option: "Convo" })}>
            Delete Conversations
          </Button>
        </LabeledList.Item>
      </LabeledList>
      {body}
    </Box>
  );
};

export const MessengerList = (props, context) => {
  const { act } = useBackend(context);
  const data = props.data;

  const {
    convopdas,
    pdas,
    charges,
    silent,
    toff,
  } = data;

  const [
    searchTerm,
    setSearchTerm,
  ] = useLocalState(context, 'searchTerm', '');

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Messenger Functions">
          <Button
            selected={!silent}
            icon={silent ? "volume-mute" : "volume-up"}
            onClick={() => act("Toggle Ringer")}>
            Ringer: {silent ? "Off" : "On"}
          </Button>
          <Button
            color={toff ? "bad" : "green"}
            icon="power-off"
            onClick={() => act("Toggle Messenger")}>
            Messenger: {toff ? "Off" : "On"}
          </Button>
          <Button
            icon="bell"
            onClick={() => act("Ringtone")}>
            Set Ringtone
          </Button>
          <Button
            icon="trash"
            color="bad"
            onClick={() => act("Clear", { option: "All" })}>
            Delete All Conversations
          </Button>
        </LabeledList.Item>
      </LabeledList>
      {!toff && (
        <Box mt={2}>
          {!!charges && (
            <LabeledList>
              <LabeledList.Item label="Cartridge Special Function">
                {charges} charges left.
              </LabeledList.Item>
            </LabeledList>
          )}
          {!convopdas.length && !pdas.length && (
            <Box>
              No current conversations
            </Box>
          ) || (
            <Box>
              Search: <Input value={searchTerm} onInput={(e, value) => { setSearchTerm(value); }} />
              <PDAList title="Current Conversations" data={data}
                pdas={convopdas}
                msgAct="Select Conversation"
                searchTerm={searchTerm} />
              <PDAList title="Other PDAs" pdas={pdas} msgAct="Message" data={data} searchTerm={searchTerm} />
            </Box>
          )}
        </Box>
      ) || (
        <Box color="bad">
          Messenger Offline.
        </Box>
      )}
    </Box>
  );
};

const PDAList = (props, context) => {
  const { act } = useBackend(context);
  const data = props.data;

  const {
    pdas,
    title,
    msgAct,
    searchTerm,
  } = props;

  const {
    charges,
    plugins,
  } = data;

  if (!pdas || !pdas.length) {
    return (
      <Section level={2} title={title}>
        No PDAs found.
      </Section>
    );
  }

  return (
    <Section level={2} title={title}>
      {pdas
        .filter(pda => { return pda.Name.toLowerCase().includes(searchTerm.toLowerCase()); })
        .map(pda => (
          <Box key={pda.uid}>
            <Button
              icon="arrow-circle-down"
              content={pda.Name}
              onClick={() => act(msgAct, { target: pda.uid })} />
            {!!charges && plugins.map(plugin => (
              <Button
                key={plugin.uid}
                icon={plugin.icon}
                content={plugin.name}
                onClick={() => act("Messenger Plugin", {
                  plugin: plugin.uid,
                  target: pda.uid,
                })} />
            ))}
          </Box>
        ))}
    </Section>
  );
};

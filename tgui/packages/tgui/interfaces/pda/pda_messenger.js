import { filter } from 'common/collections';
import { useBackend, useLocalState } from "../../backend";
import { Box, Button, Icon, LabeledList, Section } from "../../components";

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
        height="450px"
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
                color={im.sent ? "#4d9121" : "#cd7a0d"}
                position="absolute"
                left={im.sent ? null : "0px"}
                right={im.sent ? "0px" : null}
                bottom="-4px"
                style={{
                  "z-index": "0",
                  "transform": im.sent ? "scale(-1, 1)" : null,
                }}
                name="comment" />
              <Box
                inline
                backgroundColor={im.sent ? "#4d9121" : "#cd7a0d"}
                p={1}
                maxWidth="100%"
                position="relative"
                textAlign={im.sent ? "left" : "right"}
                style={{
                  "z-index": "1",
                  "border-radius": "10px",
                  "word-break": "normal",
                }}>
                {im.sent ? "You:" : "Them:"} {im.message}
              </Box>
            </Box>
          ))}
        </Section>
        <Button
          mt={1}
          icon="comment"
          onClick={() => act("Message", { "target": active_convo })}
          content="Reply" />
      </Section>
    </Box>
  );

  if (clipboardMode) {
    body = (
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
        height="450px"
        stretchContents>
        <Section style={{
          "height": "97%",
          "overflow-y": "auto",
        }}>
          {filter(im => im.target === active_convo)(messages).map((im, i) => (
            <Box
              key={i}
              color={im.sent ? "#4d9121" : "#cd7a0d"}
              style={{
                "word-break": "normal",
              }}>
              {im.sent ? "You:" : "Them:"} <Box inline>{im.message}</Box>
            </Box>
          ))}
        </Section>
        <Button
          mt={1}
          icon="comment"
          onClick={() => act("Message", { "target": active_convo })}
          content="Reply" />
      </Section>
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
              <PDAList title="Current Conversations" data={data}
                pdas={convopdas}
                msgAct="Select Conversation" />
              <PDAList title="Other PDAs" pdas={pdas} msgAct="Message" data={data} />
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
      {pdas.map(pda => (
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

import { useBackend } from "../../backend";
import { Box, Button, LabeledList, Section } from "../../components";

export const pda_secbot = (props, context) => {
  const { act, data } = useBackend(context);
  const { beepsky } = data;
  const {
    active,
  } = beepsky;

  return (
    <Box>
      {active ? (
        <BotStatus />
      ) : (
        <BotList />
      )}
    </Box>
  );
};

const BotList = (props, context) => {
  const { act, data } = useBackend(context);
  const { beepsky } = data;
  const {
    bots,
  } = beepsky;

  return (
    <Box>
      {bots.map(b => (
        <Box key={b.Name}>
          <Button
            content={b.Name}
            icon="cog"
            onClick={() => act('AccessBot', { uid: b.uid })}
          />
        </Box>
      ))}
      <Box mt={2}>
        <Button
          fluid
          icon="rss"
          content="Re-scan for bots"
          onClick={() => act('Rescan')}
        />
      </Box>
    </Box>
  );
};


const BotStatus = (props, context) => {
  const { act, data } = useBackend(context);
  // Why are these things like 3 layers deep
  const { beepsky } = data;
  const {
    botstatus,
    active,
  } = beepsky;

  const {
    mode,
    loca,
  } = botstatus;

  let statusText;
  switch (mode) {
    case 0:
      statusText = "Ready";
      break;
    case 1:
      statusText = "Apprehending target";
      break;
    case 2:
    case 3:
      statusText = "Arresting target";
      break;
    case 4:
      statusText = "Starting patrol";
      break;
    case 5:
      statusText = "On patrol";
      break;
    case 6:
      statusText = "Responding to summons";
      break;
  }

  return (
    <Section title={active}>
      {mode === -1 && (
        <Box color="red" bold>
          Waiting for response...
        </Box>
      )}
      <LabeledList>
        <LabeledList.Item label="Location">
          {loca}
        </LabeledList.Item>
        <LabeledList.Item label="Status">
          {statusText}
        </LabeledList.Item>
        <LabeledList.Item label="Controls">
          <Button
            content="Go"
            icon="play"
            onClick={() => act('Go')}
          />
          <Button
            content="Stop"
            icon="stop"
            onClick={() => act('Stop')}
          />
          <Button
            content="Summon"
            icon="arrow-down"
            onClick={() => act('Summon')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

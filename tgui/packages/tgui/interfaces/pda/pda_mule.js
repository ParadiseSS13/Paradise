import { useBackend } from "../../backend";
import { Box, Button, LabeledList, Section } from "../../components";

export const pda_mule = (props, context) => {
  const { act, data } = useBackend(context);
  const { mulebot } = data;
  const {
    active,
  } = mulebot;

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
  const { mulebot } = data;
  const {
    bots,
  } = mulebot;

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
  const { mulebot } = data;
  const {
    botstatus,
    active,
  } = mulebot;

  const {
    mode,
    loca,
    load,
    powr,
    dest,
    home,
    retn,
    pick,
  } = botstatus;

  let statusText;
  switch (mode) {
    case 0:
      statusText = "Ready";
      break;
    case 1:
      statusText = "Loading/Unloading";
      break;
    case 2:
    case 12:
      statusText = "Navigating to delivery location";
      break;
    case 3:
      statusText = "Navigating to Home";
      break;
    case 4:
      statusText = "Waiting for clear path";
      break;
    case 5:
    case 6:
      statusText = "Calculating navigation path";
      break;
    case 7:
      statusText = "Unable to locate destination";
      break;
    default:
      statusText = mode;
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
        <LabeledList.Item label="Power">
          {powr}%
        </LabeledList.Item>
        <LabeledList.Item label="Home">
          {home}
        </LabeledList.Item>
        <LabeledList.Item label="Destination">
          <Button
            content={dest ? dest + " (Set)" : "None (Set)"}
            onClick={() => act('SetDest')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Current Load">
          <Button
            content={load ? load + " (Unload)" : "None"}
            disabled={!load}
            onClick={() => act('Unload')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Auto Pickup">
          <Button
            content={pick ? "Yes" : "No"}
            selected={pick}
            onClick={() => act('SetAutoPickup', {
              autoPickupType: pick ? "pickoff" : "pickon",
            })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Auto Return">
          <Button
            content={retn ? "Yes" : "No"}
            selected={retn}
            onClick={() => act('SetAutoReturn', {
              autoReturnType: retn ? "retoff" : "reton",
            })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Controls">
          <Button
            content="Stop"
            icon="stop"
            onClick={() => act('Stop')}
          />
          <Button
            content="Proceed"
            icon="play"
            onClick={() => act('Start')}
          />
          <Button
            content="Return Home"
            icon="home"
            onClick={() => act('ReturnHome')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

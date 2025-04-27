import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const pda_mule = (props) => {
  const { act, data } = useBackend();
  const { mulebot } = data;
  const { active } = mulebot;

  return <Box>{active ? <BotStatus /> : <BotList />}</Box>;
};

const BotList = (props) => {
  const { act, data } = useBackend();
  const { mulebot } = data;
  const { bots } = mulebot;

  return bots.map((b) => (
    <Box key={b.Name}>
      <Button content={b.Name} icon="cog" onClick={() => act('control', { bot: b.uid })} />
    </Box>
  ));
};

const BotStatus = (props) => {
  const { act, data } = useBackend();
  // Why are these things like 3 layers deep
  const { mulebot } = data;
  const { botstatus, active } = mulebot;

  const { mode, loca, load, powr, dest, home, retn, pick } = botstatus;

  let statusText;
  switch (mode) {
    case 0:
      statusText = 'Ready';
      break;
    case 1:
      statusText = 'Loading/Unloading';
      break;
    case 2:
    case 12:
      statusText = 'Navigating to delivery location';
      break;
    case 3:
      statusText = 'Navigating to Home';
      break;
    case 4:
      statusText = 'Waiting for clear path';
      break;
    case 5:
    case 6:
      statusText = 'Calculating navigation path';
      break;
    case 7:
      statusText = 'Unable to locate destination';
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
        <LabeledList.Item label="Location">{loca}</LabeledList.Item>
        <LabeledList.Item label="Status">{statusText}</LabeledList.Item>
        <LabeledList.Item label="Power">{powr}%</LabeledList.Item>
        <LabeledList.Item label="Home">{home}</LabeledList.Item>
        <LabeledList.Item label="Destination">
          <Button content={dest ? dest + ' (Set)' : 'None (Set)'} onClick={() => act('target')} />
        </LabeledList.Item>
        <LabeledList.Item label="Current Load">
          <Button content={load ? load + ' (Unload)' : 'None'} disabled={!load} onClick={() => act('unload')} />
        </LabeledList.Item>
        <LabeledList.Item label="Auto Pickup">
          <Button
            content={pick ? 'Yes' : 'No'}
            selected={pick}
            onClick={() =>
              act('set_pickup_type', {
                // Using just ! doesnt work here, because !null is still null
                autopick: pick ? 0 : 1,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Auto Return">
          <Button
            content={retn ? 'Yes' : 'No'}
            selected={retn}
            onClick={() =>
              act('set_auto_return', {
                // Using just ! doesnt work here, because !null is still null
                autoret: retn ? 0 : 1,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Controls">
          <Button content="Stop" icon="stop" onClick={() => act('stop')} />
          <Button content="Proceed" icon="play" onClick={() => act('start')} />
          <Button content="Return Home" icon="home" onClick={() => act('home')} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon, Stack, Table, Tabs } from '../components';
import { Window } from '../layouts';
let bot_model = 'Securitron';

const BotStatus = (mode) => {
  if (mode === 0) {
    // Idle
    return <Box color="green">Idle</Box>;
  }
  if (mode >= 1 && mode <= 3) {
    // Secbot Arrest
    return <Box color="yellow">Arresting</Box>;
  }
  if (mode === 4 || mode === 5) {
    return <Box color="average">Patrolling</Box>;
  }
  if (mode === 6) {
    return <Box color="green">Responding</Box>;
  }
  if (mode >= 7 && mode <= 19) {
    return <Box color="blue">Working</Box>;
  }
};

export const BotCall = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const botNames = {
    0: 'Security',
    1: 'Medibot',
    2: 'Cleanbot',
    3: 'Floorbot',
    4: 'MULE',
    5: 'Honkbot',
    10: 'Securitron',
    11: 'ED-209',
  };
  const decideTab = (index) => {
    switch (index) {
      case 0:
        bot_model = 'Securitron';
        return <SecurityTab />;
      case 1:
        bot_model = 'Medibot';
        return <BotExists />;
      case 2:
        bot_model = 'Cleanbot';
        return <BotExists />;
      case 3:
        bot_model = 'Floorbot';
        return <BotExists />;
      case 4:
        bot_model = 'MULE';
        return <BotExists />;
      case 5:
        bot_model = 'Honkbot';
        return <BotExists />;
      case 10:
        bot_model = 'Securitron';
        return <SecurityTab />;
      case 11:
        bot_model = 'ED-209';
        return <SecurityTab />;
      default:
        return 'This should not happen. Report on Paradise Github';
    }
  };

  return (
    <Window width={700} height={400}>
      <Window.Content scrollable={tabIndex === 0}>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid textAlign="center">
              {Array.from({ length: 6 }).map((_, index) => (
                <Tabs.Tab
                  key={index}
                  selected={tabIndex === index}
                  onClick={() => setTabIndex(index)}
                >
                  {botNames[index]}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          {decideTab(tabIndex)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BotExists = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { bots } = data;
  if (bots[bot_model] !== undefined) {
    return <MapBot />;
  } else {
    return <NoBot />;
  }
};

const NoBot = (_properties, context) => {
  const { act, data } = useBackend(context);
  return (
    <Stack justify="center" align="center" fill vertical>
      <Box bold={1} color="bad">
        No {bot_model} detected
      </Box>
    </Stack>
  );
};

const SecurityTab = (_properties, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs fluid textAlign="center">
          <Tabs.Tab
            key="Security"
            selected={tabIndex === 10}
            onClick={() => setTabIndex(10)}
          >
            Securitron
          </Tabs.Tab>
          <Tabs.Tab
            bot_type="ED-209"
            key="ED-209"
            selected={tabIndex === 11}
            onClick={() => setTabIndex(11)}
          >
            ED-209
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <BotExists />
    </Stack>
  );
};

const MapBot = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { bots } = data;

  return (
    <Stack fill vertical scrollable>
      <Stack.Item>
        <Table m="0.5rem">
          <Table.Row header>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>Model</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Location</Table.Cell>
            <Table.Cell>Interface</Table.Cell>
            <Table.Cell>Call</Table.Cell>
          </Table.Row>
          {bots[bot_model].map((bot) => (
            <Table.Row key={bot.UID}>
              <Table.Cell>{bot.name}</Table.Cell>
              <Table.Cell>{bot.model}</Table.Cell>
              <Table.Cell>
                {bot.on ? BotStatus(bot.status) : <Box color="red">Off</Box>}
              </Table.Cell>
              <Table.Cell>{bot.location}</Table.Cell>
              <Table.Cell>
                <Button
                  content="Interface"
                  onClick={() =>
                    act('interface', {
                      botref: bot.UID,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Call"
                  onClick={() =>
                    act('call', {
                      botref: bot.UID,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Stack.Item>
    </Stack>
  );
};

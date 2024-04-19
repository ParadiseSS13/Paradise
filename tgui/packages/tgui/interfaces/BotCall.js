import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon, Stack, Table, Tabs } from '../components';
import { Window } from '../layouts';
let bot_model = 'Security';

const BotStatus = (mode) => {
  const statusMap = [
    { modeRange: [0], label: 'Idle', color: 'green' },
    { modeRange: [1, 2, 3], label: 'Arresting', color: 'yellow' },
    { modeRange: [4, 5], label: 'Patrolling', color: 'average' },
    { modeRange: [6, 11], label: 'Responding', color: 'green' },
    { modeRange: [12], label: 'Delivering Cargo', color: 'blue' },
    { modeRange: [13], label: 'Returning Home', color: 'blue' },
    { modeRange: [7, 14, 15, 16, 17, 18, 19], label: 'Working', color: 'blue' },
  ];

  const matchedStatus = statusMap.find((mapping) =>
    mapping.modeRange.includes(mode)
  );

  return <Box color={matchedStatus.color}> {matchedStatus.label} </Box>;
};

export const BotCall = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const botNames = {
    0: 'Security',
    1: 'Medibot',
    2: 'Cleanbot',
    3: 'Floorbot',
    4: 'Mule',
    5: 'Honkbot',
  };
  const decideTab = (index) => {
    switch (index) {
      case 0:
        bot_model = 'Security';
        return <BotExists />;
      case 1:
        bot_model = 'Medical';
        return <BotExists />;
      case 2:
        bot_model = 'Clean';
        return <BotExists />;
      case 3:
        bot_model = 'Floor';
        return <BotExists />;
      case 4:
        bot_model = 'Mule';
        return <BotExists />;
      case 5:
        bot_model = 'Honk';
        return <BotExists />;
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

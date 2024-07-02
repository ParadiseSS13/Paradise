import { useBackend, useLocalState } from '../backend';
import { Box, Button, Stack, Table, Tabs } from '../components';
import { Window } from '../layouts';

const BotStatus = (mode) => {
  const statusMap = [
    // magic numbers are from bots.dm under mode defines
    { modes: [0], label: 'Idle', color: 'green' },
    { modes: [1, 2, 3], label: 'Arresting', color: 'yellow' },
    { modes: [4, 5], label: 'Patrolling', color: 'average' },
    { modes: [9], label: 'Moving', color: 'average' },
    { modes: [6, 11], label: 'Responding', color: 'green' },
    { modes: [12], label: 'Delivering Cargo', color: 'blue' },
    { modes: [13], label: 'Returning Home', color: 'blue' },
    {
      modes: [7, 8, 10, 14, 15, 16, 17, 18, 19],
      label: 'Working',
      color: 'blue',
    },
  ];

  const matchedStatus = statusMap.find((mapping) => mapping.modes.includes(mode));

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
    return botNames[index] ? (
      <BotExists model={botNames[index]} />
    ) : (
      'This should not happen. Report on Paradise Github'
    );
  };

  return (
    <Window width={700} height={400}>
      <Window.Content scrollable={tabIndex === 0}>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid textAlign="center">
              {Array.from({ length: 6 }).map((_, index) => (
                <Tabs.Tab key={index} selected={tabIndex === index} onClick={() => setTabIndex(index)}>
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

const BotExists = (props, context) => {
  const { act, data } = useBackend(context);
  const { bots } = data;
  if (bots[props.model] !== undefined) {
    return <MapBot model={[props.model]} />;
  } else {
    return <NoBot model={[props.model]} />;
  }
};

const NoBot = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Stack justify="center" align="center" fill vertical>
      <Box bold={1} color="bad">
        No {[props.model]} detected
      </Box>
    </Stack>
  );
};

const MapBot = (props, context) => {
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
          {bots[props.model].map((bot) => (
            <Table.Row key={bot.UID}>
              <Table.Cell>{bot.name}</Table.Cell>
              <Table.Cell>{bot.model}</Table.Cell>
              <Table.Cell>{bot.on ? BotStatus(bot.status) : <Box color="red">Off</Box>}</Table.Cell>
              <Table.Cell>{bot.location}</Table.Cell>
              <Table.Cell>
                <Button content="Interface" onClick={() => act('interface', { botref: bot.UID })} />
              </Table.Cell>
              <Table.Cell>
                <Button content="Call" onClick={() => act('call', { botref: bot.UID })} />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Stack.Item>
    </Stack>
  );
};

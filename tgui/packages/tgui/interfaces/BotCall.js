import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon, Table, Tabs } from '../components';
import { TableCell } from '../components/Table';
import { Window } from '../layouts';
let bot_type;
// export const BotClean = (props, context) => {
//   const { act, data } = useBackend(context);
//   const {
//     name,
//     area,
//     mode,
//     model,
//   } = data;
//   return (
//     <Window resizable>
//       <Window.Content scrollable>
//         <Tabs>
//           <Tabs.Tab>
//
//           </Tabs.Tab>
//         </Tabs>
//       </Window.Content>
//     </Window>
//   );
// };

// Status from bots.dm

const BotActive = (on) => {
  if (on) {
    return 'red';
  } else {
    return 'green';
  }
};

const BotStatus = (mode) => {
  if (mode === 0) {
    // Idle
    return 'Idle';
  }
  if (mode >= 1 && mode <= 3) {
    // Secbot Arrest
    return 'Arresting';
  }
  if (mode === 4 || mode === 5) {
    return 'Patrolling';
  }
  if (mode === 6) {
    return 'Responding';
  }
  if (mode >= 7 && mode <= 19) {
    return 'Working';
  }
};

export const BotCall = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <BotView />;
      case 1:
        return <BotView />;
      default:
        return 'This should not happen. Report on Paradise Github'; // Blatant copy past from atmos UI
    }
  };

  return (
    <Window width={700} height={400}>
      <Window.Content scrollable={tabIndex === 0}>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab
              bot_type="Securitron"
              key="Securitron"
              selected={tabIndex === 0}
              onClick={() => setTabIndex(0)}
            >
              Securitron
            </Tabs.Tab>
            <Tabs.Tab
              bot_type="Medibot"
              key="Medibot"
              selected={tabIndex === 1}
              onClick={() => setTabIndex(1)}
            >
              Medibot
            </Tabs.Tab>
            <Tabs.Tab
              bot_type="Cleanbot"
              key="Cleanbot"
              selected={tabIndex === 2}
              onClick={() => setTabIndex(2)}
            >
              Cleanbot
            </Tabs.Tab>
            <Tabs.Tab
              bot_type="Floorbot"
              key="Floorbot"
              selected={tabIndex === 3}
              onClick={() => setTabIndex(3)}
            >
              Floorbot
            </Tabs.Tab>
            <Tabs.Tab
              bot_type="MULE"
              key="Mule"
              selected={tabIndex === 4}
              onClick={() => setTabIndex(4)}
            >
              Mule
            </Tabs.Tab>
            <Tabs.Tab
              bot_type="Honkbot"
              key="Misc"
              selected={tabIndex === 5}
              onClick={() => setTabIndex(5)}
            >
              Misc
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

const BotView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { bots } = data;

  return (
    <Box>
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Model</Table.Cell>
          <Table.Cell>Status</Table.Cell>
          <Table.Cell>Location</Table.Cell>
          <Table.Cell>Interface</Table.Cell>
          <Table.Cell>Call</Table.Cell>
        </Table.Row>
        {bots[bot_type].map((bot) => (
          <Table.Row key={bot.UID}>
            <TableCell>{bot.model}</TableCell>
            <TableCell>{bot.model}</TableCell>
            <TableCell>{BotStatus(bot.status)}</TableCell>
            <TableCell>{bot.location !== undefined && (bot.location)}</TableCell>
            <TableCell>
              <Button
                content="Interface"
                onClick={() =>
                  act('interface', {
                    UID: bot.UID,
                  })
                }
              />
            </TableCell>
            <TableCell>
              <Button
                content="Call"
                onClick={() =>
                  act('call', {
                    UID: bot.UID,
                  })
                }
              />
            </TableCell>
          </Table.Row>
        ))}
      </Table>
    </Box>
  );
};

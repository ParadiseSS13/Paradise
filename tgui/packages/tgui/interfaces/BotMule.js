import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Box, Section, Tabs, Stack } from '../components';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotMule = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <BotStatus />;
      case 1:
        return <MuleLoad />;
      default:
        return 'Whoops!!';
    }
  };
  return (
    <Window width={800} height={600}>
      <Window.Content>
        <Stack fill vertical fillPositionedParent>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                key="BotStatus"
                icon="signal"
                selected={0 === tabIndex}
                onClick={() => setTabIndex(0)}
              >
                Status
              </Tabs.Tab>
              <Tabs.Tab
                key="CargoLoad"
                icon="truck"
                selected={1 === tabIndex}
                onClick={() => setTabIndex(1)}
              >
                Cargo
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          {decideTab(tabIndex)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MuleLoad = (props, context) => {
  const { act, data } = useBackend(context);
  const { mode, load, destination, cell } = data;
  return (
    <Window width={500} heiht={510}>
      <Window.Content scrollable>
        <Section>
          <Box>
            <LabeledList title="test">{cell}</LabeledList>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

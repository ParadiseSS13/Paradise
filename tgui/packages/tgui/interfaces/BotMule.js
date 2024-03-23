import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Box,
  Section,
  Tabs,
  Stack,
  Flex,
  NoticeBox,
  Icon,
} from '../components';
import { IconStack } from '../components/Icon';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotMule = (props, context) => {
  const { act, data } = useBackend(context);
  const { cell } = data;
  if (cell) {
    return <MuleMain />;
  } else {
    return <HasCell />;
  }
};

const HasCell = (props, context) => {
  const { act, data } = useBackend(context);
  const { cell } = data;
  return (
    <Window width={500} height={500}>
      <Stack justify="center" align="center" height="100%">
        <Icon.Stack>
          <Icon size="3" name="slash" />
          <Icon size="3" name="battery-quarter" />
        </Icon.Stack>
        <Box bold={1} color="bad">
          Please Insert Battery
        </Box>
      </Stack>
    </Window>
  );
};

const MuleMain = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <BotStatus />;
      case 1:
        return <MuleLoad />;
      default:
        return 'Whoops!! This is a bug. Please report to Paradise Github';
    }
  };

  return (
    <Window width={500} height={500}>
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
  const {
    noaccess,
    painame,
    mode,
    load,
    destination,
    cell,
    auto_pickup,
    auto_return,
    stop,
    go,
    home,
    setid,
    sethome,
    unload,
  } = data;
  return (
    <Section fill scrollable backgroundColor="transparent">
      <Section title="Delivery Settings">
        <Button
          icon=""
          content={destination ? destination : 'Select Destination'}
          selected={destination}
          disabled={noaccess}
          onClick={() => act('destination')}
        />
      </Section>
      <Section title="Movement Settings">
        <Stack direction="row">
          <Button
            icon="location-arrow"
            content="Go"
            selected={go}
            disabled={noaccess}
            onClick={() => act('go')}
          />
          <Button
            icon="location-arrow"
            content="Home"
            selected={home}
            disabled={noaccess}
            onClick={() => act('home')}
          />
          <Button
            icon="stop"
            content="Stop"
            selected={stop}
            disabled={noaccess}
            color="bad"
            onClick={() => act('stop')}
          />
        </Stack>
      </Section>
    </Section>
  );
};

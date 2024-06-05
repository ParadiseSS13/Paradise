import { useBackend, useLocalState } from '../backend';
import {
  Button,
  ButtonCheckbox,
  LabeledList,
  Box,
  Section,
  Tabs,
  Stack,
  Flex,
  NoticeBox,
  Icon,
  IconStack,
} from '../components';
import { Window } from '../layouts';
import { BotStatus } from './common/BotStatus';

export const BotMule = (props, context) => {
  const { act, data } = useBackend(context);
  const { cell } = data;
  if (cell) {
    return <MuleMain />;
  } else {
    return <NoCell />;
  }
};

const NoCell = (props, context) => {
  const { act, data } = useBackend(context);
  const { cell } = data;
  return (
    <Window width={500} height={500}>
      <Stack justify="center" align="center" fill vertical>
        <Icon.Stack>
          <Icon size="5" name="slash" />
          <Icon size="5" name="battery-quarter" />
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
        return <MuleStatus />;
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

const MuleStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    noaccess,
    mode,
    destination,
    auto_pickup,
    auto_return,
    sethome,
    unload,
    bot_suffix,
    set_home,
  } = data;
  return (
    <Section fill scrollable>
      <BotStatus />
      <Section title="Delivery Settings">
        <Button.Checkbox
          fluid
          checked={auto_pickup}
          content="Auto Pickup"
          disabled={noaccess}
          onClick={() => act('auto_pickup')}
        />
        <Button.Checkbox
          fluid
          checked={auto_return}
          content="Auto Return"
          disabled={noaccess}
          onClick={() => act('auto_return')}
        />
        <Button.Checkbox
          fluid
          content="Change ID"
          onClick={() => act('setid')}
        />
        <Button.Checkbox fluid content="Set Home" />
        <LabeledList mb={1}>
          <LabeledList.Item label="Home">{set_home}</LabeledList.Item>
        </LabeledList>
      </Section>
    </Section>
  );
};

const MuleLoad = (props, context) => {
  const { act, data } = useBackend(context);
  const { noaccess, mode, load, destination, cargo_IMG } = data;
  return (
    <Section fill scrollable>
      {cargo_IMG !== undefined ? (
        <img
          src={`data:image/jpeg;base64,${cargo_IMG}`}
          style={{
            height: '20%',
            width: '20%',
            'float': 'right',
            'vertical-align': 'middle',
            '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
            'image-rendering': 'pixelated',
          }}
        />
      ) : (
        <Box bold={1}>No Cargo</Box>
      )}
      <Section title="Delivery Settings">
        <Button
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
            disabled={noaccess}
            onClick={() => act('go')}
          />
          <Button
            icon="home"
            content="Return Home"
            disabled={noaccess}
            onClick={() => act('home')}
          />
          <Button
            icon="stop"
            content="Stop"
            disabled={noaccess}
            color="bad"
            onClick={() => act('stop')}
          />
        </Stack>
        <Stack>
          <Button
            icon="stop"
            content="Unload"
            disabled={noaccess || load === 'None'}
            color="bad"
            onClick={() => act('unload')}
          />
        </Stack>
      </Section>
    </Section>
  );
};

import { Box, Button, Icon, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
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
    <Window width={500} height={400}>
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
  const [tabIndex, setTabIndex] = useLocalState(context, 0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <MuleStatus />;
      case 1:
        return <MuleLoad />;
      default:
        return 'Something went wrong. Report it on Paradise Github';
    }
  };

  return (
    <Window width={500} height={400}>
      <Window.Content>
        <Tabs>
          <Tabs.Tab key="BotStatus" icon="signal" selected={0 === tabIndex} onClick={() => setTabIndex(0)}>
            Status
          </Tabs.Tab>
          <Tabs.Tab key="CargoLoad" icon="truck" selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
            Cargo
          </Tabs.Tab>
          <Button fluid content="Refresh" icon="rotate-right" verticalAlign="middle" onClick={() => act('refresh')} />
        </Tabs>
        {decideTab(tabIndex)}
      </Window.Content>
    </Window>
  );
};

const MuleStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const { noaccess, auto_pickup, auto_return, sethome, bot_suffix, set_home, report } = data;
  return (
    <Section>
      <BotStatus />
      <Button fluid content={'Change ID:  ' + bot_suffix} onClick={() => act('setid')} />
      <Button fluid content={'Set Home:  ' + set_home} onClick={() => act('sethome')} />

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
          checked={report}
          content="Announce Delivery"
          disabled={noaccess}
          onClick={() => act('report')}
        />
      </Section>
    </Section>
  );
};

const MuleLoad = (props, context) => {
  const { act, data } = useBackend(context);
  const { noaccess, mode, load, destination, cargo_IMG, cargo_info } = data;
  return (
    <Box>
      <Section title="Delivery Settings">
        <Button
          content={'Destination:  ' + (destination ? destination : 'Not Set')}
          selected={destination}
          disabled={noaccess}
          onClick={() => act('destination')}
        />
        <Box>
          {cargo_IMG !== null ? (
            <img
              src={`data:image/jpeg;base64,${cargo_IMG}`}
              style={{
                height: '20%',
                width: '20%',
                'float': 'middle',
                'vertical-align': 'middle',
                '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                'image-rendering': 'pixelated',
              }}
            />
          ) : (
            <Box bold={1}>No Cargo</Box>
          )}
        </Box>
        <Box as="span" m={1.5}>
          {cargo_info}
        </Box>
      </Section>
      <Section title="Movement Settings">
        <Stack fill>
          <Stack.Item>
            <Button fluid icon="location-arrow" content="Go" disabled={noaccess} onClick={() => act('go')} />
          </Stack.Item>
          <Stack.Item>
            <Button fluid icon="home" content="Return" disabled={noaccess} onClick={() => act('home')} />
          </Stack.Item>
          <Stack.Item>
            <Button fluid icon="stop" content="Stop" disabled={noaccess} color="bad" onClick={() => act('stop')} />
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Cargo Settings">
        <Stack fill>
          <Stack.Item>
            <Button
              fluid
              icon="stop"
              content="Load"
              disabled={noaccess || load}
              color="bad"
              onClick={() => act('load')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              fluid
              icon="stop"
              content="Unload"
              disabled={noaccess || !load}
              color="bad"
              onClick={() => act('unload')}
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Box>
  );
};

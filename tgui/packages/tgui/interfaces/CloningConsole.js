import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section, Box, Tabs, Flex } from '../components';
import { Window } from '../layouts';

export const CloningConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    tab,
    hasScanner,
    pods,
    podAmount
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title='Cloning Console'>
          <LabeledList>
            <LabeledList.Item label="Connected scanner">{hasScanner ? 'Online' : 'Missing'}</LabeledList.Item>
            <LabeledList.Item label="Connected pods">{podAmount}</LabeledList.Item>
          </LabeledList>
        </Section>
        <Tabs>
          <Tabs.Tab selected={tab === 1} icon="home" onClick={() => act('menu', {tab: 1})}>Main Menu</Tabs.Tab>
          <Tabs.Tab selected={tab === 2} icon="clipboard-list" onClick={() => act('menu', {tab: 2})}>Damage Configuration</Tabs.Tab>
        </Tabs>
        <Section>
          <CloningConsoleBody />
        </Section>
      </Window.Content>
    </Window>
  );
};

const CloningConsoleBody = (props, context) => {
  const { data } = useBackend(context);
  const { tab } = data;
  let body;
  if (tab === 1) {
    body = <CloningConsoleMain />;
  } else if (tab === 2) {
    body = <CloningConsoleDamage />;
  }
  return body;
};

const CloningConsoleMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    pods
  } = data;
  return (
    <Box>
      {!pods && (<Box color='average'>Notice: No pods connected.</Box>)}
      <Flex>
        {!!pods &&
          pods.map((pod, i) => (
            <Flex.Item key={pod}>
              <Box textAlign='center'>
                <img
                  src={'pod_' + (pod["cloning"] ? 'cloning' : 'idle') + '.gif'}
                  style={{
                   width: '100%',
                    '-ms-interpolation-mode': 'nearest-neighbor',
                  }}
                />
                Pod {i + 1}
              </Box>
            </Flex.Item>
        ))}
      </Flex>
    </Box>
  );
};

const CloningConsoleDamage = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    pods
  } = data;
  return (
    <Box>This is the damage menu</Box>
  );
};

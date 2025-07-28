import { Box, Button, LabeledList, NoticeBox, Section, Stack, Tabs } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const AIResourceManagementConsoleBody = (props) => {
  const { data } = useBackend();
  const { screen } = data;
  let body;

  if (screen === 0) {
    body = <AllocatedResources />;
  } else if (screen === 1) {
    body = <OnlineNodes />;
  }
  return body;
};

export const AIResourceManagementConsole = (props) => {
  const { act, data } = useBackend();
  const { auth, ai_list, nodes_list, screen } = data;

  return (
    <Window width={350} height={425}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab selected={screen === 0} icon="list" onClick={() => act('menu', { screen: 0 })}>
                Allocated Resources
              </Tabs.Tab>
              <Tabs.Tab selected={screen === 1} icon="circle-nodes" onClick={() => act('menu', { screen: 1 })}>
                Online Nodes
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow mt={0}>
            <Section fill scrollable>
              <AIResourceManagementConsoleBody />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AllocatedResources = (props) => {
  const { act, data } = useBackend();
  const { screen, ai_list, nodes_list } = data;
  return (
    <Box>
      {(!ai_list || ai_list.length === 0) && <NoticeBox>No AI detected.</NoticeBox>}
      {!!ai_list &&
        ai_list.map((ai, i) => (
          <Section key={ai} title={ai.name}>
            <LabeledList>
              <LabeledList.Item label="Memory">{ai.memory}</LabeledList.Item>
              <LabeledList.Item label="Maximum Memory">{ai.memory_max}</LabeledList.Item>
              <LabeledList.Item label="Bandwidth">{ai.bandwidth}</LabeledList.Item>
              <LabeledList.Item label="Maximum Bandwidth">{ai.bandwidth_max}</LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
    </Box>
  );
};

const OnlineNodes = (props) => {
  const { act, data } = useBackend();
  const { screen, ai_list, nodes_list } = data;
  return (
    <Box>
      {(!nodes_list || nodes_list.length === 0) && <NoticeBox>No nodes detected.</NoticeBox>}
      {!!nodes_list &&
        nodes_list.map((node, i) => (
          <Section
            key={node}
            title={capitalize(node.name)}
            buttons={
              <Box>
                <Button icon="circle-nodes" onClick={() => act('reassign', { uid: node.uid })}>
                  Reassign
                </Button>
              </Box>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Assigned AI">{node.assigned_ai}</LabeledList.Item>
              <LabeledList.Item label="Resource">{capitalize(node.resource)}</LabeledList.Item>
              <LabeledList.Item label="Amount">{node.amount}</LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
    </Box>
  );
};

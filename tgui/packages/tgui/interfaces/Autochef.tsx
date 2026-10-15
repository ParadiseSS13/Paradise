import { Button, DmIcon, Icon, Section, Stack, Table, Tabs } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import TabsContext, { useTabs } from './common/TabsContext';

enum AutochefState {
  Idle = 0,
  Running,
  Interrupted,
}

enum AutochefActState {
  Started = 0,
  Complete,
  FollowSteps,
  WaitForResult,
  Interrupted,
  Failed,
  StepComplete,
  MissingIngredient,
  MissingReagent,
  MissingMachine,
  NoAvailableMachines,
  NoAvailableStorage,
  AddedTask,
  Valid,
}

type LinkedItem = {
  name: string;
  icon: string;
  icon_state: string;
  uid: string;
  storage: BooleanLike;
};

type Recipe = {
  name: string;
  icon: string;
  icon_state: string;
  type: string;
};

type AutochefTask = {
  desc: string;
  type: string;
  state: AutochefActState;
  repeating: BooleanLike;
  uid: string;
};

type AutochefData = {
  linked_items: LinkedItem[];
  task_queue: AutochefTask[];
  recipe_memory: Recipe[];
  current_recipe: string;
  current_state: AutochefState;
  current_output: string;
};

const AutochefNavigation = () => {
  const { tabIndex, setTabIndex } = useTabs();
  return (
    <Stack vertical>
      <Stack.Item>
        <Tabs>
          <Tabs.Tab icon="list-check" selected={0 === tabIndex} onClick={() => setTabIndex(0)}>
            Task Queue
          </Tabs.Tab>
          <Tabs.Tab icon="link" selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
            Linked Items
          </Tabs.Tab>
          <Tabs.Tab icon="magnifying-glass" selected={2 === tabIndex} onClick={() => setTabIndex(2)}>
            Seen Recipes
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
    </Stack>
  );
};

const AutochefTaskQueue = () => {
  const { data } = useBackend<AutochefData>();
  const { task_queue } = data;
  return (
    <Section title="Task Queue" scrollable>
      <Table>
        {task_queue.map((task) => {
          return (
            <Table.Row key={task.uid} className="candystripe">
              <Table.Cell p={0.5}>
                {task.desc} ({AutochefActState[task.state]}) {!!task.repeating && <Icon name="repeat" />}
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

const AutochefLinkedItems = () => {
  const { act, data } = useBackend<AutochefData>();
  const { linked_items, current_output } = data;
  return (
    <Section title="Linked Items" fill scrollable>
      <Table>
        {linked_items.map((item) => {
          return (
            <Table.Row key={item.uid} className="candystripe">
              <Table.Cell collapsing>
                <DmIcon verticalAlign="middle" icon={item.icon} icon_state={item.icon_state} />
              </Table.Cell>
              <Table.Cell verticalAlign="middle">{item.name}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                {!!item.storage &&
                  (item.uid === current_output ? (
                    <Button disabled>Output</Button>
                  ) : (
                    <Button onClick={() => act('set_output', { item: item.uid })}>Set Output</Button>
                  ))}
                <Button.Confirm onClick={() => act('unlink_item', { item: item.uid })}>Unlink</Button.Confirm>
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

const AutochefSeenRecipes = () => {
  const { act, data } = useBackend<AutochefData>();
  const { recipe_memory, current_recipe } = data;

  return (
    <Section title="Seen Recipes">
      <Table className="candystripe">
        {recipe_memory.map((recipe) => {
          return (
            <Table.Row key={recipe.type} className="candystripe">
              <Table.Cell collapsing>
                <DmIcon verticalAlign="middle" icon={recipe.icon} icon_state={recipe.icon_state} />
              </Table.Cell>
              <Table.Cell verticalAlign="middle">{recipe.name}</Table.Cell>
              <Table.Cell textAlign="right">
                <Stack>
                  <Stack.Item>
                    {recipe.type === current_recipe ? (
                      <Button disabled>Selected</Button>
                    ) : (
                      <Button onClick={() => act('set_recipe', { recipe: recipe.type })}>Select</Button>
                    )}
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

const AutochefContent = () => {
  const { tabIndex } = useTabs();
  switch (tabIndex) {
    case 0:
      return <AutochefTaskQueue />;
    case 1:
      return <AutochefLinkedItems />;
    case 2:
      return <AutochefSeenRecipes />;
  }
  return;
};

export const Autochef = () => {
  const { act, data } = useBackend<AutochefData>();
  const { current_state } = data;

  let primary_button = 'Start';
  switch (current_state) {
    case AutochefState.Interrupted:
      primary_button = 'Resume';
      break;
    case AutochefState.Running:
      primary_button = 'Pause';
      break;
  }

  return (
    <Window width={400} height={550}>
      <Window.Content>
        <Section>
          <Stack>
            <Stack.Item>
              <Button
                onClick={() => {
                  act('toggle_state');
                }}
              >
                {primary_button}
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        <TabsContext.Default tabIndex={0}>
          <Stack fill vertical>
            <AutochefNavigation />
            <AutochefContent />
          </Stack>
        </TabsContext.Default>
      </Window.Content>
    </Window>
  );
};

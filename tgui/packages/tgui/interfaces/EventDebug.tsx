import { createContext, useContext, useState } from 'react';
import { Button, Section, Stack, Table, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface EventData {
  containers: EventContainer[];
  resources: Resource[];
  net_resources: Resource[];
}

interface EventContainer {
  severity: String;
  events: Event[];
}

interface Event {
  name: String;
  weight: number;
}

interface Resource {
  name: String;
  amount: number;
}

type EventTabContextType = {
  tabIndexState: [number, (value: number) => void];
};

const EventTabContext = createContext<EventTabContextType>({
  tabIndexState: [1, () => {}],
});

export const EventDebug = () => {
  const tabIndexState = useState(1);
  return (
    <Window width={800} height={600}>
      <Window.Content>
        <EventTabContext.Provider value={{ tabIndexState }}>
          <Stack vertical>
            <Stack.Item>
              <EventDebugNavigation />
            </Stack.Item>
            <Stack.Item grow>
              <EventDebugContent />
            </Stack.Item>
          </Stack>
        </EventTabContext.Provider>
      </Window.Content>
    </Window>
  );
};

const EventDebugNavigation = () => {
  const { tabIndexState } = useContext<EventTabContextType>(EventTabContext);
  const [tabIndex, settabIndex] = tabIndexState;
  return (
    <Tabs>
      <Tabs.Tab
        key="Mundane"
        selected={tabIndex === 0}
        onClick={() => {
          settabIndex(0);
        }}
      >
        Mundane
      </Tabs.Tab>
      <Tabs.Tab
        key="Moderate"
        selected={tabIndex === 1}
        onClick={() => {
          settabIndex(1);
        }}
      >
        Moderate
      </Tabs.Tab>
      <Tabs.Tab
        key="Major"
        selected={tabIndex === 2}
        onClick={() => {
          settabIndex(2);
        }}
      >
        Major
      </Tabs.Tab>
      <Tabs.Tab
        key="Disaster"
        selected={tabIndex === 3}
        onClick={() => {
          settabIndex(3);
        }}
      >
        Disaster
      </Tabs.Tab>
      <Tabs.Tab
        key="Resource Data"
        selected={tabIndex === 4}
        onClick={() => {
          settabIndex(4);
        }}
      >
        Resource Data
      </Tabs.Tab>
    </Tabs>
  );
};

const PickTitle = (index) => {
  switch (index) {
    case 0:
      return 'Mundane';
    case 1:
      return 'Moderate';
    case 2:
      return 'Major';
    case 3:
      return 'Disaster';
    case 4:
      return 'Resource Data';
    default:
      return 'Something went wrong with this menu, make an issue report please!';
  }
};

const PickTab = (index) => {
  switch (index) {
    case 0:
      return <EventContainerData severity="Mundane" />;
    case 1:
      return <EventContainerData severity="Moderate" />;
    case 2:
      return <EventContainerData severity="Major" />;
    case 3:
      return <EventContainerData severity="Disaster" />;
    case 4:
      return <ResourceData />;
    default:
      return 'Something went wrong with this menu, make an issue report please!';
  }
};

const EventDebugContent = () => {
  const { act } = useBackend<EventData>();
  const { tabIndexState } = useContext<EventTabContextType>(EventTabContext);
  const [tabIndex, settabIndex] = tabIndexState;
  return (
    <Section
      fill
      title={PickTitle(tabIndex)}
      buttons={
        <Stack fill>
          <Button icon="sync" onClick={() => act('refresh')}>
            Refresh
          </Button>
        </Stack>
      }
    >
      <EventDebugContent2 />
    </Section>
  );
};

const EventDebugContent2 = () => {
  const { tabIndexState } = useContext<EventTabContextType>(EventTabContext);
  const [tabIndex, settabIndex] = tabIndexState;
  return PickTab(tabIndex);
};

const EventContainerData = (properties) => {
  const { act, data } = useBackend<EventData>();
  const { containers } = data;
  const { severity } = properties;
  if (!containers) {
    return 'Missing containers data for: ' + severity;
  }
  let container_index: number = 0;
  for (let i = 0; i < containers.length; i++) {
    if (containers[i].severity === severity) {
      container_index = i;
    }
  }

  return (
    <Table className="Event Container Info">
      {containers[container_index].events.map((event, index) => (
        <Table.Row key={index}>
          <Table.Cell>{event.name}</Table.Cell>
          <Table.Cell>{event.weight}</Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const ResourceData = () => {
  const { data } = useBackend<EventData>();
  const { resources, net_resources } = data;
  return (
    <Stack vertical>
      <Section title="Net Resources">
        <Table>
          {net_resources.map((resource, index) => (
            <Table.Row key={index}>
              <Table.Cell>{resource.name}</Table.Cell>
              <Table.Cell>{resource.amount}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
      <Section title="Total Resources">
        <Table>
          {resources.map((resource, index) => (
            <Table.Row key={index}>
              <Table.Cell>{resource.name}</Table.Cell>
              <Table.Cell>{resource.amount}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Stack>
  );
};

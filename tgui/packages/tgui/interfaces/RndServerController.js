import { useBackend, useLocalState } from "../backend";
import { Button, LabeledList, Box, Tabs, Section, Table, ProgressBar } from '../components';
import { Window } from '../layouts';

const PickTab = index => {
  switch (index) {
    case 0:
      return <ServerManagement />;
    case 1:
      return <ConsoleManagement />;
    default:
      return "SOMETHING WENT VERY WRONG PLEASE AHELP";
  }
};

export const RndServerController = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  return (
    <Window>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            key="ServerManagement"
            selected={tabIndex === 0}
            onClick={() => setTabIndex(0)}
            icon="server">
            Server Management
          </Tabs.Tab>
          <Tabs.Tab
            key="ConsoleManagement"
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}
            icon="desktop">
            Console Management
          </Tabs.Tab>
        </Tabs>
        {PickTab(tabIndex)}
      </Window.Content>
    </Window>
  );
};

const ServerManagement = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    active_server_data,
    servers,
  } = data;

  return (
    active_server_data ? (
      <Section title="Selected Server" buttons={
        <Button
          content="Back"
          icon="arrow-left"
          onClick={() => act('back')} />
      }>
        <LabeledList>
          <LabeledList.Item label="Server ID">
            {active_server_data.ref}
          </LabeledList.Item>
          <LabeledList.Item label="Server Status">
            {active_server_data.working ? (
              <Button
                color="green"
                content="Active"
                icon="check"
                onClick={() => act('toggle_server_active')} />
            ) : (
              <Button
                color="red"
                content="Offline"
                icon="times"
                onClick={() => act('toggle_server_active')} />
            )}
          </LabeledList.Item>
          <LabeledList.Item label="System Integrity">
            <ProgressBar
              color={active_server_data.health > 50 ? "good" : "bad"}
              value={active_server_data.health / 100}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Server Location">
            {active_server_data.location}
          </LabeledList.Item>
          <LabeledList.Item label="Server Temperature">
            {active_server_data.temperature} K
          </LabeledList.Item>
        </LabeledList>
      </Section>
    ) : (
      <Section title="Server Management" buttons={
        <Button
          content="Refresh"
          icon="sync-alt"
          onClick={() => act('refresh')} />
      }>
        <Table>
          <Table.Row bold>
            <Table.Cell>Server ID</Table.Cell>
            <Table.Cell>Location</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Control</Table.Cell>
          </Table.Row>
          {servers.map(s => (
            <Table.Row key={s.ref}>
              <Table.Cell>{s.ref}</Table.Cell>
              <Table.Cell>{s.location}</Table.Cell>
              <Table.Cell>
                {s.working ? (
                  <Button color="green" content="Active" />
                ) : (
                  <Button color="red" content="Offline" />
                )}
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon="cog"
                  content="Manage"
                  onClick={() => act('select_server', { suid: s.ref })} />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>

      </Section>
    )
  );
};

const ConsoleManagement = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    consoles,
  } = data;
  return (
    <Section title="Console Management" buttons={
      <Button
        content="Refresh"
        icon="sync-alt"
        onClick={() => act('refresh')} />
    }>
      <Table>
        <Table.Row bold>
          <Table.Cell>Console Name</Table.Cell>
          <Table.Cell>Location</Table.Cell>
          <Table.Cell>Access</Table.Cell>
        </Table.Row>
        {consoles.map(c => (
          <Table.Row key={c.ref}>
            <Table.Cell>{c.name}</Table.Cell>
            <Table.Cell>{c.location}</Table.Cell>
            <Table.Cell>
              <Button
                icon={c.writeaccess ? "file-signature" : "file-contract"}
                content={c.writeaccess ? "Read/Write" : "Read Only"}
                onClick={() => act('toggle_console_access', { cuid: c.ref })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};


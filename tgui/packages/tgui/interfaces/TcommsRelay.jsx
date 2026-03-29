import { Box, Button, LabeledList, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const TcommsRelay = (props) => {
  const { act, data } = useBackend();
  const { linked, active, network_id } = data;

  return (
    <Window width={600} height={292}>
      <Window.Content scrollable>
        <Section title="Relay Configuration">
          <LabeledList>
            <LabeledList.Item label="Machine Power">
              <Button
                content={active ? 'On' : 'Off'}
                selected={active}
                icon="power-off"
                onClick={() => act('toggle_active')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Network ID">
              <Button
                content={network_id ? network_id : 'Unset'}
                selected={network_id}
                icon="server"
                onClick={() => act('network_id')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Link Status">
              {linked === 1 ? <Box color="green">Linked</Box> : <Box color="red">Unlinked</Box>}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {linked === 1 ? <LinkedView /> : <UnlinkedView />}
      </Window.Content>
    </Window>
  );
};

const LinkedView = (_properties) => {
  const { act, data } = useBackend();
  const { linked_core_id, linked_core_addr, hidden_link } = data;
  return (
    <Section title="Link Status">
      <LabeledList>
        <LabeledList.Item label="Linked Core ID">{linked_core_id}</LabeledList.Item>
        <LabeledList.Item label="Linked Core Address">{linked_core_addr}</LabeledList.Item>
        <LabeledList.Item label="Hidden Link">
          <Button
            content={hidden_link ? 'Yes' : 'No'}
            icon={hidden_link ? 'eye-slash' : 'eye'}
            selected={hidden_link}
            onClick={() => act('toggle_hidden_link')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Unlink">
          <Button content="Unlink" icon="unlink" color="red" onClick={() => act('unlink')} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const UnlinkedView = (_properties) => {
  const { act, data } = useBackend();
  const { cores } = data;
  return (
    <Section title="Detected Cores">
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Network Address</Table.Cell>
          <Table.Cell>Network ID</Table.Cell>
          <Table.Cell>Sector</Table.Cell>
          <Table.Cell>Link</Table.Cell>
        </Table.Row>
        {cores.map((c) => (
          <Table.Row key={c.addr}>
            <Table.Cell>{c.addr}</Table.Cell>
            <Table.Cell>{c.net_id}</Table.Cell>
            <Table.Cell>{c.sector}</Table.Cell>
            <Table.Cell>
              <Button
                content="Link"
                icon="link"
                onClick={() =>
                  act('link', {
                    addr: c.addr,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

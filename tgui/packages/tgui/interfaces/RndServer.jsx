import { Box, Button, LabeledList, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const RndServer = (props) => {
  const { act, data } = useBackend();
  const { active, network_name } = data;

  return (
    <Window width={600} height={500} resizable>
      <Window.Content scrollable>
        <Section title="Server Configuration">
          <LabeledList>
            <LabeledList.Item label="Machine power">
              <Button
                content={active ? 'On' : 'Off'}
                selected={active}
                icon="power-off"
                onClick={() => act('toggle_active')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Link status">
              {network_name === null ? <Box color="red">Unlinked</Box> : <Box color="green">Linked</Box>}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {network_name === null ? <UnlinkedView /> : <LinkedView />}
      </Window.Content>
    </Window>
  );
};

const LinkedView = (_properties) => {
  const { act, data } = useBackend();
  const { network_name } = data;
  return (
    <Section title="Network Info">
      <LabeledList>
        <LabeledList.Item label="Connected network ID">{network_name}</LabeledList.Item>
        <LabeledList.Item label="Unlink">
          <Button content="Unlink" icon="unlink" color="red" onClick={() => act('unlink')} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const UnlinkedView = (_properties) => {
  const { act, data } = useBackend();
  const { controllers } = data;
  return (
    <Section title="Detected Cores">
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Network ID</Table.Cell>
          <Table.Cell>Link</Table.Cell>
        </Table.Row>
        {controllers.map((c) => (
          <Table.Row key={c.addr}>
            <Table.Cell>{c.netname}</Table.Cell>
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

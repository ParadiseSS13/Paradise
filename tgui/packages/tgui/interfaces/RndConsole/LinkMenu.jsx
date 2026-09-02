import { Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

export const LinkMenu = (properties) => {
  const { act, data } = useBackend();

  const { controllers } = data;

  return (
    <Window width={800} height={550}>
      <Window.Content>
        <Section title="Setup Linkage">
          <Table m="0.5rem">
            <Table.Row header>
              <Table.Cell>Network Address</Table.Cell>
              <Table.Cell>Network ID</Table.Cell>
              <Table.Cell>Link</Table.Cell>
            </Table.Row>
            {controllers.map((c) => (
              <Table.Row key={c.addr}>
                <Table.Cell>{c.addr}</Table.Cell>
                <Table.Cell>{c.net_id}</Table.Cell>
                <Table.Cell>
                  <Button
                    content="Link"
                    icon="link"
                    onClick={() =>
                      act('linktonetworkcontroller', {
                        target_controller: c.addr,
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

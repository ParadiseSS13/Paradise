import { Box, Button, LabeledList, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const RndBackupConsole = (properties) => {
  const { act, data } = useBackend();
  const { network_name, has_disk, disk_name, linked, techs, last_timestamp } = data;

  return (
    <Window width={900} height={600}>
      <Window.Content scrollable>
        <Section title="Device Info">
          <Box mb={2}>
            <LabeledList>
              <LabeledList.Item label="Current Network">
                {linked ? (
                  <Button content={network_name} icon="unlink" selected={1} onClick={() => act('unlink')} />
                ) : (
                  'None'
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Loaded Disk">
                {has_disk ? (
                  <>
                    <Button
                      content={disk_name + ' (Last backup: ' + last_timestamp + ')'}
                      icon="save"
                      selected={1}
                      onClick={() => act('eject_disk')}
                    />
                    <Button icon="sign-in-alt" content="Save all" onClick={() => act('saveall2disk')} />
                    <Button icon="sign-out-alt" content="Load all" onClick={() => act('saveall2network')} />
                  </>
                ) : (
                  'None'
                )}
              </LabeledList.Item>
            </LabeledList>
          </Box>
          {!!linked || <LinkMenu />}
        </Section>
        <Box mt={2}>
          <Section title="Tech Info">
            <Table m="0.5rem">
              <Table.Row header>
                <Table.Cell>Tech Name</Table.Cell>
                <Table.Cell>Network Level</Table.Cell>
                <Table.Cell>Disk Level</Table.Cell>
                <Table.Cell>Actions</Table.Cell>
              </Table.Row>
              {Object.keys(techs).map(
                (t) =>
                  !(techs[t]['network_level'] > 0 || techs[t]['disk_level'] > 0) || (
                    <Table.Row key={t}>
                      <Table.Cell>{techs[t]['name']}</Table.Cell>
                      <Table.Cell>{techs[t]['network_level'] || 'None'}</Table.Cell>
                      <Table.Cell>{techs[t]['disk_level'] || 'None'}</Table.Cell>
                      <Table.Cell>
                        <Button
                          icon="sign-in-alt"
                          content="Load to network"
                          disabled={!has_disk || !linked}
                          onClick={() => act('savetech2network', { tech: t })}
                        />
                        <Button
                          icon="sign-out-alt"
                          content="Load to disk"
                          disabled={!has_disk || !linked}
                          onClick={() => act('savetech2disk', { tech: t })}
                        />
                      </Table.Cell>
                    </Table.Row>
                  )
              )}
            </Table>
          </Section>
        </Box>
      </Window.Content>
    </Window>
  );
};

export const LinkMenu = (properties) => {
  const { act, data } = useBackend();

  const { controllers } = data;

  return (
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
  );
};

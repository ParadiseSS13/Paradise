import { Box, Button, LabeledList, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const RndServer = (props) => {
  const { act, data } = useBackend();
  const { active, network_name, point_gen_val, point_gen_type, total_points, mode, stored_points, loaded_disk } = data;

  return (
    <Window width={600} height={500} resizable>
      <Window.Content scrollable>
        <Section title="Server Configuration">
          <LabeledList>
            <LabeledList.Item label="Server state">
              <Button
                content={data.active ? 'On' : 'Off'}
                selected={data.active}
                icon="power-off"
                onClick={() => act('swtch_on')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Mode">
              <Button
                content={data.mode ? 'Auto' : 'Store'}
                selected={data.mode}
                onClick={() => act('mode')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Link status">
              {network_name === null ? <Box color="red">Unlinked</Box> : <Box color="green">Linked</Box>}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {network_name === null ? <UnlinkedView /> : <LinkedView />}
        <Section title="Server Information">
          <LabeledList>
            <LabeledList.Item label="Point Generation">{point_gen_val} {point_gen_type} points per second</LabeledList.Item>
            <LabeledList.Item label="Total Generated">{total_points} {point_gen_type} points </LabeledList.Item>
          </LabeledList>
        </Section>
        {loaded_disk === null ? <DisklessView /> : <DiskView />}
      </Window.Content>
    </Window>
  );
};

const DisklessView = (_properties) => {
  const { act, data } = useBackend();
  const { stored_points, point_gen_type } = data;
  return (
    <Section title="Disk Info">
      <LabeledList>
          <LabeledList.Item label="Stored Points (Server)">{stored_points} {point_gen_type} </LabeledList.Item>
          <LabeledList.Item label="Stored Points (Disk)">No Disk Detected </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};


const DiskView = (_properties) => {
  const { act, data } = useBackend();
  const { disk_stored_t, disk_stored_p, stored_points, point_gen_type } = data;
  return (
    <Section title="Disk Info">
      <LabeledList>
          <LabeledList.Item label="Stored Points (Server)">{stored_points} {point_gen_type} </LabeledList.Item>
          <LabeledList.Item label="Stored Points (Disk)">{disk_stored_p} {disk_stored_t} </LabeledList.Item>
            <LabeledList.Item label="Transfer Points">
              <Button
                content={'Transfer'}
                onClick={() => act('load')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Eject Disk">
              <Button
                content={'Eject'}
                onClick={() => act('eject_disk')}
                icon="arrow-up-from-bracket"
              />
            </LabeledList.Item>
      </LabeledList>
    </Section>
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

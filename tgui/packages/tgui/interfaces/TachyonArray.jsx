import { Button, Flex, LabeledList, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const TachyonArray = (props) => {
  const { act, data } = useBackend();
  const { records = [], explosion_target, toxins_tech, printing } = data;
  return (
    <Window width={500} height={600}>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Shift's Target">{explosion_target}</LabeledList.Item>
            <LabeledList.Item label="Current Toxins Level">{toxins_tech}</LabeledList.Item>
            <LabeledList.Item label="Administration">
              <Button
                icon="print"
                content="Print All Logs"
                disabled={!records.length || printing}
                align="center"
                onClick={() => act('print_logs')}
              />
              <Button.Confirm
                icon="trash"
                content="Delete All Logs"
                disabled={!records.length}
                color="bad"
                align="center"
                onClick={() => act('delete_logs')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!records.length ? <NoticeBox>No Records</NoticeBox> : <TachyonArrayContent />}
      </Window.Content>
    </Window>
  );
};

export const TachyonArrayContent = (props) => {
  const { act, data } = useBackend();
  const { records = [] } = data;

  return (
    <Section title="Logged Explosions">
      <Flex>
        <Flex.Item>
          <Table m="0.5rem">
            <Table.Row header>
              <Table.Cell>Time</Table.Cell>
              <Table.Cell>Epicenter</Table.Cell>
              <Table.Cell>Actual Size</Table.Cell>
              <Table.Cell>Theoretical Size</Table.Cell>
            </Table.Row>
            {records.map((a) => (
              <Table.Row key={a.index}>
                <Table.Cell>{a.logged_time}</Table.Cell>
                <Table.Cell>{a.epicenter}</Table.Cell>
                <Table.Cell>{a.actual_size_message}</Table.Cell>
                <Table.Cell>{a.theoretical_size_message}</Table.Cell>
                <Table.Cell>
                  <Button.Confirm
                    icon="trash"
                    content="Delete"
                    color="bad"
                    onClick={() =>
                      act('delete_record', {
                        'index': a.index,
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

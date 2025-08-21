import { Box, Button, Section, Stack, Table } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { BooleanLike } from 'tgui-core/react';
import { JobSlotData } from './types';

type Props = {
  cooldown_time: BooleanLike | string;
  job_slots?: JobSlotData[];
  target_dept: number;
  priority_jobs: string[];
};

export const CardComputerJobPriority = (props: Props) => {
  const { act } = useBackend();
  const { cooldown_time, job_slots, target_dept, priority_jobs } = props;
  return (
    <Stack fill vertical>
      <Section color={cooldown_time ? 'red' : ''}>
        Next Change Available:
        {cooldown_time ? cooldown_time : 'Now'}
      </Section>
      <Section fill scrollable title="Job Slots">
        <Table>
          <Table.Row height={2}>
            <Table.Cell bold textAlign="center">
              Title
            </Table.Cell>
            <Table.Cell bold textAlign="center">
              Used Slots
            </Table.Cell>
            <Table.Cell bold textAlign="center">
              Total Slots
            </Table.Cell>
            <Table.Cell bold textAlign="center">
              Free Slots
            </Table.Cell>
            <Table.Cell bold textAlign="center">
              Close Slot
            </Table.Cell>
            <Table.Cell bold textAlign="center">
              Open Slot
            </Table.Cell>
            <Table.Cell bold textAlign="center">
              Priority
            </Table.Cell>
          </Table.Row>
          {job_slots &&
            job_slots.map((slotData) => (
              <Table.Row key={slotData.title} height={2} className="candystripe">
                <Table.Cell textAlign="center">
                  <Box color={slotData.is_priority ? 'green' : ''}>{slotData.title}</Box>
                </Table.Cell>
                <Table.Cell textAlign="center">{slotData.current_positions}</Table.Cell>
                <Table.Cell textAlign="center">{slotData.total_positions}</Table.Cell>
                <Table.Cell textAlign="center">
                  {(slotData.total_positions > slotData.current_positions && (
                    <Box color="green">{slotData.total_positions - slotData.current_positions}</Box>
                  )) || <Box color="red">0</Box>}
                </Table.Cell>
                <Table.Cell textAlign="center">
                  <Button
                    disabled={!!cooldown_time || !slotData.can_close}
                    onClick={() => act('make_job_unavailable', { job: slotData.title })}
                  >
                    -
                  </Button>
                </Table.Cell>
                <Table.Cell textAlign="center">
                  <Button
                    disabled={!!cooldown_time || !slotData.can_open}
                    onClick={() => act('make_job_available', { job: slotData.title })}
                  >
                    +
                  </Button>
                </Table.Cell>
                <Table.Cell textAlign="center">
                  {(target_dept && (
                    <Box color="green">{priority_jobs.indexOf(slotData.title) > -1 ? 'Yes' : ''}</Box>
                  )) || (
                    <Button
                      selected={slotData.is_priority}
                      disabled={!!cooldown_time || !slotData.can_prioritize}
                      onClick={() => act('prioritize_job', { job: slotData.title })}
                    >
                      {slotData.is_priority ? 'Yes' : 'No'}
                    </Button>
                  )}
                </Table.Cell>
              </Table.Row>
            ))}
        </Table>
      </Section>
    </Stack>
  );
};

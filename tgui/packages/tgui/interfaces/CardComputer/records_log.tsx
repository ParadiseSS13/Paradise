import { Box, Button, Section, Table } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { CardComputerRecord } from './types';

type Props = {
  authenticated: BooleanLike;
  records: CardComputerRecord[];
  target_dept: number;
  is_centcom: BooleanLike;
};

export const CardComputerRecordsLog = (props: Props) => {
  const { act } = useBackend();
  const { authenticated, records, target_dept, is_centcom } = props;

  return (
    <Section
      fill
      scrollable
      title="Records"
      buttons={
        <Button
          icon="times"
          disabled={!authenticated || records.length === 0 || target_dept}
          onClick={() => act('wipe_all_logs')}
        >
          Delete All Records
        </Button>
      }
    >
      <Table>
        <Table.Row height={2}>
          <Table.Cell bold>Crewman</Table.Cell>
          <Table.Cell bold>Old Rank</Table.Cell>
          <Table.Cell bold>New Rank</Table.Cell>
          <Table.Cell bold>Authorized By</Table.Cell>
          <Table.Cell bold>Time</Table.Cell>
          <Table.Cell bold>Reason</Table.Cell>
          {!!is_centcom && <Table.Cell bold>Deleted By</Table.Cell>}
        </Table.Row>
        {records.map((record) => (
          <Table.Row key={record.timestamp} height={2}>
            <Table.Cell>{record.transferee}</Table.Cell>
            <Table.Cell>{record.oldvalue}</Table.Cell>
            <Table.Cell>{record.newvalue}</Table.Cell>
            <Table.Cell>{record.whodidit}</Table.Cell>
            <Table.Cell>{record.timestamp}</Table.Cell>
            <Table.Cell>{record.reason}</Table.Cell>
            {!!is_centcom && <Table.Cell>{record.deletedby}</Table.Cell>}
          </Table.Row>
        ))}
      </Table>
      {!!is_centcom && (
        <Box>
          <Button
            icon="pencil-alt"
            color="purple"
            disabled={!authenticated || records.length === 0}
            onClick={() => act('wipe_my_logs')}
          >
            Delete MY Records
          </Button>
        </Box>
      )}
    </Section>
  );
};

import { Button, Section, Stack, Table, TimeDisplay } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const BrigCellsTableRow = (properties) => {
  const { cell } = properties;
  const { act } = useBackend();
  const { cell_id, occupant, crimes, brigged_by, time_left_seconds, time_set_seconds, ref } = cell;

  let className = '';
  if (time_left_seconds > 0) {
    className += ' BrigCells__listRow--active';
  }

  const release = () => {
    act('release', { ref });
  };

  return (
    <Table.Row className={className}>
      <Table.Cell>{cell_id}</Table.Cell>
      <Table.Cell>{occupant}</Table.Cell>
      <Table.Cell>{crimes}</Table.Cell>
      <Table.Cell>{brigged_by}</Table.Cell>
      <Table.Cell>
        <TimeDisplay totalSeconds={time_set_seconds} />
      </Table.Cell>
      <Table.Cell>
        <TimeDisplay totalSeconds={time_left_seconds} />
      </Table.Cell>
      <Table.Cell>
        <Button type="button" onClick={release}>
          Release
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

const BrigCellsTable = ({ cells }) => (
  <Table className="BrigCells__list">
    <Table.Row>
      <Table.Cell header>Cell</Table.Cell>
      <Table.Cell header>Occupant</Table.Cell>
      <Table.Cell header>Crimes</Table.Cell>
      <Table.Cell header>Brigged By</Table.Cell>
      <Table.Cell header>Time Brigged For</Table.Cell>
      <Table.Cell header>Time Left</Table.Cell>
      <Table.Cell header>Release</Table.Cell>
    </Table.Row>
    {cells.map((cell) => (
      <BrigCellsTableRow key={cell.ref} cell={cell} />
    ))}
  </Table>
);

export const BrigCells = (properties) => {
  const { act, data } = useBackend();
  const { cells } = data;

  return (
    <Window theme="security" width={800} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Section fill scrollable>
            <BrigCellsTable cells={cells} />
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

import { Box, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const LatheMaterials = (properties) => {
  const { data } = useBackend();

  const { total_materials, max_materials, max_chemicals, total_chemicals } = data;

  return (
    <Box className="RndConsole__LatheMaterials" mb="10px">
      <Table width="auto">
        <Table.Row>
          <Table.Cell bold>Material Amount:</Table.Cell>
          <Table.Cell>{total_materials}</Table.Cell>
          {max_materials ? <Table.Cell>{' / ' + max_materials}</Table.Cell> : null}
        </Table.Row>
        <Table.Row>
          <Table.Cell bold>Chemical Amount:</Table.Cell>
          <Table.Cell>{total_chemicals}</Table.Cell>
          {max_chemicals ? <Table.Cell>{' / ' + max_chemicals}</Table.Cell> : null}
        </Table.Row>
      </Table>
    </Box>
  );
};

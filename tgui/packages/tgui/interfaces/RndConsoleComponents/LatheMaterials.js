import { useBackend } from "../../backend";
import { Box, Table } from "../../components";


export const LatheMaterials = (properties, context) => {
  const { data } = useBackend(context);

  const {
    total_materials,
    max_materials,
    max_chemicals,
    total_chemicals,
  } = data;

  return (
    <Box mb="10px">
      <Box color="yellow">
        <Table>
          <Table.Row>
            <Table.Cell bold>Material Amount:</Table.Cell>
            <Table.Cell>{total_materials}</Table.Cell>
            {max_materials ? (
              <Table.Cell>
                {" / " + max_materials}
              </Table.Cell>
            ) : null}
          </Table.Row>
          <Table.Row>
            <Table.Cell bold>Chemical Amount:</Table.Cell>
            <Table.Cell>{total_chemicals}</Table.Cell>
            {max_chemicals ? (
              <Table.Cell>
                {" / " + max_chemicals}

              </Table.Cell>
            ) : null}
          </Table.Row>
        </Table>
      </Box>
    </Box>

  );
};

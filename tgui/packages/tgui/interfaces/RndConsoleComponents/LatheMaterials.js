import { useBackend } from "../../backend";
import { Box } from "../../components";


export const LatheMaterials = (properties, context) => {
  const { data } = useBackend(context);

  const {
    total_materials,
    max_materials,
    max_chemicals,
    total_chemicals,
  } = data;

  return (
    <div style={{ 'margin': '0 0 10px 0' }}>
      <Box color="yellow">
        <table>
          <tr>
            <td style={{ 'font-weight': 'bold' }}>Material Amount:</td>
            <td>{total_materials}</td>
            {max_materials ? (
              <td>
                {" / " + max_materials}
              </td>
            ) : null}
          </tr>
          <tr>
            <td style={{ 'font-weight': 'bold' }}>Chemical Amount:</td>
            <td>{total_chemicals}</td>
            {max_chemicals ? (
              <td>
                {" / " + max_chemicals}

              </td>
            ) : null}
          </tr>
        </table>
      </Box>
    </div>

  );
};

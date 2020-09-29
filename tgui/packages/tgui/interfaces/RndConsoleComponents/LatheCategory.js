import { useBackend } from "../../backend";
import { Button, Section } from "../../components";
import { LatheMaterials } from "./index";

// Also handles search results
export const LatheCategory = (properties, context) => {
  const { data, act } = useBackend(context);

  const {
    category,
    matching_designs,
    menu,
  } = data;

  const lathe = menu === 4;
  // imprinter current ignores amount, only prints 1, always can_build 1 or 0
  const action = lathe ? 'build' : 'imprint';

  return (
    <Section title={category}>
      <LatheMaterials />
      <table>
        {matching_designs.map(({ id, name, can_build, materials }) => {
          return (
            <tr key={id}>
              <td>
                <Button
                  icon="print"
                  content={name}
                  disabled={!can_build}
                  onClick={() => act(action, { id, amount: 1 })} />
              </td>
              <td>
                {can_build >= 5 ? (
                  <Button
                    content="x5"
                    onClick={() => act(action, { id, amount: 5 })} />
                ) : null}
              </td>
              <td>
                {can_build >= 10 ? (
                  <Button
                    content="x10"
                    onClick={() => act(action, { id, amount: 10 })} />
                ) : null}
              </td>
              <td>
                {materials.map(mat => (
                  <>
                    {" | "}
                    <span className={mat.is_red ? 'color-red' : null}>
                      {mat.amount} {mat.name}
                    </span>
                  </>
                ))}
              </td>
            </tr>
          );
        })}
      </table>
    </Section>
  );
};

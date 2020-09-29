import { useBackend } from "../../backend";
import { Button, Section } from "../../components";


export const LatheMaterialStorage = (properties, context) => {
  const { data, act } = useBackend(context);
  const { loaded_materials } = data;
  return (
    <Section title="Material Storage">
      <table className="color-yellow">
        {loaded_materials.map(({ id, amount, name }) => {
          const eject = amount => {
            const action = data.menu === 4 ? 'lathe_ejectsheet' : 'imprinter_ejectsheet';
            act(action, { id, amount });
          };
          // 1 sheet = 2000 units
          const sheets = Math.floor((amount / 2000));
          const plural = sheets === 1 ? '' : 's';
          return (
            <tr key={id}>
              <td style={{ 'min-width': '210px' }}>
                * {amount} of {name}
              </td>
              <td style={{ 'min-width': '110px' }}>
                ({sheets} sheet{plural})
              </td>
              <td>
                {amount >= 2000 ? (
                  <>
                    <Button content="1x" icon="eject" onClick={() => eject(1)} />
                    <Button content="C" icon="eject" onClick={() => eject('custom')} />
                    {amount >= 2000 * 5 ? (
                      <Button content="5x" icon="eject" onClick={() => eject(5)} />
                    ) : null}
                    <Button content="All" icon="eject" onClick={() => eject(50)} />
                  </>
                ) : null}
              </td>
            </tr>
          );
        })}
      </table>
    </Section>
  );
};

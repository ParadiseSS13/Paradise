import { Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const LatheMaterialStorage = (properties) => {
  const { data, act } = useBackend();
  const { loaded_materials } = data;
  return (
    <Section className="RndConsole__LatheMaterialStorage" title="Material Storage">
      <Table>
        {loaded_materials.map(({ id, amount, name }) => {
          const eject = (amount) => {
            const action = data.menu === 4 ? 'lathe_ejectsheet' : 'imprinter_ejectsheet';
            act(action, { id, amount });
          };
          // 1 sheet = 2000 units
          const sheets = Math.floor(amount / 2000);
          const empty = amount < 1;
          const plural = sheets === 1 ? '' : 's';
          return (
            <Table.Row key={id} className={empty ? 'color-grey' : 'color-yellow'}>
              <Table.Cell minWidth="210px">
                * {amount} of {name}
              </Table.Cell>
              <Table.Cell minWidth="110px">
                ({sheets} sheet{plural})
              </Table.Cell>
              <Table.Cell>
                {amount >= 2000 ? (
                  <>
                    <Button content="1x" icon="eject" onClick={() => eject(1)} />
                    <Button content="C" icon="eject" onClick={() => eject('custom')} />
                    {amount >= 2000 * 5 ? <Button content="5x" icon="eject" onClick={() => eject(5)} /> : null}
                    <Button content="All" icon="eject" onClick={() => eject(50)} />
                  </>
                ) : null}
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

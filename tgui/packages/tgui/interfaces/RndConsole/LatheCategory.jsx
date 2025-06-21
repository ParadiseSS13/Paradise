import { Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { LatheMaterials } from './LatheMaterials';

// Also handles search results
export const LatheCategory = (properties) => {
  const { data, act } = useBackend();

  const { category, matching_designs, menu } = data;

  const lathe = menu === 4;
  // imprinter current ignores amount, only prints 1, always can_build 1 or 0
  const action = lathe ? 'build' : 'imprint';

  return (
    <Section fill scrollable height={36} title={category}>
      <LatheMaterials />
      <Table className="RndConsole__LatheCategory__MatchingDesigns">
        {matching_designs.map(({ id, name, can_build, materials }) => {
          return (
            <Table.Row key={id}>
              <Table.Cell>
                <Button
                  icon="print"
                  content={name}
                  disabled={can_build < 1}
                  onClick={() => act(action, { id, amount: 1 })}
                />
              </Table.Cell>
              <Table.Cell>
                {can_build >= 5 ? <Button content="x5" onClick={() => act(action, { id, amount: 5 })} /> : null}
              </Table.Cell>
              <Table.Cell>
                {can_build >= 10 ? <Button content="x10" onClick={() => act(action, { id, amount: 10 })} /> : null}
              </Table.Cell>
              <Table.Cell>
                {materials.map((mat) => (
                  <>
                    {' | '}
                    <span className={mat.is_red ? 'color-red' : null}>
                      {mat.amount} {mat.name}
                    </span>
                  </>
                ))}
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};
